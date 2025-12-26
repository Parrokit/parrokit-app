// ============================================================================
// lib/core/provider/mixins/media_action_mixin.dart
// ============================================================================
//
// [역할]
// 미디어 CRUD 및 액션 로직 분리 (Mixin)
//
// [레이어]
// Core > Provider > Mixins
// ============================================================================

import 'package:flutter/foundation.dart';
import '../../../../data/local/app_database.dart';
import '../../services/media_service.dart';

mixin MediaActionMixin on ChangeNotifier {
  AppDatabase get db;
  MediaService get service;

  // Navigation / Refresh required methods
  int? get selectedTitleId;
  int? get selectedReleaseId;
  int? get selectedEpisodeId;

  Future<void> selectTitle(int id);
  Future<void> selectRelease(int id);
  Future<void> selectEpisode(int id);
  Future<void> loadTitles();

  // ─────────────────────────────────────────────────────────────────
  // Actions
  // ─────────────────────────────────────────────────────────────────

  Future<bool> deleteClipById(int clipId) async {
    final success = await service.deleteClipById(clipId);
    if (!success) return false;

    // ===== 뷰 리프레시 (기존 로직 유지) =====
    if (selectedEpisodeId != null) {
      final existsEp = await (db.select(db.episodes)
            ..where((e) => e.id.equals(selectedEpisodeId!))
            ..limit(1))
          .getSingleOrNull();
      if (existsEp != null) {
        await selectEpisode(selectedEpisodeId!);
        return true;
      }
      if (selectedReleaseId != null) {
        final existsRel = await (db.select(db.releases)
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
      final existsTitle = await (db.select(db.titles)
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
    await service.addMedia(
      titleName: titleName,
      titleNameNative: titleNameNative,
      type: type,
      seasonNumber: seasonNumber,
      episodeNumber: episodeNumber,
      episodeTitle: episodeTitle,
      clipTitle: clipTitle,
      filePath: filePath,
      durationMs: durationMs,
      segments: segments,
      tags: tags,
    );
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
    await service.updateMedia(
      clipId: clipId,
      titleName: titleName,
      titleNameNative: titleNameNative,
      type: type,
      seasonNumber: seasonNumber,
      episodeNumber: episodeNumber,
      episodeTitle: episodeTitle,
      clipTitle: clipTitle,
      filePath: filePath,
      durationMs: durationMs,
      segments: segments,
      tags: tags,
    );
  }
}
