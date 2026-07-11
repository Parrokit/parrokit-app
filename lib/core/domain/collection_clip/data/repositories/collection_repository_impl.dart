// ============================================================================
// lib/core/collection_media/data/repositories/collection_repository_impl.dart
// ============================================================================
//
// [역할]
// CollectionRepository 구현체. Collections는 storageMode 컬럼으로 이미
// 저장위치별로 독립돼 있으므로, 그 컬럼으로 직접 필터링합니다. 클립이
// 하나도 없는 갓 생성된 콜렉션도 storageMode만 맞으면 항상 보여야 합니다
// (클립 visibility를 거쳐 콜렉션 visibility를 계산하던 예전 방식은 빈
// 콜렉션이 렌더링되지 않는 버그의 원인이었습니다).
//
// [레이어]
// Core > Collection Media > Data > Repositories
// ============================================================================

import 'package:drift/drift.dart';

import 'package:parrokit/data/local/app_database.dart';
import 'package:parrokit/core/domain/collection_clip/domain/repositories/collection_repository.dart';

class CollectionRepositoryImpl implements CollectionRepository {
  final AppDatabase db;

  CollectionRepositoryImpl(this.db);

  @override
  Future<List<Collection>> getVisibleCollectionsForGroup(
    int? groupId,
    String storageMode,
  ) async {
    List<Collection> rows;
    if (groupId == null) {
      final query = db.select(db.collections).join([
        leftOuterJoin(
          db.groupCollections,
          db.groupCollections.collectionId.equalsExp(db.collections.id),
        ),
      ])
        ..where(
          db.groupCollections.groupId.isNull() &
              db.collections.storageMode.equals(storageMode),
        );
      final joined = await query.get();
      rows = joined.map((r) => r.readTable(db.collections)).toList();
    } else if (groupId == -1) {
      rows = await (db.select(db.collections)
            ..where((c) => c.storageMode.equals(storageMode)))
          .get();
    } else {
      final query = db.select(db.collections).join([
        innerJoin(
          db.groupCollections,
          db.groupCollections.collectionId.equalsExp(db.collections.id),
        ),
      ])
        ..where(
          db.groupCollections.groupId.equals(groupId) &
              db.collections.storageMode.equals(storageMode),
        );
      final joined = await query.get();
      rows = joined.map((r) => r.readTable(db.collections)).toList();
    }

    rows.sort((a, b) => a.name.compareTo(b.name));
    return rows;
  }

  @override
  Future<List<Collection>> getAllVisibleCollections(String storageMode) async {
    return (db.select(db.collections)
          ..where((c) => c.storageMode.equals(storageMode))
          ..orderBy([(c) => OrderingTerm.asc(c.name)]))
        .get();
  }
}
