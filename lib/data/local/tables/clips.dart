import 'package:drift/drift.dart';
import 'collections.dart';

class Clips extends Table {
  IntColumn get id => integer().autoIncrement()();
  IntColumn get collectionId =>
      integer().nullable().references(Collections, #id)();
  TextColumn get title => text()(); // 영상 제목
  TextColumn get filePath => text()(); // 레거시 호환용 경로
  TextColumn get sourceFilePath => text().nullable()(); // 진짜 로컬 원본 경로
  TextColumn get thumbnailFilePath => text().nullable()(); // 로컬 썸네일 경로
  TextColumn get ownerScope => text().withDefault(const Constant('device'))();
  TextColumn get ownerKey => text().nullable()();
  TextColumn get storageMode =>
      text().withDefault(const Constant('local'))(); // local/server/gdrive
  IntColumn get storageBytes =>
      integer().withDefault(const Constant(0))(); // 저장 파일 크기(bytes)
  IntColumn get durationMs => integer()(); // 전체 길이(ms)
}
