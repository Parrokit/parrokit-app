import 'package:drift/drift.dart';
import '../app_database.dart';
import '../tables/groups.dart';

part 'groups_dao.g.dart';

@DriftAccessor(tables: [Groups])
class GroupsDao extends DatabaseAccessor<AppDatabase> with _$GroupsDaoMixin {
  GroupsDao(super.db);

  Future<List<Group>> getAllGroups() =>
      (select(groups)..orderBy([(g) => OrderingTerm.asc(g.name)])).get();

  Future<int> insertGroup(String name) =>
      into(groups).insert(GroupsCompanion.insert(name: name));

  Future<void> deleteGroupById(int id) =>
      (delete(groups)..where((g) => g.id.equals(id))).go();
}
