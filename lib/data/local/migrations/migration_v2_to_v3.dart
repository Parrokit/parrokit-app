import 'package:drift/drift.dart';
import '../app_database.dart';

/// Schema Version 2 -> 3 마이그레이션
/// - Groups 테이블 생성
/// - Collections 테이블에 groupId 필드 추가
Future<void> migrateV2ToV3(Migrator m, AppDatabase db) async {
  await m.createTable(db.groups);
  await m.addColumn(db.collections, db.collections.groupId);
}
