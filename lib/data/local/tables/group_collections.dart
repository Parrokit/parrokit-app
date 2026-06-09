import 'package:drift/drift.dart';
import 'groups.dart';
import 'collections.dart';

class GroupCollections extends Table {
  IntColumn get groupId => integer().references(Groups, #id)();
  IntColumn get collectionId => integer().references(Collections, #id)();

  @override
  Set<Column> get primaryKey => {groupId, collectionId};
}
