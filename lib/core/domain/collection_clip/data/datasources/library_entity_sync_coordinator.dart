// ============================================================================
// lib/core/collection_media/data/datasources/library_entity_sync_coordinator.dart
// ============================================================================
//
// [역할]
// 그룹/콜렉션 생성·이름변경·삭제·pull 진입점에서 로컬 DB 반영과 원격
// (서버/클라우드) 동기화를 한 번에 처리하는 조정자. storageMode가
// local이면 원격 호출 없이 로컬만 갱신합니다.
//
// collection_group_mirror_datasource.dart와는 역할이 다릅니다 — 그쪽은
// "클립이 이동할 때 콜렉션을 이름으로 매칭"하는 것이고, 이쪽은 "그룹/
// 콜렉션 자체의 CRUD를 원격에 반영"하는 것입니다. 클립 이동/pull 시
// 그룹 정보는 여전히 사용하지 않는다는 기존 설계는 그대로 유지됩니다.
//
// [레이어]
// Core > Collection Media > Data > Datasources
// ============================================================================

import 'package:firebase_auth/firebase_auth.dart' as fb;
import 'package:drift/drift.dart';

import 'package:parrokit/data/local/app_database.dart';
import 'package:parrokit/core/domain/collection_clip/data/constants/clip_storage_constants.dart';
import 'library_entity_remote_sync_datasource.dart';
import 'remote_doc_id_resolver.dart';

class LibraryEntitySyncCoordinator {
  final AppDatabase db;
  final LibraryEntityRemoteSyncDatasource remoteSyncDatasource;
  final RemoteDocIdResolver remoteDocIdResolver;

  LibraryEntitySyncCoordinator(
    this.db,
    this.remoteSyncDatasource,
    this.remoteDocIdResolver,
  );

  static const _kindGroups = 'groups';
  static const _kindCollections = 'collections';

  // ─────────────────────────────────────────────────────────────────
  // Create
  // ─────────────────────────────────────────────────────────────────

  Future<Group> createGroup(String name, String storageMode) async {
    final remoteId = _needsRemoteId(storageMode) ? remoteDocIdResolver.newClipDocId() : null;
    final id = await db.groupsDao.insertGroup(name, storageMode, remoteId: remoteId);
    if (remoteId != null) {
      await _upsertRemoteEntity(
        storageMode: storageMode,
        kind: _kindGroups,
        remoteId: remoteId,
        fields: {'name': name},
      );
    }
    return (await db.groupsDao.findById(id))!;
  }

  Future<Collection> createCollection(
    String name,
    String storageMode, {
    List<int> groupIds = const [],
  }) async {
    final remoteId = _needsRemoteId(storageMode) ? remoteDocIdResolver.newClipDocId() : null;
    final id = await db.into(db.collections).insert(
          CollectionsCompanion.insert(
            name: name,
            storageMode: Value(storageMode),
            remoteId: Value(remoteId),
          ),
        );
    if (remoteId != null) {
      final groupRemoteIds = await _remoteIdsForGroups(groupIds);
      await _upsertRemoteEntity(
        storageMode: storageMode,
        kind: _kindCollections,
        remoteId: remoteId,
        fields: {
          'name': name,
          if (groupRemoteIds.isNotEmpty) 'groupRemoteIds': groupRemoteIds,
        },
      );
    }
    return (await db.collectionsDao.findById(id))!;
  }

  // ─────────────────────────────────────────────────────────────────
  // Rename
  // ─────────────────────────────────────────────────────────────────

  Future<void> renameGroup(int id, String newName) async {
    final group = await db.groupsDao.findById(id);
    if (group == null) return;
    await db.groupsDao.updateName(id, newName);
    final remoteId = group.remoteId;
    if (remoteId != null) {
      await _upsertRemoteEntity(
        storageMode: group.storageMode,
        kind: _kindGroups,
        remoteId: remoteId,
        fields: {'name': newName},
      );
    }
  }

  Future<void> renameCollection(int id, String newName) async {
    final collection = await db.collectionsDao.findById(id);
    if (collection == null) return;
    await db.collectionsDao.updateName(id, newName);
    final remoteId = collection.remoteId;
    if (remoteId != null) {
      final groupRemoteIds = await _remoteIdsForGroups(await _groupIdsForCollection(id));
      await _upsertRemoteEntity(
        storageMode: collection.storageMode,
        kind: _kindCollections,
        remoteId: remoteId,
        fields: {
          'name': newName,
          if (groupRemoteIds.isNotEmpty) 'groupRemoteIds': groupRemoteIds,
        },
      );
    }
  }

  // ─────────────────────────────────────────────────────────────────
  // Delete (원격 삭제만 담당 — 로컬 삭제는 기존 호출부가 그대로 수행)
  // ─────────────────────────────────────────────────────────────────

  Future<void> deleteGroup(int id) async {
    final group = await db.groupsDao.findById(id);
    final remoteId = group?.remoteId;
    if (group == null || remoteId == null) return;
    await _deleteRemoteEntity(
      storageMode: group.storageMode,
      kind: _kindGroups,
      remoteId: remoteId,
    );
  }

  Future<void> deleteCollection(int id) async {
    final collection = await db.collectionsDao.findById(id);
    final remoteId = collection?.remoteId;
    if (collection == null || remoteId == null) return;
    await _deleteRemoteEntity(
      storageMode: collection.storageMode,
      kind: _kindCollections,
      remoteId: remoteId,
    );
  }

  // ─────────────────────────────────────────────────────────────────
  // Pull (다른 기기가 만든 빈 그룹/콜렉션도 로컬로 당겨오기)
  // ─────────────────────────────────────────────────────────────────

  /// 반환값은 이번 pull로 로컬에 새로 생긴 그룹/콜렉션 개수입니다 (이미
  /// 있던 걸 remoteId만 붙여 "입양"한 경우는 세지 않음 — 목록에 새로
  /// 보일 게 없으므로 UI 새로고침을 유발할 필요가 없음).
  Future<int> pullServer(String uid) async {
    final groupDocs = await remoteSyncDatasource.listServerEntities(uid: uid, kind: _kindGroups);
    final collectionDocs =
        await remoteSyncDatasource.listServerEntities(uid: uid, kind: _kindCollections);
    return _pullGroupsAndCollections(
      storageMode: ClipStorageConstants.storageModeServer,
      groupEntities: {for (final e in groupDocs) e.key: e.value},
      collectionEntities: {for (final e in collectionDocs) e.key: e.value},
    );
  }

  Future<int> pullCloud() async {
    final groupEntities = await remoteSyncDatasource.listCloudEntities(_kindGroups);
    final collectionEntities = await remoteSyncDatasource.listCloudEntities(_kindCollections);
    return _pullGroupsAndCollections(
      storageMode: ClipStorageConstants.storageModeGoogleDrive,
      groupEntities: groupEntities,
      collectionEntities: collectionEntities,
    );
  }

  Future<int> _pullGroupsAndCollections({
    required String storageMode,
    required Map<String, Map<String, dynamic>> groupEntities,
    required Map<String, Map<String, dynamic>> collectionEntities,
  }) async {
    var createdCount = 0;
    final remoteIdToLocalGroupId = <String, int>{};
    for (final entry in groupEntities.entries) {
      final name = entry.value['name'] as String?;
      if (name == null || name.trim().isEmpty) continue;
      final (localId, created) = await _adoptOrCreateGroup(
        remoteId: entry.key,
        name: name.trim(),
        storageMode: storageMode,
      );
      remoteIdToLocalGroupId[entry.key] = localId;
      if (created) createdCount++;
    }

    for (final entry in collectionEntities.entries) {
      final name = entry.value['name'] as String?;
      if (name == null || name.trim().isEmpty) continue;
      final (localCollectionId, created) = await _adoptOrCreateCollection(
        remoteId: entry.key,
        name: name.trim(),
        storageMode: storageMode,
      );
      if (created) createdCount++;
      final groupRemoteIds =
          (entry.value['groupRemoteIds'] as List?)?.whereType<String>() ?? const [];
      for (final groupRemoteId in groupRemoteIds) {
        final localGroupId = remoteIdToLocalGroupId[groupRemoteId];
        if (localGroupId == null) continue;
        await db.into(db.groupCollections).insert(
              GroupCollectionsCompanion.insert(
                groupId: localGroupId,
                collectionId: localCollectionId,
              ),
              mode: InsertMode.insertOrIgnore,
            );
      }
    }
    return createdCount;
  }

  Future<(int, bool)> _adoptOrCreateGroup({
    required String remoteId,
    required String name,
    required String storageMode,
  }) async {
    final byRemoteId = await db.groupsDao.findByRemoteId(remoteId);
    if (byRemoteId != null) return (byRemoteId.id, false);

    final unsynced = await db.groupsDao.findByNameAndStorageMode(name, storageMode);
    if (unsynced != null && unsynced.remoteId == null) {
      await db.groupsDao.updateRemoteId(unsynced.id, remoteId);
      return (unsynced.id, false);
    }

    final id = await db.groupsDao.insertGroup(name, storageMode, remoteId: remoteId);
    return (id, true);
  }

  Future<(int, bool)> _adoptOrCreateCollection({
    required String remoteId,
    required String name,
    required String storageMode,
  }) async {
    final byRemoteId = await db.collectionsDao.findByRemoteId(remoteId);
    if (byRemoteId != null) return (byRemoteId.id, false);

    final unsynced = await db.collectionsDao.findByNameAndStorageMode(name, storageMode);
    if (unsynced != null && unsynced.remoteId == null) {
      await db.collectionsDao.updateRemoteId(unsynced.id, remoteId);
      return (unsynced.id, false);
    }

    final id = await db.into(db.collections).insert(
          CollectionsCompanion.insert(
            name: name,
            storageMode: Value(storageMode),
            remoteId: Value(remoteId),
          ),
        );
    return (id, true);
  }

  // ─────────────────────────────────────────────────────────────────
  // Helpers
  // ─────────────────────────────────────────────────────────────────

  bool _needsRemoteId(String storageMode) =>
      storageMode == ClipStorageConstants.storageModeServer ||
      storageMode == ClipStorageConstants.storageModeGoogleDrive;

  Future<void> _upsertRemoteEntity({
    required String storageMode,
    required String kind,
    required String remoteId,
    required Map<String, dynamic> fields,
  }) async {
    if (storageMode == ClipStorageConstants.storageModeServer) {
      final uid = fb.FirebaseAuth.instance.currentUser?.uid;
      if (uid == null) return;
      await remoteSyncDatasource.upsertServerEntity(
        uid: uid,
        kind: kind,
        remoteId: remoteId,
        fields: fields,
      );
    } else if (storageMode == ClipStorageConstants.storageModeGoogleDrive) {
      await remoteSyncDatasource.upsertCloudEntity(
        kind: kind,
        remoteId: remoteId,
        fields: fields,
      );
    }
  }

  Future<void> _deleteRemoteEntity({
    required String storageMode,
    required String kind,
    required String remoteId,
  }) async {
    if (storageMode == ClipStorageConstants.storageModeServer) {
      final uid = fb.FirebaseAuth.instance.currentUser?.uid;
      if (uid == null) return;
      await remoteSyncDatasource.deleteServerEntity(uid: uid, kind: kind, remoteId: remoteId);
    } else if (storageMode == ClipStorageConstants.storageModeGoogleDrive) {
      await remoteSyncDatasource.deleteCloudEntity(kind: kind, remoteId: remoteId);
    }
  }

  Future<List<String>> _remoteIdsForGroups(List<int> groupIds) async {
    final remoteIds = <String>[];
    for (final id in groupIds) {
      final group = await db.groupsDao.findById(id);
      final remoteId = group?.remoteId;
      if (remoteId != null) remoteIds.add(remoteId);
    }
    return remoteIds;
  }

  Future<List<int>> _groupIdsForCollection(int collectionId) async {
    final rows = await (db.select(db.groupCollections)
          ..where((gc) => gc.collectionId.equals(collectionId)))
        .get();
    return rows.map((r) => r.groupId).toList();
  }
}
