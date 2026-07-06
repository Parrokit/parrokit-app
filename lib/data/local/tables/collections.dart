import 'package:drift/drift.dart';

class Collections extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get name => text()();
  TextColumn get remoteId => text().nullable()(); // Firestore 문서 ID
  TextColumn get syncStatus =>
      text().withDefault(const Constant('pending'))(); // pending/synced/error
  DateTimeColumn get lastSyncedAt => dateTime().nullable()(); // 최종 동기화 시각
}
