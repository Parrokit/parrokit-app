import 'package:drift/drift.dart';
import 'collections.dart';

class Clips extends Table {
  IntColumn get id => integer().autoIncrement()();
  IntColumn get collectionId =>
      integer().nullable().references(Collections, #id)();
  TextColumn get title => text()();         // 영상 제목
  TextColumn get filePath => text()();      // 로컬 파일 경로
  IntColumn  get durationMs => integer()(); // 전체 길이(ms)
}
