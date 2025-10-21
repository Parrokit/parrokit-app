// lib/provider/media_provider.dart
import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:parrokit/utils/pa_logger.dart';
import 'package:path_provider/path_provider.dart';
import 'package:video_thumbnail/video_thumbnail.dart';
import '../data/local/pa_database.dart';
import 'package:drift/drift.dart';
import '../data/models/clip_view.dart';
import '../../data/models/clip_item.dart';
import 'dart:io' show File;

class MediaProvider extends ChangeNotifier {
  final PaDatabase pdb;

  MediaProvider(this.pdb);

  List<Title> titles = [];
  List<Release> releases = [];
  List<Episode> episodes = [];
  List<ClipItem> clipItems = [];

  int? selectedTitleId;
  int? selectedReleaseId;
  int? selectedEpisodeId;

  List<Clip> clips = [];
  Map<int, List<Tag>> tagsByClip = {};

  /// 전체 태그
  List<Tag> _distinctTags = [];
  StreamSubscription<List<Tag>>? _tagSub;

  List<Tag> get distinctTags => _distinctTags;

  Future<ClipView?> fetchClipById(int clipId) async {
    final clip = await (pdb.select(pdb.clips)
          ..where((c) => c.id.equals(clipId))
          ..limit(1))
        .getSingleOrNull();
    if (clip == null) return null;

    final segments = await (pdb.select(pdb.segments)
          ..where((s) => s.clipId.equals(clip.id))
          ..orderBy([(s) => OrderingTerm.asc(s.startMs)]))
        .get();

    final abs = await _absolutePathFor(clip.filePath);
    final clipAbs = clip.copyWith(filePath: abs);

    return ClipView(clip: clipAbs, segments: segments);
  }

  Future<bool> deleteClipById(int clipId) async {
    Clip? target;
    try {
      target = await (pdb.select(pdb.clips)
            ..where((c) => c.id.equals(clipId))
            ..limit(1))
          .getSingleOrNull();
      if (target == null) return false;

      await pdb.transaction(() async {
        await (pdb.delete(pdb.segments)..where((s) => s.clipId.equals(clipId)))
            .go();
        await (pdb.delete(pdb.clipTags)
              ..where((ct) => ct.clipId.equals(clipId)))
            .go();
        await (pdb.delete(pdb.clips)..where((c) => c.id.equals(clipId))).go();

        // 상위 구조 고아 정리
        await _cleanupAfterClipDelete(episodeId: target!.episodeId);
      });

      // ✅ 파일 삭제 (절대 경로 보정 후)
      if (target.filePath.isNotEmpty) {
        try {
          final abs = await _absolutePathFor(target.filePath);
          final f = File(abs);
          if (await f.exists()) await f.delete();
        } catch (_) {}
      }

      // ===== 뷰 리프레시 (기존 로직 유지) =====
      if (selectedEpisodeId != null) {
        final existsEp = await (pdb.select(pdb.episodes)
              ..where((e) => e.id.equals(selectedEpisodeId!))
              ..limit(1))
            .getSingleOrNull();
        if (existsEp != null) {
          await selectEpisode(selectedEpisodeId!);
          return true;
        }
        if (selectedReleaseId != null) {
          final existsRel = await (pdb.select(pdb.releases)
                ..where((r) => r.id.equals(selectedReleaseId!))
                ..limit(1))
              .getSingleOrNull();
          if (existsRel != null) {
            await selectRelease(selectedReleaseId!);
            return true;
          }
        }
      }

      if (selectedTitleId != null) {
        final existsTitle = await (pdb.select(pdb.titles)
              ..where((t) => t.id.equals(selectedTitleId!))
              ..limit(1))
            .getSingleOrNull();
        if (existsTitle != null) {
          await selectTitle(selectedTitleId!);
          return true;
        }
      }

      await loadTitles();
      return true;
    } catch (_) {
      return false;
    }
  }

  /// clip 삭제 후 상위에 요소가 하나도 없으면 위로 올라가며 정리
  Future<void> _cleanupAfterClipDelete({
    required int episodeId,
  }) async {
    // 1) 에피소드에 클립이 남았는지 확인
    final remainingClips = await (pdb.select(pdb.clips)
          ..where((c) => c.episodeId.equals(episodeId))
          ..limit(1))
        .get();

    if (remainingClips.isNotEmpty) {
      return; // 아직 클립이 있으니 상위 정리는 불필요
    }

    // 에피소드 정보 가져오기 (릴리즈 ID 필요)
    final ep = await (pdb.select(pdb.episodes)
          ..where((e) => e.id.equals(episodeId))
          ..limit(1))
        .getSingleOrNull();

    if (ep == null) return; // 이미 지워졌으면 끝

    // 1-1) 에피소드 삭제
    await (pdb.delete(pdb.episodes)..where((e) => e.id.equals(episodeId))).go();

    final releaseId = ep.releaseId;

    // 2) 해당 릴리즈에 에피소드가 남았는지 확인
    final remainingEpisodes = await (pdb.select(pdb.episodes)
          ..where((e) => e.releaseId.equals(releaseId))
          ..limit(1))
        .get();

    if (remainingEpisodes.isNotEmpty) {
      return; // 아직 에피소드가 있으니 더 올라가지 않음
    }

    // 릴리즈 정보 가져오기 (타이틀 ID 필요)
    final rel = await (pdb.select(pdb.releases)
          ..where((r) => r.id.equals(releaseId))
          ..limit(1))
        .getSingleOrNull();

    if (rel == null) return;

    // 2-1) 릴리즈 삭제
    await (pdb.delete(pdb.releases)..where((r) => r.id.equals(releaseId))).go();

    final titleId = rel.titleId;

    // 3) 해당 타이틀에 릴리즈가 남았는지 확인
    final remainingReleases = await (pdb.select(pdb.releases)
          ..where((r) => r.titleId.equals(titleId))
          ..limit(1))
        .get();

    if (remainingReleases.isNotEmpty) {
      return; // 아직 릴리즈가 있으니 종료
    }

    // 3-1) 타이틀 삭제
    await (pdb.delete(pdb.titles)..where((t) => t.id.equals(titleId))).go();
  }

  Future<void> loadTitles() async {
    titles = await (pdb.select(pdb.titles)
          ..orderBy([(t) => OrderingTerm.asc(t.name)]))
        .get();
    selectedTitleId = null;
    selectedReleaseId = null;
    releases = [];
    episodes = [];
    notifyListeners();
  }

  /// title 선택
  Future<void> selectTitle(int titleId) async {
    selectedTitleId = titleId;

    releases = await (pdb.select(pdb.releases)
          ..where((r) => r.titleId.equals(titleId))
          ..orderBy([
            (r) => OrderingTerm.desc(r.type),
            (r) => OrderingTerm.asc(r.number),
          ]))
        .get();

    selectedReleaseId = null;
    episodes = [];
    notifyListeners();
  }

  /// release 선택
  Future<void> selectRelease(int releaseId) async {
    selectedReleaseId = releaseId;
    selectedEpisodeId = null;
    clips = [];
    tagsByClip = {};

    episodes = await (pdb.select(pdb.episodes)
          ..where((e) => e.releaseId.equals(releaseId))
          ..orderBy([(e) => OrderingTerm.asc(e.number)]))
        .get();
    notifyListeners();
  }

  /// episode 선택
  Future<void> selectEpisode(int episodeId) async {
    selectedEpisodeId = episodeId;

    // 클립 목록
    clips = await (pdb.select(pdb.clips)
          ..where((e) => e.episodeId.equals(episodeId))
          ..orderBy([(c) => OrderingTerm.asc(c.id)]))
        .get();

    // 태그 매핑
    tagsByClip = {};
    if (clips.isNotEmpty) {
      final clipIds = clips.map((c) => c.id).toList();
      final jt = pdb.clipTags;
      final rows = await (pdb.select(pdb.tags).join([
        innerJoin(jt, jt.tagId.equalsExp(pdb.tags.id)),
      ])
            ..where(jt.clipId.isIn(clipIds)))
          .get();

      for (final row in rows) {
        final tag = row.readTable(pdb.tags);
        final ct = row.readTable(jt);
        tagsByClip.putIfAbsent(ct.clipId, () => []).add(tag);
      }
    }

    // ✅ ClipItem에 segments + thumbnail까지 넣어서 구성
    clipItems = [];
    for (final c in clips) {
      final segments = await (pdb.select(pdb.segments)
            ..where((s) => s.clipId.equals(c.id))
            ..orderBy([(s) => OrderingTerm.asc(s.startMs)]))
          .get();

      final dir = await getApplicationDocumentsDirectory();
      final absPath =
          c.filePath.startsWith('/') ? c.filePath : '${dir.path}/${c.filePath}';
      final clipAbs = c.copyWith(filePath: absPath);

      Uint8List? thumbBytes;
      try {
        thumbBytes = await VideoThumbnail.thumbnailData(
          video: absPath, // ✅ 절대경로 사용
          imageFormat: ImageFormat.JPEG,
          quality: 70,
          timeMs: 500,
        );
      } catch (_) {
        thumbBytes = null;
      }
      clipItems.add(
        ClipItem(
          clip: c,
          tags: tagsByClip[c.id] ?? const [],
          segments: segments,
          thumbnail: thumbBytes,
        ),
      );
    }

    notifyListeners();
  }

  /// titles 화면으로 돌아감
  void backToTitles() {
    selectedTitleId = null;
    selectedReleaseId = null;
    selectedEpisodeId = null;

    releases = [];
    episodes = [];
    clips = [];
    tagsByClip = {};

    notifyListeners();
  }

  /// releases 화면으로 돌아감
  void backToReleases() {
    selectedReleaseId = null;
    selectedEpisodeId = null;

    episodes = [];
    clips = [];
    tagsByClip = {};

    notifyListeners();
  }

  /// episodes 화면으로 돌아감
  void backToEpisodes() {
    selectedEpisodeId = null;

    clips = [];
    tagsByClip = {};

    notifyListeners();
  }

  Future<int> _ensureTitle(String name, String nameNative) async {
    final found = await (pdb.select(pdb.titles)
          ..where((t) => t.name.equals(name)))
        .getSingleOrNull();
    if (found != null) return found.id;

    return pdb.into(pdb.titles).insert(
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

    final q = pdb.select(pdb.releases)
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
    return pdb.into(pdb.releases).insert(
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
      final found = await (pdb.select(pdb.episodes)
            ..where((e) => e.releaseId.equals(releaseId))
            ..where((e) => e.number.isNull()))
          .getSingleOrNull();

      if (found != null) {
        // ✅ 기존 id 유지 + 제목 덮어쓰기
        await (pdb.update(pdb.episodes)..where((e) => e.id.equals(found.id)))
            .write(
          EpisodesCompanion(title: Value(episodeTitle)),
        );
        return found.id;
      }

      // 없으면 새로 생성
      return pdb.into(pdb.episodes).insert(
            EpisodesCompanion.insert(
              releaseId: releaseId,
              number: const Value.absent(),
              title: Value(episodeTitle),
            ),
          );
    } else {
      // season: (releaseId, episodeNumber)로 식별
      final numVal = episodeNumber!;
      final found = await (pdb.select(pdb.episodes)
            ..where((e) => e.releaseId.equals(releaseId))
            ..where((e) => e.number.equals(numVal)))
          .getSingleOrNull();

      if (found != null) {
        // ✅ 기존 id 유지 + 제목 덮어쓰기
        await (pdb.update(pdb.episodes)..where((e) => e.id.equals(found.id)))
            .write(
          EpisodesCompanion(title: Value(episodeTitle)),
        );
        return found.id;
      }

      // 없으면 새로 생성
      return pdb.into(pdb.episodes).insert(
            EpisodesCompanion.insert(
              releaseId: releaseId,
              number: Value(numVal),
              title: Value(episodeTitle),
            ),
          );
    }
  }

  /// 태그가 없으면 만들고 id 반환
  Future<int> _ensureTag(String name) async {
    final found = await (pdb.select(pdb.tags)
          ..where((t) => t.name.equals(name)))
        .getSingleOrNull();
    if (found != null) return found.id;
    return pdb.into(pdb.tags).insert(
          TagsCompanion.insert(
            name: name,
          ),
        );
  }

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
    await pdb.transaction(() async {
      {
        final titleId = await _ensureTitle(titleName, titleNameNative);

        final releaseId = await _ensureRelease(
          titleId: titleId,
          type: type, // 'season' | 'movie'
          seasonNumber: seasonNumber, // season일 때만 의미 있음
        );

        final episodeId = await _ensureEpisode(
          releaseId: releaseId,
          type: type,
          episodeNumber: episodeNumber,
          episodeTitle: episodeTitle,
        );

        final clipId = await pdb.into(pdb.clips).insert(
              ClipsCompanion.insert(
                episodeId: episodeId,
                title: clipTitle,
                filePath: filePath,
                durationMs: durationMs,
              ),
            );

        for (final s in segments) {
          await pdb.into(pdb.segments).insert(
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
            await pdb.into(pdb.clipTags).insert(
                  ClipTagsCompanion.insert(clipId: clipId, tagId: tagId),
                  mode: InsertMode.insertOrIgnore,
                );
          }
        }
      }
    });
  }

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
    await pdb.transaction(() async {
      // 1) 이전 계층 id들 확보
      final prevClip = await (pdb.select(pdb.clips)
            ..where((c) => c.id.equals(clipId)))
          .getSingle();
      final prevEpisode = await (pdb.select(pdb.episodes)
            ..where((e) => e.id.equals(prevClip.episodeId)))
          .getSingle();
      final prevRelease = await (pdb.select(pdb.releases)
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
      await (pdb.update(pdb.clips)..where((c) => c.id.equals(clipId))).write(
        ClipsCompanion(
          episodeId: Value(episodeId),
          title: Value(clipTitle),
          filePath: Value(filePath),
          durationMs: Value(durationMs),
        ),
      );

      // 4) 세그먼트 재작성
      await (pdb.delete(pdb.segments)..where((s) => s.clipId.equals(clipId)))
          .go();
      for (final s in segments) {
        await pdb.into(pdb.segments).insert(
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
        await (pdb.delete(pdb.clipTags)
              ..where((ct) => ct.clipId.equals(clipId)))
            .go();
        for (final name in tags.toSet()) {
          final tagId = await _ensureTag(name);
          await pdb.into(pdb.clipTags).insert(
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

  Future<void> _pruneOrphansAfterMove({
    required int oldEpisodeId,
    required int oldReleaseId,
    required int oldTitleId,
  }) async {
    // (A) 이전 episode에 달린 clip 수
    final countClips = pdb.clips.id.count();
    final clipsOnOldEpisode = await (pdb.selectOnly(pdb.clips)
          ..addColumns([countClips])
          ..where(pdb.clips.episodeId.equals(oldEpisodeId)))
        .getSingle()
        .then((row) => row.read(countClips) ?? 0);

    if (clipsOnOldEpisode == 0) {
      // episode 삭제
      await (pdb.delete(pdb.episodes)..where((e) => e.id.equals(oldEpisodeId)))
          .go();

      // (B) 이전 release에 달린 episode 수
      final countEpisodes = pdb.episodes.id.count();
      final episodesOnOldRelease = await (pdb.selectOnly(pdb.episodes)
            ..addColumns([countEpisodes])
            ..where(pdb.episodes.releaseId.equals(oldReleaseId)))
          .getSingle()
          .then((row) => row.read(countEpisodes) ?? 0);

      if (episodesOnOldRelease == 0) {
        // release 삭제
        await (pdb.delete(pdb.releases)
              ..where((r) => r.id.equals(oldReleaseId)))
            .go();

        // (C) 이전 title에 달린 release 수
        final countReleases = pdb.releases.id.count();
        final releasesOnOldTitle = await (pdb.selectOnly(pdb.releases)
              ..addColumns([countReleases])
              ..where(pdb.releases.titleId.equals(oldTitleId)))
            .getSingle()
            .then((row) => row.read(countReleases) ?? 0);

        if (releasesOnOldTitle == 0) {
          // title 삭제
          await (pdb.delete(pdb.titles)..where((t) => t.id.equals(oldTitleId)))
              .go();
        }
      }
    }
  }

  /// clip.filePath가 상대경로라면 App Documents와 합쳐 절대경로로 변환
  Future<String> _absolutePathFor(String pathFromClip) async {
    // 이미 절대경로면 그대로 반환 (간단 체크)
    if (pathFromClip.startsWith('/')) return pathFromClip;
    // 필요 시 package:path의 isAbsolute 사용 가능
    final dir = await getApplicationDocumentsDirectory();
    return '${dir.path}/$pathFromClip';
  }

  /// DB에 있는 태그를 중복 제거하여 저장, 구독하여 갱신
  Stream<List<Tag>> _distinctTagsStream({bool onlyUsed = false}) {
    if (onlyUsed) {
      final jt = pdb.clipTags;
      final q = pdb.select(pdb.tags).join([
        innerJoin(jt, jt.tagId.equalsExp(pdb.tags.id)),
      ]);

      return q.watch().map((rows) {
        final all = rows.map((r) => r.readTable(pdb.tags)).toList();
        final map = <String, Tag>{};
        for (final t in all) map.putIfAbsent(t.name, () => t);
        final list = map.values.toList()
          ..sort((a, b) => a.name.compareTo(b.name));
        return list;
      });
    } else {
      return (pdb.select(pdb.tags)..orderBy([(t) => OrderingTerm.asc(t.name)]))
          .watch()
          .map((all) {
        final map = <String, Tag>{};
        for (final t in all) map.putIfAbsent(t.name, () => t);
        final list = map.values.toList()
          ..sort((a, b) => a.name.compareTo(b.name));
        return list;
      });
    }
  }

  void startWatchingDistinctTags({bool onlyUsed = false}) {
    _tagSub?.cancel();
    _tagSub = _distinctTagsStream(onlyUsed: onlyUsed).listen((list) {
      _distinctTags = list;
      notifyListeners();
    });
  }

  void stopWatchingDistinctTags() {
    _tagSub?.cancel();
    _tagSub = null;
  }
}
