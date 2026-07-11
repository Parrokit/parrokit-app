// ============================================================================
// lib/core/collection_media/data/datasources/clip_detail_query_datasource.dart
// ============================================================================
//
// [역할]
// 클립의 세그먼트/태그 이름 목록을 조회하는 소규모 공용 datasource.
// server Firestore 메타데이터와 gdrive metadata.json 빌더 양쪽에서 똑같이
// 필요해서 별도로 분리했습니다.
//
// [레이어]
// Core > Collection Media > Data > Datasources
// ============================================================================

import 'package:drift/drift.dart';

import 'package:parrokit/data/local/app_database.dart';

class ClipDetailQueryDatasource {
  final AppDatabase db;

  ClipDetailQueryDatasource(this.db);

  Future<List<Segment>> segmentsForClip(int clipId) {
    return (db.select(db.segments)
          ..where((s) => s.clipId.equals(clipId))
          ..orderBy([(s) => OrderingTerm.asc(s.startMs)]))
        .get();
  }

  Future<List<String>> tagNamesForClip(int clipId) async {
    final rows = await (db.select(db.tags).join([
      innerJoin(
        db.clipTags,
        db.clipTags.tagId.equalsExp(db.tags.id),
      ),
    ])
          ..where(db.clipTags.clipId.equals(clipId)))
        .get();

    return rows
        .map((row) => row.readTable(db.tags).name)
        .where((name) => name.isNotEmpty)
        .toSet()
        .toList()
      ..sort();
  }
}
