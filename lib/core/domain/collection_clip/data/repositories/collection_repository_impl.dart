// ============================================================================
// lib/core/collection_media/data/repositories/collection_repository_impl.dart
// ============================================================================
//
// [역할]
// CollectionRepository 구현체. "보이는 컬렉션"을 계산하려면 클립 가시성
// 정보가 필요하므로 ClipRepository.getVisibleCollectionIds()에 의존합니다
// (가시성 로직을 여기서 복제하지 않습니다 — 중복 구현은 버그의 원인이 됩니다).
//
// [레이어]
// Core > Collection Media > Data > Repositories
// ============================================================================

import 'package:drift/drift.dart';

import 'package:parrokit/data/local/app_database.dart';
import 'package:parrokit/core/domain/collection_clip/domain/repositories/clip_repository.dart';
import 'package:parrokit/core/domain/collection_clip/domain/repositories/collection_repository.dart';

class CollectionRepositoryImpl implements CollectionRepository {
  final AppDatabase db;
  final ClipRepository clipRepository;

  CollectionRepositoryImpl(this.db, this.clipRepository);

  @override
  Future<List<Collection>> getVisibleCollectionsForGroup(
    int? groupId,
    String storageMode,
  ) async {
    final visibleCollectionIds =
        await clipRepository.getVisibleCollectionIds(storageMode);
    if (visibleCollectionIds.isEmpty) return const [];

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
              db.collections.id.isIn(visibleCollectionIds),
        );
      final joined = await query.get();
      rows = joined.map((r) => r.readTable(db.collections)).toList();
    } else if (groupId == -1) {
      rows = await (db.select(db.collections)
            ..where((c) => c.id.isIn(visibleCollectionIds)))
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
              db.collections.id.isIn(visibleCollectionIds),
        );
      final joined = await query.get();
      rows = joined.map((r) => r.readTable(db.collections)).toList();
    }

    rows.sort((a, b) => a.name.compareTo(b.name));
    return rows;
  }

  @override
  Future<List<Collection>> getAllVisibleCollections(String storageMode) async {
    final visibleCollectionIds =
        await clipRepository.getVisibleCollectionIds(storageMode);
    if (visibleCollectionIds.isEmpty) return const [];
    final rows = await (db.select(db.collections)
          ..where((c) => c.id.isIn(visibleCollectionIds))
          ..orderBy([(c) => OrderingTerm.asc(c.name)]))
        .get();
    return rows;
  }
}
