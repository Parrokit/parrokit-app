// ============================================================================
// lib/core/collection_media/data/datasources/collection_group_mirror_datasource.dart
// ============================================================================
//
// [역할]
// 클립이 다른 저장위치로 이동할 때, 속해있던 콜렉션을 목적지 저장위치에도
// 이름 기준으로 자동 매칭/생성하는 datasource. 목적지에 같은 이름의
// 콜렉션이 있으면 재사용하고, 없으면 새로 만듭니다. 그룹은 저장위치별로
// 완전히 독립된 개념이라 이동을 따라가지 않습니다 — 목적지 탭에서 새로
// 그룹에 넣어야 합니다.
//
// [레이어]
// Core > Collection Media > Data > Datasources
// ============================================================================

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
    return destCollection.id;
  }
}
