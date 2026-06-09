// ============================================================================
// lib/core/provider/media_provider.dart
// ============================================================================
//
// [역할]
// 미디어 데이터 조회 및 선택 상태 관리 (Collection -> Clip)
//
// [레이어]
// Core > Provider
// ============================================================================

import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:path_provider/path_provider.dart';
import 'package:video_thumbnail/video_thumbnail.dart';
import '../../../data/local/app_database.dart';
import 'package:drift/drift.dart';
import '../../../data/models/clip_view.dart';
import '../../../../data/models/clip_item.dart';

import 'package:parrokit/core/infrastructure/services/media_service.dart';
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

  List<Group> groups = [];
  @override
  int? selectedGroupId;

  List<Collection> collections = [];
  @override
  int? selectedCollectionId;

  List<ClipItem> clipItems = [];
  List<Clip> clips = [];
  Map<int, List<Tag>> tagsByClip = {};

  // ─────────────────────────────────────────────────────────────────
  // Methods
  // ─────────────────────────────────────────────────────────────────

  Future<ClipView?> fetchClipById(int clipId) async {
    return _service.fetchClipById(clipId);
  }

  /// 모든 그룹 로드.
  @override
  Future<void> loadGroups() async {
    groups = await _service.getAllGroups();
    
    // 초기화
    selectedGroupId = null;
    selectedCollectionId = null;
    collections = [];
    clips = [];
    clipItems = [];
    tagsByClip = {};
    notifyListeners();
  }

  /// 그룹 선택. 그룹에 속한 컬렉션 목록을 불러옵니다.
  /// id가 null이면 소속 그룹이 없는 최상위 컬렉션을 불러옵니다.
  @override
  Future<void> selectGroup(int? id) async {
    selectedGroupId = id;
    selectedCollectionId = null;
    clips = [];
    clipItems = [];
    tagsByClip = {};

    if (id == null) {
      collections = await (db.select(db.collections)
            ..where((c) => c.groupId.isNull())
            ..orderBy([(c) => OrderingTerm.asc(c.name)]))
          .get();
    } else if (id == -1) {
      collections = await (db.select(db.collections)
            ..orderBy([(c) => OrderingTerm.asc(c.name)]))
          .get();
    } else {
      collections = await (db.select(db.collections)
            ..where((c) => c.groupId.equals(id))
            ..orderBy([(c) => OrderingTerm.asc(c.name)]))
          .get();
    }
    notifyListeners();
  }

  /// 새 그룹 생성 후 목록 갱신.
  Future<void> createGroup(String name) async {
    await _service.createGroup(name);
    await loadGroups();
  }

  /// 그룹 삭제 후 목록 갱신.
  Future<void> deleteGroupById(int id) async {
    await _service.deleteGroupById(id);
    if (selectedGroupId == id) {
      selectedGroupId = null;
    }
    await loadGroups();
  }

  /// 모든 컬렉션 로드 (호환성 또는 필요 시 사용).
  @override
  Future<void> loadCollections() async {
    collections = await (db.select(db.collections)
          ..orderBy([(c) => OrderingTerm.asc(c.name)]))
        .get();
    notifyListeners();
  }

  /// 컬렉션 선택 (null이면 컬렉션 없는 클립 표시).
  @override
  Future<void> selectCollection(int? id) async {
    selectedCollectionId = id;
    clips = [];
    clipItems = [];
    tagsByClip = {};

    if (id == null) {
      clips = await (db.select(db.clips)
            ..where((c) => c.collectionId.isNull())
            ..orderBy([(c) => OrderingTerm.asc(c.id)]))
          .get();
    } else {
      clips = await (db.select(db.clips)
            ..where((c) => c.collectionId.equals(id))
            ..orderBy([(c) => OrderingTerm.asc(c.id)]))
          .get();
    }

    await _buildClipItems();
    notifyListeners();
  }

  /// 컬렉션 내 클립 수 조회.
  Future<int> countClipsInCollection(int collectionId) async {
    final rows = await (db.select(db.clips)
          ..where((c) => c.collectionId.equals(collectionId)))
        .get();
    return rows.length;
  }

  /// 새 컬렉션 생성 후 목록 갱신.
  Future<void> createCollection(String name) async {
    final int? targetGroupId = selectedGroupId == -1 ? null : selectedGroupId;
    await db.into(db.collections).insert(
      CollectionsCompanion.insert(name: name, groupId: Value(targetGroupId)),
    );
    await selectGroup(selectedGroupId); // 현재 그룹의 컬렉션 다시 불러오기
  }

  /// 그룹으로 돌아감 (선택한 컬렉션 해제)
  void backToCollections() {
    selectedCollectionId = null;
    clips = [];
    clipItems = [];
    tagsByClip = {};
    notifyListeners();
  }

  /// 라이브러리 루트(그룹 목록)로 돌아감
  void backToGroups() {
    selectedGroupId = null;
    selectedCollectionId = null;
    collections = [];
    clips = [];
    clipItems = [];
    tagsByClip = {};
    loadGroups();
  }

  // ─────────────────────────────────────────────────────────────────
  // Internal helpers
  // ─────────────────────────────────────────────────────────────────

  Future<void> _buildClipItems() async {
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

    // ClipItem 구성 (segments + thumbnail)
    clipItems = [];
    for (final c in clips) {
      final segments = await (db.select(db.segments)
            ..where((s) => s.clipId.equals(c.id))
            ..orderBy([(s) => OrderingTerm.asc(s.startMs)]))
          .get();

      final dir = await getApplicationDocumentsDirectory();
      final absPath =
          c.filePath.startsWith('/') ? c.filePath : '${dir.path}/${c.filePath}';

      Uint8List? thumbBytes;
      try {
        thumbBytes = await VideoThumbnail.thumbnailData(
          video: absPath,
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
  }

}
