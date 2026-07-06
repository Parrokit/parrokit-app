import 'package:drift/drift.dart';
import 'collections.dart';

class Clips extends Table {
  IntColumn get id => integer().autoIncrement()();
  IntColumn get collectionId =>
      integer().nullable().references(Collections, #id)();
  TextColumn get title => text()(); // 영상 제목
  TextColumn get filePath => text()(); // 로컬 파일 경로
  TextColumn get remoteId => text().nullable()(); // Firestore 문서 ID
  TextColumn get storageMode =>
      text().withDefault(const Constant('local'))(); // local/server/cloud
  IntColumn get storageBytes =>
      integer().withDefault(const Constant(0))(); // 저장 파일 크기(bytes)
  IntColumn get durationMs => integer()(); // 전체 길이(ms)
  TextColumn get syncStatus =>
      text().withDefault(const Constant('pending'))(); // pending/synced/error
  DateTimeColumn get lastSyncedAt => dateTime().nullable()(); // 최종 동기화 시각
}
