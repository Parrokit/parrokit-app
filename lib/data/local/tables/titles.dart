import 'package:drift/drift.dart';

class Titles extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get name => text()();
  TextColumn get nameNative => text()();
}