// ============================================================================
// lib/core/provider/media_provider.dart
// ============================================================================
//
// [역할]
// 미디어 데이터 조회 및 선택 상태 관리 (Title -> Release -> Episode -> Clip)
//
// [레이어]
// Core > Provider
// ============================================================================

import 'dart:async';

import 'package:flutter/foundation.dart';
// app_logger not used here
import 'package:path_provider/path_provider.dart';
import 'package:video_thumbnail/video_thumbnail.dart';
import '../../data/local/app_database.dart';
import 'package:drift/drift.dart';
import '../../data/models/clip_view.dart';
import '../../../data/models/clip_item.dart';

import 'package:parrokit/core/services/media_service.dart';
import 'mixins/media_tag_mixin.dart';
import 'mixins/media_action_mixin.dart';

class MediaProvider extends ChangeNotifier
    with MediaTagMixin, MediaActionMixin {
  @override
  final AppDatabase db;
  late final MediaService _service;

  @override
  MediaService get service => _service;

  MediaProvider(this.db) {
    _service = MediaService(db);
  }

  // ─────────────────────────────────────────────────────────────────
  // State
  // ─────────────────────────────────────────────────────────────────

  List<Title> titles = [];
  List<Release> releases = [];
  List<Episode> episodes = [];
  List<ClipItem> clipItems = [];

  @override
  int? selectedTitleId;
  @override
  int? selectedReleaseId;
  @override
  int? selectedEpisodeId;

  List<Clip> clips = [];
  Map<int, List<Tag>> tagsByClip = {};

  // MediaTagMixin handles distinctTags

  // ─────────────────────────────────────────────────────────────────
  // Methods
  // ─────────────────────────────────────────────────────────────────

  Future<ClipView?> fetchClipById(int clipId) async {
    return _service.fetchClipById(clipId);
  }

  // MediaActionMixin implements deleteClipById

  @override
  Future<void> loadTitles() async {
    titles = await (db.select(db.titles)
          ..orderBy([(t) => OrderingTerm.asc(t.name)]))
        .get();
    selectedTitleId = null;
    selectedReleaseId = null;
    releases = [];
    episodes = [];
    notifyListeners();
  }

  /// title 선택.
  @override
  Future<void> selectTitle(int titleId) async {
    selectedTitleId = titleId;

    releases = await (db.select(db.releases)
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

  /// release 선택.
  @override
  Future<void> selectRelease(int releaseId) async {
    selectedReleaseId = releaseId;
    selectedEpisodeId = null;
    clips = [];
    tagsByClip = {};

    episodes = await (db.select(db.episodes)
          ..where((e) => e.releaseId.equals(releaseId))
          ..orderBy([(e) => OrderingTerm.asc(e.number)]))
        .get();
    notifyListeners();
  }

  /// episode 선택.
  @override
  Future<void> selectEpisode(int episodeId) async {
    selectedEpisodeId = episodeId;

    // 클립 목록
    clips = await (db.select(db.clips)
          ..where((e) => e.episodeId.equals(episodeId))
          ..orderBy([(c) => OrderingTerm.asc(c.id)]))
        .get();

    // 태그 매핑
    tagsByClip = {};
    if (clips.isNotEmpty) {
      final clipIds = clips.map((c) => c.id).toList();
      final jt = db.clipTags;
      final rows = await (db.select(db.tags).join([
        innerJoin(jt, jt.tagId.equalsExp(db.tags.id)),
      ])
            ..where(jt.clipId.isIn(clipIds)))
          .get();

      for (final row in rows) {
        final tag = row.readTable(db.tags);
        final ct = row.readTable(jt);
        tagsByClip.putIfAbsent(ct.clipId, () => []).add(tag);
      }
    }

    // ✅ ClipItem에 segments + thumbnail까지 넣어서 구성
    clipItems = [];
    for (final c in clips) {
      final segments = await (db.select(db.segments)
            ..where((s) => s.clipId.equals(c.id))
            ..orderBy([(s) => OrderingTerm.asc(s.startMs)]))
          .get();

      final dir = await getApplicationDocumentsDirectory();
      final absPath =
          c.filePath.startsWith('/') ? c.filePath : '${dir.path}/${c.filePath}';
      // clipAbs removed - absPath used directly below

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

  /// titles 화면으로 돌아감.
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

  /// releases 화면으로 돌아감.
  void backToReleases() {
    selectedReleaseId = null;
    selectedEpisodeId = null;

    episodes = [];
    clips = [];
    tagsByClip = {};

    notifyListeners();
  }

  /// episodes 화면으로 돌아감.
  void backToEpisodes() {
    selectedEpisodeId = null;

    clips = [];
    tagsByClip = {};

    notifyListeners();
  }
}
