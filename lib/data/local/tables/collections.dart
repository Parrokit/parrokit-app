import 'package:drift/drift.dart';
import 'groups.dart';

class Collections extends Table {
  IntColumn get id => integer().autoIncrement()();
  IntColumn get groupId => integer().nullable().references(Groups, #id)();
  TextColumn get name => text()();
}
