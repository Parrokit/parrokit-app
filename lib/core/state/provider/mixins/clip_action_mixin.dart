// ============================================================================
// lib/core/state/provider/mixins/clip_action_mixin.dart
// ============================================================================
//
// [역할]
// 클립 CRUD 및 액션 로직 분리 (Mixin)
//
// [레이어]
// Core > State > Provider > Mixins
// ============================================================================

import 'package:flutter/foundation.dart';
import '../../../../../data/local/app_database.dart';
import '../../../infrastructure/services/media_service.dart';

mixin ClipActionMixin on ChangeNotifier {
  AppDatabase get db;
  MediaService get service;

  // Navigation / Refresh required methods
  int? get selectedGroupId;
  int? get selectedCollectionId;

  Future<void> selectGroup(int? id);
  Future<void> selectCollection(int? id);
  Future<void> loadGroups();
  Future<void> loadCollections();

  // ─────────────────────────────────────────────────────────────────
  // Actions
  // ─────────────────────────────────────────────────────────────────

  Future<bool> deleteClipById(int clipId) async {
    final success = await service.deleteClipById(clipId);
    if (!success) return false;

    // Refresh current view
    if (selectedCollectionId != null) {
      final exists = await (db.select(db.collections)
            ..where((c) => c.id.equals(selectedCollectionId!))
            ..limit(1))
          .getSingleOrNull();
      if (exists != null) {
        await selectCollection(selectedCollectionId);
        return true;
      }
    }

    await selectGroup(selectedGroupId);
    return true;
  }

  Future<bool> deleteCollectionById(int collectionId) async {
    final clipsInCol = await (db.select(db.clips)
          ..where((c) => c.collectionId.equals(collectionId)))
        .get();

    for (final clip in clipsInCol) {
      await service.deleteClipById(clip.id);
    }

    await (db.delete(db.collections)..where((c) => c.id.equals(collectionId)))
        .go();

    await selectGroup(selectedGroupId);
    return true;
  }

  Future<void> addClip({
    required String? collectionName,
    required String clipTitle,
    required String filePath,
    required int durationMs,
    required List<Segment> segments,
    required List<String>? tags,
  }) async {
    await service.addMedia(
      collectionName: collectionName,
      clipTitle: clipTitle,
      filePath: filePath,
      durationMs: durationMs,
      segments: segments,
      tags: tags,
    );
  }

  Future<void> updateClip({
    required int clipId,
    required String? collectionName,
    required String clipTitle,
    required String filePath,
    required int durationMs,
    required List<Segment> segments,
    required List<String>? tags,
  }) async {
    await service.updateMedia(
      clipId: clipId,
      collectionName: collectionName,
      clipTitle: clipTitle,
      filePath: filePath,
      durationMs: durationMs,
      segments: segments,
      tags: tags,
    );
  }
}
