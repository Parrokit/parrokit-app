// Drift DB 엔진 & schemaVersion

// lib/data/local/pa_database.dart
import 'dart:io';
import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'tables/titles.dart';
import 'tables/releases.dart';
import 'tables/episodes.dart';
import 'tables/clips.dart';
import 'tables/segments.dart';
import 'tables/tags.dart';
import 'tables/clip_tags.dart';
import 'tables/recent_clip_views.dart';

part 'pa_database.g.dart';

@DriftDatabase(tables: [
  Titles,
  Releases,
  Episodes,
  Clips,
  Segments,
  Tags,
  ClipTags,
  RecentClipViews,
])
class PaDatabase extends _$PaDatabase {
  PaDatabase() : super(_open());

  @override
  int get schemaVersion => 1;
}

LazyDatabase _open() => LazyDatabase(() async {
      final dir = await getApplicationDocumentsDirectory();
      final file = File(p.join(dir.path, 'paro.db'));
      return NativeDatabase.createInBackground(file);
    });
