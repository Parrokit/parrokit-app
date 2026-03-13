// Drift DB 엔진 & schemaVersion

// lib/data/local/app_database.dart
import 'dart:io';
import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'tables/collections.dart';
import 'tables/clips.dart';
import 'tables/segments.dart';
import 'tables/tags.dart';
import 'tables/clip_tags.dart';
import 'tables/recent_clip_views.dart';

import 'dao/collections_dao.dart';

part 'app_database.g.dart';

@DriftDatabase(
  tables: [
    Collections,
    Clips,
    Segments,
    Tags,
    ClipTags,
    RecentClipViews,
  ],
  daos: [
    CollectionsDao,
  ],
)
class AppDatabase extends _$AppDatabase {
  AppDatabase() : super(_open());

  @override
  int get schemaVersion => 2;

  // @override
  // MigrationStrategy get migration => MigrationStrategy(
  //       onUpgrade: (m, from, to) async {
  //         await m.recreateAllViews();
  //         // 스키마 변경 시 기존 데이터를 초기화합니다.
  //         // (개발 중 DB 구조가 바뀌어 호환되지 않는 경우)
  //         for (final table in allTables) {
  //           await m.deleteTable(table.actualTableName);
  //           await m.createTable(table);
  //         }
  //       },
  //     );
}

LazyDatabase _open() => LazyDatabase(() async {
      final dir = await getApplicationDocumentsDirectory();
      final file = File(p.join(dir.path, 'app.db'));
      return NativeDatabase.createInBackground(file);
    });
