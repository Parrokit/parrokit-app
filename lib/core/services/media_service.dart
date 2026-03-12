// ============================================================================
// lib/core/services/media_service.dart
// ============================================================================
//
// [역할]
// 미디어 데이터(Title, Release, Episode, Clip) 조작 및 비즈니스 로직 담당 서비스
//
// [레이어]
// Core > Services
// ============================================================================

import 'dart:io' show File;
import 'package:drift/drift.dart';
import 'package:path_provider/path_provider.dart';
import '../../data/local/app_database.dart';
import '../../data/models/clip_view.dart';

/// 미디어 데이터(Title, Release, Episode, Clip) 조작 및 비즈니스 로직 담당 서비스
class MediaService {
  final AppDatabase db;

  MediaService(this.db);

  /// Clip ID로 단일 클립 정보(세그먼트 포함) 조회.
  Future<ClipView?> fetchClipById(int clipId) async {
    final clip = await (db.select(db.clips)
          ..where((c) => c.id.equals(clipId))
          ..limit(1))
        .getSingleOrNull();
    if (clip == null) return null;

    final segments = await (db.select(db.segments)
          ..where((s) => s.clipId.equals(clip.id))
          ..orderBy([(s) => OrderingTerm.asc(s.startMs)]))
        .get();

    final abs = await _absolutePathFor(clip.filePath);
    final clipAbs = clip.copyWith(filePath: abs);

    return ClipView(clip: clipAbs, segments: segments);
  }

  /// Clip 삭제 (파일 및 상위 고아 데이터 정리 포함).
  Future<bool> deleteClipById(int clipId) async {
    Clip? target;
    try {
      target = await (db.select(db.clips)
            ..where((c) => c.id.equals(clipId))
            ..limit(1))
          .getSingleOrNull();
      if (target == null) return false;

      // 1. DB 삭제 트랜잭션
      await db.transaction(() async {
        await (db.delete(db.segments)..where((s) => s.clipId.equals(clipId)))
            .go();
        await (db.delete(db.clipTags)..where((ct) => ct.clipId.equals(clipId)))
            .go();
        await (db.delete(db.clips)..where((c) => c.id.equals(clipId))).go();

        // 상위 구조 고아 정리
        await _cleanupAfterClipDelete(episodeId: target!.episodeId);
      });

      // 2. 파일 삭제 (절대 경로 보정 후)
      if (target.filePath.isNotEmpty) {
        try {
          final abs = await _absolutePathFor(target.filePath);
          final f = File(abs);
          if (await f.exists()) await f.delete();
        } catch (_) {}
      }

      return true;
    } catch (_) {
      return false;
    }
  }

  /// 미디어 추가 (Title ~ Clip 계층 구조 생성).
  Future<void> addMedia({
    required String titleName,
    required String titleNameNative,
    required String type,
    required int? seasonNumber,
    required int? episodeNumber,
    required String episodeTitle,
    required String clipTitle,
    required String filePath,
    required int durationMs,
    required List<Segment> segments,
    required List<String>? tags,
  }) async {
    await db.transaction(() async {
      final titleId = await _ensureTitle(titleName, titleNameNative);

      final releaseId = await _ensureRelease(
        titleId: titleId,
        type: type, // 'season' | 'movie'
        seasonNumber: seasonNumber,
      );

      final episodeId = await _ensureEpisode(
        releaseId: releaseId,
        type: type,
        episodeNumber: episodeNumber,
        episodeTitle: episodeTitle,
      );

      final clipId = await db.into(db.clips).insert(
            ClipsCompanion.insert(
              episodeId: episodeId,
              title: clipTitle,
              filePath: filePath,
              durationMs: durationMs,
            ),
          );

      for (final s in segments) {
        await db.into(db.segments).insert(
              SegmentsCompanion.insert(
                clipId: clipId,
                startMs: s.startMs,
                endMs: s.endMs,
                original: s.original,
                pron: s.pron,
                trans: s.trans,
              ),
            );
      }

      if (tags != null) {
        for (final name in tags) {
          final tagId = await _ensureTag(name);
          await db.into(db.clipTags).insert(
                ClipTagsCompanion.insert(clipId: clipId, tagId: tagId),
                mode: InsertMode.insertOrIgnore,
              );
        }
      }
    });
  }

  /// 미디어 정보 수정 (이동 포함).
  Future<void> updateMedia({
    required int clipId,
    required String titleName,
    required String titleNameNative,
    required String type,
    required int? seasonNumber,
    required int? episodeNumber,
    required String episodeTitle,
    required String clipTitle,
    required String filePath,
    required int durationMs,
    required List<Segment> segments,
    required List<String>? tags,
  }) async {
    await db.transaction(() async {
      // 1) 이전 계층 id들 확보 (이동 후 고아 정리용)
      final prevClip = await (db.select(db.clips)
            ..where((c) => c.id.equals(clipId)))
          .getSingle();
      final prevEpisode = await (db.select(db.episodes)
            ..where((e) => e.id.equals(prevClip.episodeId)))
          .getSingle();
      final prevRelease = await (db.select(db.releases)
            ..where((r) => r.id.equals(prevEpisode.releaseId)))
          .getSingle();
      final prevTitleId = prevRelease.titleId;

      final oldEpisodeId = prevEpisode.id;
      final oldReleaseId = prevRelease.id;
      final oldTitleId = prevTitleId;

      // 2) 새 계층 ensure
      final titleId = await _ensureTitle(titleName, titleNameNative);
      final releaseId = await _ensureRelease(
        titleId: titleId,
        type: type,
        seasonNumber: seasonNumber,
      );

      final episodeId = await _ensureEpisode(
        releaseId: releaseId,
        type: type,
        episodeNumber: episodeNumber,
        episodeTitle: episodeTitle,
      );

      // 3) 클립 갱신
      await (db.update(db.clips)..where((c) => c.id.equals(clipId))).write(
        ClipsCompanion(
          episodeId: Value(episodeId),
          title: Value(clipTitle),
          filePath: Value(filePath),
          durationMs: Value(durationMs),
        ),
      );

      // 4) 세그먼트 재작성 (Full replace)
      await (db.delete(db.segments)..where((s) => s.clipId.equals(clipId)))
          .go();
      for (final s in segments) {
        await db.into(db.segments).insert(
              SegmentsCompanion.insert(
                clipId: clipId,
                startMs: s.startMs,
                endMs: s.endMs,
                original: s.original,
                pron: s.pron,
                trans: s.trans,
              ),
            );
      }

      // 5) 태그 갱신
      if (tags != null) {
        await (db.delete(db.clipTags)..where((ct) => ct.clipId.equals(clipId)))
            .go();
        for (final name in tags.toSet()) {
          final tagId = await _ensureTag(name);
          await db.into(db.clipTags).insert(
                ClipTagsCompanion.insert(clipId: clipId, tagId: tagId),
                mode: InsertMode.insertOrIgnore,
              );
        }
      }

      // 6) 이전 계층 고아 정리 (새 episodeId와 동일하면 아무 일도 안 일어남)
      await _pruneOrphansAfterMove(
        oldEpisodeId: oldEpisodeId,
        oldReleaseId: oldReleaseId,
        oldTitleId: oldTitleId,
      );
    });
  }

  // ─────────────────────────────────────────────────────────────────
  // Helpers (Private logic methods)
  // ─────────────────────────────────────────────────────────────────

  /// clip.filePath가 상대경로라면 App Documents와 합쳐 절대경로로 변환.
  Future<String> _absolutePathFor(String pathFromClip) async {
    if (pathFromClip.startsWith('/')) return pathFromClip;
    final dir = await getApplicationDocumentsDirectory();
    return '${dir.path}/$pathFromClip';
  }

  Future<void> _cleanupAfterClipDelete({
    required int episodeId,
  }) async {
    // 1) 에피소드에 클립이 남았는지 확인
    final remainingClips = await (db.select(db.clips)
          ..where((c) => c.episodeId.equals(episodeId))
          ..limit(1))
        .get();

    if (remainingClips.isNotEmpty) return;

    // 에피소드 정보 가져오기
    final ep = await (db.select(db.episodes)
          ..where((e) => e.id.equals(episodeId))
          ..limit(1))
        .getSingleOrNull();

    if (ep == null) return;

    // 1-1) 에피소드 삭제
    await (db.delete(db.episodes)..where((e) => e.id.equals(episodeId))).go();

    final releaseId = ep.releaseId;

    // 2) 해당 릴리즈에 에피소드가 남았는지 확인
    final remainingEpisodes = await (db.select(db.episodes)
          ..where((e) => e.releaseId.equals(releaseId))
          ..limit(1))
        .get();

    if (remainingEpisodes.isNotEmpty) return;

    // 릴리즈 정보 가져오기
    final rel = await (db.select(db.releases)
          ..where((r) => r.id.equals(releaseId))
          ..limit(1))
        .getSingleOrNull();

    if (rel == null) return;

    // 2-1) 릴리즈 삭제
    await (db.delete(db.releases)..where((r) => r.id.equals(releaseId))).go();

    final titleId = rel.titleId;

    // 3) 해당 타이틀에 릴리즈가 남았는지 확인
    final remainingReleases = await (db.select(db.releases)
          ..where((r) => r.titleId.equals(titleId))
          ..limit(1))
        .get();

    if (remainingReleases.isNotEmpty) return;

    // 3-1) 타이틀 삭제
    await (db.delete(db.titles)..where((t) => t.id.equals(titleId))).go();
  }

  Future<void> _pruneOrphansAfterMove({
    required int oldEpisodeId,
    required int oldReleaseId,
    required int oldTitleId,
  }) async {
    // (A) 이전 episode에 달린 clip 수
    final countClips = db.clips.id.count();
    final clipsOnOldEpisode = await (db.selectOnly(db.clips)
          ..addColumns([countClips])
          ..where(db.clips.episodeId.equals(oldEpisodeId)))
        .getSingle()
        .then((row) => row.read(countClips) ?? 0);

    if (clipsOnOldEpisode == 0) {
      // episode 삭제
      await (db.delete(db.episodes)..where((e) => e.id.equals(oldEpisodeId)))
          .go();

      // (B) 이전 release에 달린 episode 수
      final countEpisodes = db.episodes.id.count();
      final episodesOnOldRelease = await (db.selectOnly(db.episodes)
            ..addColumns([countEpisodes])
            ..where(db.episodes.releaseId.equals(oldReleaseId)))
          .getSingle()
          .then((row) => row.read(countEpisodes) ?? 0);

      if (episodesOnOldRelease == 0) {
        // release 삭제
        await (db.delete(db.releases)..where((r) => r.id.equals(oldReleaseId)))
            .go();

        // (C) 이전 title에 달린 release 수
        final countReleases = db.releases.id.count();
        final releasesOnOldTitle = await (db.selectOnly(db.releases)
              ..addColumns([countReleases])
              ..where(db.releases.titleId.equals(oldTitleId)))
            .getSingle()
            .then((row) => row.read(countReleases) ?? 0);

        if (releasesOnOldTitle == 0) {
          // title 삭제
          await (db.delete(db.titles)..where((t) => t.id.equals(oldTitleId)))
              .go();
        }
      }
    }
  }

  Future<int> _ensureTitle(String name, String nameNative) async {
    final found = await (db.select(db.titles)
          ..where((t) => t.name.equals(name)))
        .getSingleOrNull();
    if (found != null) {
      // 기존 Title의 원어 작품명이 변경되었으면 업데이트
      if (found.nameNative != nameNative) {
        await (db.update(db.titles)..where((t) => t.id.equals(found.id)))
            .write(TitlesCompanion(nameNative: Value(nameNative)));
      }
      return found.id;
    }

    return db.into(db.titles).insert(
          TitlesCompanion.insert(
            name: name,
            nameNative: nameNative,
          ),
        );
  }

  Future<int> _ensureRelease({
    required int titleId,
    required String type, // 'season' | 'movie'
    required int? seasonNumber,
  }) async {
    final isMovie = type == 'movie';
    final numberForMovie = 0;

    final q = db.select(db.releases)
      ..where((r) => r.titleId.equals(titleId))
      ..where((r) => r.type.equals(type));

    if (isMovie) {
      q.where((r) => r.number.equals(numberForMovie));
    } else {
      q.where((r) => r.number.equals(seasonNumber!));
    }

    final found = await q.getSingleOrNull();
    if (found != null) return found.id;

    // 없으면 생성
    return db.into(db.releases).insert(
          isMovie
              ? ReleasesCompanion.insert(
                  titleId: titleId,
                  type: 'movie',
                  number: const Value(0),
                )
              : ReleasesCompanion.insert(
                  titleId: titleId,
                  type: 'season',
                  number: Value(seasonNumber!),
                ),
        );
  }

  Future<int> _ensureEpisode({
    required int releaseId,
    required String type, // 'season' | 'movie'
    required int? episodeNumber,
    required String episodeTitle,
  }) async {
    if (type == 'movie') {
      // movie: releaseId 당 1개( number == null )
      final found = await (db.select(db.episodes)
            ..where((e) => e.releaseId.equals(releaseId))
            ..where((e) => e.number.isNull()))
          .getSingleOrNull();

      if (found != null) {
        await (db.update(db.episodes)..where((e) => e.id.equals(found.id)))
            .write(
          EpisodesCompanion(title: Value(episodeTitle)),
        );
        return found.id;
      }

      return db.into(db.episodes).insert(
            EpisodesCompanion.insert(
              releaseId: releaseId,
              number: const Value.absent(),
              title: Value(episodeTitle),
            ),
          );
    } else {
      // season: (releaseId, episodeNumber)로 식별
      final numVal = episodeNumber!;
      final found = await (db.select(db.episodes)
            ..where((e) => e.releaseId.equals(releaseId))
            ..where((e) => e.number.equals(numVal)))
          .getSingleOrNull();

      if (found != null) {
        await (db.update(db.episodes)..where((e) => e.id.equals(found.id)))
            .write(
          EpisodesCompanion(title: Value(episodeTitle)),
        );
        return found.id;
      }

      return db.into(db.episodes).insert(
            EpisodesCompanion.insert(
              releaseId: releaseId,
              number: Value(numVal),
              title: Value(episodeTitle),
            ),
          );
    }
  }

  Future<int> _ensureTag(String name) async {
    final found = await (db.select(db.tags)..where((t) => t.name.equals(name)))
        .getSingleOrNull();
    if (found != null) return found.id;
    return db.into(db.tags).insert(
          TagsCompanion.insert(
            name: name,
          ),
        );
  }
}
