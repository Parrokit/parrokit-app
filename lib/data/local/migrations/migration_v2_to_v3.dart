import 'package:drift/drift.dart';
import '../app_database.dart';

/// Schema Version 2 -> 3 마이그레이션
/// - Groups 테이블 생성
/// - 다대다 매핑을 위한 GroupCollections 테이블 생성
Future<void> migrateV2ToV3(Migrator m, AppDatabase db) async {
  await m.createTable(db.groups);
  await m.createTable(db.groupCollections);
}
