// ============================================================================
// lib/core/state/provider/clip_provider.dart
// ============================================================================
//
// [역할]
// 클립 데이터 조회 및 선택 상태 관리 (Collection -> Clip)
//
// [레이어]
// Core > State > Provider
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
import 'package:parrokit/core/infrastructure/services/firebase/collection_sync_service.dart';
import 'mixins/clip_tag_mixin.dart';
import 'mixins/clip_action_mixin.dart';

class ClipProvider extends ChangeNotifier with ClipTagMixin, ClipActionMixin {
  static const int serverStorageQuotaBytes = 1024 * 1024 * 1024;

  @override
  final AppDatabase db;
  late final MediaService _service;
  late final CollectionSyncService _collectionSyncService;

  @override
  MediaService get service => _service;

  ClipProvider(this.db) {
    _service = MediaService(db);
    _collectionSyncService = CollectionSyncService(database: db);
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
  int serverStorageUsedBytes = 0;

  // ─────────────────────────────────────────────────────────────────
  // Methods
  // ─────────────────────────────────────────────────────────────────

  Future<ClipView?> fetchClipById(int clipId) async {
    return _service.fetchClipById(clipId);
  }

  @override
  Future<void> refreshServerStorageUsage() async {
    serverStorageUsedBytes = await _service.getServerStorageUsedBytes();
  }

  /// 현재 로그인 유저의 collection 메타데이터를 Firestore로 동기화합니다.
  Future<void> syncCollectionDataToServer(String uid) async {
    await _collectionSyncService.syncCollectionData(uid: uid);
    notifyListeners();
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
    await refreshServerStorageUsage();
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
      // 그룹이 없는 콜렉션
      final query = db.select(db.collections).join([
        leftOuterJoin(db.groupCollections,
            db.groupCollections.collectionId.equalsExp(db.collections.id))
      ])
        ..where(db.groupCollections.groupId.isNull());

      final rows = await query.get();
      collections = rows.map((r) => r.readTable(db.collections)).toList();
    } else if (id == -1) {
      // 모든 콜렉션
      collections = await (db.select(db.collections)
            ..orderBy([(c) => OrderingTerm.asc(c.name)]))
          .get();
    } else {
      // 특정 그룹의 콜렉션
      final query = db.select(db.collections).join([
        innerJoin(db.groupCollections,
            db.groupCollections.collectionId.equalsExp(db.collections.id))
      ])
        ..where(db.groupCollections.groupId.equals(id));

      final rows = await query.get();
      collections = rows.map((r) => r.readTable(db.collections)).toList();
    }

    collections.sort((a, b) => a.name.compareTo(b.name));
    await refreshServerStorageUsage();
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
    await refreshServerStorageUsage();
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
    await refreshServerStorageUsage();
    notifyListeners();
  }

  /// 컬렉션 내 클립 수 조회.
  Future<int> countClipsInCollection(int collectionId) async {
    final rows = await (db.select(db.clips)
          ..where((c) => c.collectionId.equals(collectionId)))
        .get();
    return rows.length;
  }

  /// 이름 중복 검사 (그룹 및 콜렉션 전체)
  Future<bool> isNameExists(String name) async {
    final groupMatch = await (db.select(db.groups)
          ..where((g) => g.name.equals(name)))
        .getSingleOrNull();
    if (groupMatch != null) return true;

    final collectionMatch = await (db.select(db.collections)
          ..where((c) => c.name.equals(name)))
        .getSingleOrNull();
    return collectionMatch != null;
  }

  /// 새 컬렉션 생성 후 목록 갱신.
  Future<void> createCollection(String name) async {
    final collectionId = await db.into(db.collections).insert(
          CollectionsCompanion.insert(name: name),
        );

    if (selectedGroupId != null && selectedGroupId != -1) {
      await db.into(db.groupCollections).insert(
            GroupCollectionsCompanion.insert(
                groupId: selectedGroupId!, collectionId: collectionId),
          );
    }

    await selectGroup(selectedGroupId); // 현재 그룹의 콜렉션 다시 불러오기
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

  /// 모든 콜렉션 조회 (관리 모달용)
  Future<List<Collection>> fetchAllCollections() async {
    return await (db.select(db.collections)
          ..orderBy([(c) => OrderingTerm.asc(c.name)]))
        .get();
  }

  /// 콜렉션의 매핑된 그룹 ID 목록 조회
  Future<List<int>> getGroupIdsForCollection(int collectionId) async {
    final query = db.select(db.groupCollections)
      ..where((gc) => gc.collectionId.equals(collectionId));
    final rows = await query.get();
    return rows.map((r) => r.groupId).toList();
  }

  /// 특정 그룹의 매핑된 콜렉션 ID 목록 조회
  Future<List<int>> getCollectionIdsForGroup(int groupId) async {
    final query = db.select(db.groupCollections)
      ..where((gc) => gc.groupId.equals(groupId));
    final rows = await query.get();
    return rows.map((r) => r.collectionId).toList();
  }

  /// 특정 콜렉션의 그룹 매핑 업데이트
  Future<void> updateGroupsForCollection(
      int collectionId, List<int> groupIds) async {
    await db.transaction(() async {
      await (db.delete(db.groupCollections)
            ..where((gc) => gc.collectionId.equals(collectionId)))
          .go();
      for (final gid in groupIds) {
        await db.into(db.groupCollections).insert(
              GroupCollectionsCompanion.insert(
                  groupId: gid, collectionId: collectionId),
            );
      }
    });
    // 현재 보고 있는 화면이 갱신되어야 할 수 있음
    await loadGroups();
    await selectGroup(selectedGroupId);
  }

  /// 특정 그룹의 콜렉션 매핑 업데이트
  Future<void> updateCollectionsForGroup(
      int groupId, List<int> collectionIds) async {
    await db.transaction(() async {
      await (db.delete(db.groupCollections)
            ..where((gc) => gc.groupId.equals(groupId)))
          .go();
      for (final cid in collectionIds) {
        await db.into(db.groupCollections).insert(
              GroupCollectionsCompanion.insert(
                  groupId: groupId, collectionId: cid),
            );
      }
    });
    // 현재 보고 있는 화면이 갱신되어야 할 수 있음
    await loadGroups();
    await selectGroup(selectedGroupId);
  }
}
