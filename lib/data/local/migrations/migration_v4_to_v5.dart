import 'dart:io';

import 'package:drift/drift.dart';
import 'package:path_provider/path_provider.dart';

import '../app_database.dart';

/// Schema Version 4 -> 5 마이그레이션
/// - clips 테이블에 storageBytes 컬럼 추가
/// - 기존 값은 파일 크기 기준으로 채움
Future<void> migrateV4ToV5(Migrator m, AppDatabase db) async {
  await m.addColumn(db.clips, db.clips.storageBytes);

  final dir = await getApplicationDocumentsDirectory();
  final rows = await db.select(db.clips).get();

  for (final clip in rows) {
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
