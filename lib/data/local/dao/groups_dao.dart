import 'package:drift/drift.dart';
import '../app_database.dart';
import '../tables/groups.dart';

part 'groups_dao.g.dart';

@DriftAccessor(tables: [Groups])
class GroupsDao extends DatabaseAccessor<AppDatabase> with _$GroupsDaoMixin {
  GroupsDao(super.db);

  Future<List<Group>> getAllGroups(String storageMode) => (select(groups)
        ..where((g) => g.storageMode.equals(storageMode))
        ..orderBy([(g) => OrderingTerm.asc(g.name)]))
      .get();

  Future<int> insertGroup(String name, String storageMode) => into(groups)
      .insert(GroupsCompanion.insert(name: name, storageMode: Value(storageMode)));

  Future<void> deleteGroupById(int id) =>
      (delete(groups)..where((g) => g.id.equals(id))).go();
}
