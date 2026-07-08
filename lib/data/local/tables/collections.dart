import 'package:drift/drift.dart';

class Collections extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get name => text()();
}
