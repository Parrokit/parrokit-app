// ============================================================================
// lib/core/collection_media/data/datasources/collection_group_mirror_datasource.dart
// ============================================================================
//
// [역할]
// 클립이 다른 저장위치로 이동할 때, 속해있던 콜렉션/그룹을 목적지
// 저장위치에도 이름 기준으로 자동 매칭/생성하는 datasource. 목적지에
// 같은 이름의 콜렉션/그룹이 있으면 재사용하고, 없으면 새로 만듭니다.
//
// [레이어]
// Core > Collection Media > Data > Datasources
// ============================================================================

import 'package:drift/drift.dart';

import 'package:parrokit/data/local/app_database.dart';

class CollectionGroupMirrorDatasource {
  final AppDatabase db;

  CollectionGroupMirrorDatasource(this.db);

  /// 클립의 현재 collectionId와 목적지 storageMode를 받아, 목적지에서
  /// 클립이 속해야 할 collectionId를 반환합니다. currentCollectionId가
  /// null이면 그대로 null을 반환합니다.
  Future<int?> mirrorCollectionForClip({
    required int? currentCollectionId,
    required String destinationStorageMode,
  }) async {
    if (currentCollectionId == null) return null;

    final source = await (db.select(db.collections)
          ..where((c) => c.id.equals(currentCollectionId))
          ..limit(1))
        .getSingleOrNull();
    if (source == null) return null;
    if (source.storageMode == destinationStorageMode) return currentCollectionId;

    final destCollection = await db.collectionsDao.findOrCreate(
      source.name,
      destinationStorageMode,
    );

    final groupLinks = await (db.select(db.groupCollections)
          ..where((gc) => gc.collectionId.equals(currentCollectionId)))
        .get();
    for (final link in groupLinks) {
      final sourceGroup = await (db.select(db.groups)
            ..where((g) => g.id.equals(link.groupId))
            ..limit(1))
          .getSingleOrNull();
      if (sourceGroup == null) continue;

      final destGroupId =
          await _findOrCreateGroup(sourceGroup.name, destinationStorageMode);
      await db.into(db.groupCollections).insert(
            GroupCollectionsCompanion.insert(
              groupId: destGroupId,
              collectionId: destCollection.id,
            ),
            mode: InsertMode.insertOrIgnore,
          );
    }

    return destCollection.id;
  }

  Future<int> _findOrCreateGroup(String name, String storageMode) async {
    final existing = await (db.select(db.groups)
          ..where(
            (g) => g.name.equals(name) & g.storageMode.equals(storageMode),
          )
          ..limit(1))
        .getSingleOrNull();
    if (existing != null) return existing.id;
    return db.into(db.groups).insert(
          GroupsCompanion.insert(name: name, storageMode: Value(storageMode)),
        );
  }
}
