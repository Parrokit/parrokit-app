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
}

LazyDatabase _open() => LazyDatabase(() async {
      final dir = await getApplicationDocumentsDirectory();
      final file = File(p.join(dir.path, 'app.db'));
      return NativeDatabase.createInBackground(file);
    });
