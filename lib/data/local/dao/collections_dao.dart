import 'package:drift/drift.dart';
import '../app_database.dart';
import '../tables/collections.dart';
import '../tables/clips.dart';
import '../tables/segments.dart';
import '../tables/tags.dart';
import '../tables/clip_tags.dart';
import '../tables/recent_clip_views.dart';

part 'collections_dao.g.dart';

@DriftAccessor(tables: [Collections, Clips, Segments, Tags, ClipTags, RecentClipViews])
class CollectionsDao extends DatabaseAccessor<AppDatabase>
    with _$CollectionsDaoMixin {
  CollectionsDao(super.db);

  // All collections
  Future<List<Collection>> fetchAll() => select(collections).get();
  Stream<List<Collection>> watchAll() => select(collections).watch();

  // Find or create collection by (name, storageMode)
  Future<Collection> findOrCreate(String name, String storageMode) async {
    final existing = await (select(collections)
          ..where(
            (c) => c.name.equals(name) & c.storageMode.equals(storageMode),
          )
          ..limit(1))
        .getSingleOrNull();
    if (existing != null) return existing;
    final id = await into(collections).insert(
      CollectionsCompanion.insert(name: name, storageMode: Value(storageMode)),
    );
    return (select(collections)..where((c) => c.id.equals(id))).getSingle();
  }

  // Collection names for a given storageMode (for autocomplete)
  Future<List<String>> fetchAllNames(String storageMode) async {
    final rows = await (select(collections)
          ..where((c) => c.storageMode.equals(storageMode)))
        .get();
    return rows.map((c) => c.name).toList();
  }

  // Delete collection if it has no clips
  Future<void> pruneIfEmpty(int collectionId) async {
    final clips = await (select(db.clips)
          ..where((c) => c.collectionId.equals(collectionId)))
        .get();
    if (clips.isEmpty) {
      await (delete(collections)..where((c) => c.id.equals(collectionId))).go();
    }
  }
}
