import 'package:drift/drift.dart';

import '../app_database.dart';

/// Schema Version 3 -> 4 마이그레이션
/// - clips 테이블에 storageMode 컬럼 추가
/// - 기존 로컬 클립은 local로 표시
Future<void> migrateV3ToV4(Migrator m, AppDatabase db) async {
  await m.addColumn(db.clips, db.clips.storageMode);
  await db.customStatement(
    "UPDATE clips SET storage_mode = 'local' "
    "WHERE storage_mode IS NULL OR storage_mode = ''",
  );
}
