import 'dart:io';

import 'package:drift/drift.dart';
import 'package:path_provider/path_provider.dart';

import '../app_database.dart';

/// Schema Version 2 -> 3 마이그레이션
/// - Groups 테이블 생성
/// - 다대다 매핑을 위한 GroupCollections 테이블 생성
/// - clip 원본/캐시 스키마 생성
Future<void> migrateV2ToV3(Migrator m, AppDatabase db) async {
  await m.createTable(db.groups);
  await m.createTable(db.groupCollections);
  await m.createTable(db.clipSourceRefs);
  await m.createTable(db.clipCacheEntries);

  await m.addColumn(db.clips, db.clips.sourceFilePath);
  await m.addColumn(db.clips, db.clips.storageMode);
  await m.addColumn(db.clips, db.clips.storageBytes);
  await m.addColumn(db.clips, db.clips.ownerScope);
  await m.addColumn(db.clips, db.clips.ownerKey);

  await db.customStatement(
    """
    UPDATE clips
    SET source_file_path = file_path,
        storage_mode = 'local',
        owner_scope = 'device',
        owner_key = NULL
    """,
  );

  final dir = await getApplicationDocumentsDirectory();
  final clips = await db.select(db.clips).get();
  for (final clip in clips) {
    final path = clip.filePath.startsWith('/')
        ? clip.filePath
        : '${dir.path}/${clip.filePath}';
    final file = File(path);
    final bytes = await file.exists() ? await file.length() : 0;
    await (db.update(db.clips)..where((c) => c.id.equals(clip.id))).write(
      ClipsCompanion(storageBytes: Value(bytes)),
    );
  }
}
