import 'package:drift/drift.dart';

import '../app_database.dart';

/// Schema Version 3 -> 4 마이그레이션
/// - Groups/Collections에 storageMode 컬럼 추가
/// - 기존에 로컬/서버/gdrive 클립이 섞여 있던 콜렉션을 storageMode별로 분리
///   (같은 이름의 콜렉션/그룹을 목적지 storageMode에서 찾거나 새로 만들고,
///   그 모드의 클립들을 재배정)
Future<void> migrateV3ToV4(Migrator m, AppDatabase db) async {
  await m.addColumn(db.groups, db.groups.storageMode);
  await m.addColumn(db.collections, db.collections.storageMode);

  final collections = await db.select(db.collections).get();
  final emptiedCollectionIds = <int>{};

  for (final collection in collections) {
    final clipsInCollection = await (db.select(db.clips)
          ..where((c) => c.collectionId.equals(collection.id)))
        .get();
    if (clipsInCollection.isEmpty) continue;

    final distinctModes = clipsInCollection.map((c) => c.storageMode).toSet();
    if (distinctModes.length == 1 && distinctModes.single == 'local') {
      continue;
    }

    for (final mode in distinctModes.where((mode) => mode != 'local')) {
      final destCollectionId =
          await _findOrCreateCollection(db, collection.name, mode);

      await (db.update(db.clips)
            ..where(
              (c) =>
                  c.collectionId.equals(collection.id) &
                  c.storageMode.equals(mode),
            ))
          .write(ClipsCompanion(collectionId: Value(destCollectionId)));

      final groupLinks = await (db.select(db.groupCollections)
            ..where((gc) => gc.collectionId.equals(collection.id)))
          .get();
      for (final link in groupLinks) {
        final sourceGroup = await (db.select(db.groups)
              ..where((g) => g.id.equals(link.groupId))
              ..limit(1))
            .getSingleOrNull();
        if (sourceGroup == null) continue;

        final destGroupId =
            await _findOrCreateGroup(db, sourceGroup.name, mode);
        await db.into(db.groupCollections).insert(
              GroupCollectionsCompanion.insert(
                groupId: destGroupId,
                collectionId: destCollectionId,
              ),
              mode: InsertMode.insertOrIgnore,
            );
      }
    }

    final remaining = await (db.select(db.clips)
          ..where((c) => c.collectionId.equals(collection.id)))
        .get();
    if (remaining.isEmpty) {
      emptiedCollectionIds.add(collection.id);
    }
  }

  if (emptiedCollectionIds.isNotEmpty) {
    await (db.delete(db.groupCollections)
          ..where((gc) => gc.collectionId.isIn(emptiedCollectionIds)))
        .go();
    await (db.delete(db.collections)
          ..where((c) => c.id.isIn(emptiedCollectionIds)))
        .go();
  }
}

Future<int> _findOrCreateCollection(
  AppDatabase db,
  String name,
  String storageMode,
) async {
  final existing = await (db.select(db.collections)
        ..where(
          (c) => c.name.equals(name) & c.storageMode.equals(storageMode),
        )
        ..limit(1))
      .getSingleOrNull();
  if (existing != null) return existing.id;
  return db.into(db.collections).insert(
        CollectionsCompanion.insert(
          name: name,
          storageMode: Value(storageMode),
        ),
      );
}

Future<int> _findOrCreateGroup(
  AppDatabase db,
  String name,
  String storageMode,
) async {
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
