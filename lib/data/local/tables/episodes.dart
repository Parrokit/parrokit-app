import 'package:drift/drift.dart';
import 'releases.dart';

class Episodes extends Table {
  IntColumn get id => integer().autoIncrement()();
  IntColumn get releaseId => integer().references(Releases, #id)();
  IntColumn get number => integer().nullable()(); // 회차 (moivie일 경우 null)
  TextColumn get title => text().nullable()();               // 에피소드 제목
}
