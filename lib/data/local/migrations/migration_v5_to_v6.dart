import 'package:drift/drift.dart';

import '../app_database.dart';

/// Schema Version 5 -> 6 마이그레이션
/// - collections / clips 테이블에 서버 동기화 메타데이터 추가
/// - 기존 데이터는 모두 pending 상태로 둬서 초기 backfill 대상이 되게 함
Future<void> migrateV5ToV6(Migrator m, AppDatabase db) async {
  await m.addColumn(db.collections, db.collections.remoteId);
  await m.addColumn(db.collections, db.collections.syncStatus);
  await m.addColumn(db.collections, db.collections.lastSyncedAt);

  await m.addColumn(db.clips, db.clips.remoteId);
  await m.addColumn(db.clips, db.clips.syncStatus);
  await m.addColumn(db.clips, db.clips.lastSyncedAt);

  await db.customStatement(
    "UPDATE collections SET sync_status = 'pending' "
    "WHERE sync_status IS NULL OR sync_status = ''",
  );
  await db.customStatement(
    "UPDATE clips SET sync_status = 'pending' "
    "WHERE sync_status IS NULL OR sync_status = ''",
  );
}
