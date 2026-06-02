// ============================================================================
// lib/core/provider/clip_activity_provider.dart
// ============================================================================
//
// [역할]
// 클립 활동 관련 상태 관리 Provider.
// - 클립 수 카운팅
// - 최근 시청 기록 (recent6, logRecent)
// - 컬렉션 목록
// - 랜덤 자막/히어로 클립
//
// [레이어]
// Core Layer > Provider
// ============================================================================

import 'dart:async';
import 'package:drift/drift.dart';
import 'package:flutter/foundation.dart';
import 'package:path_provider/path_provider.dart';
import 'package:video_thumbnail/video_thumbnail.dart';

import 'package:parrokit/data/local/app_database.dart';

/// 클립 활동 관련 상태 관리 Provider.
class ClipActivityProvider extends ChangeNotifier {
  final AppDatabase db;

  ClipActivityProvider(this.db) {
    _initWatchers();
  }

  // ─────────────────────────────────────────────────────────────────
  // State
  // ─────────────────────────────────────────────────────────────────

  /// HeroCard용 상태 (clipId, imageBytes?, clipTitle?, collectionName?)
  (int, Uint8List?, String?, String?)? heroClip;
  bool loadingHero = false;

  /// 이어보기 (clipId, thumbnail, clipTitle, collectionName)
  List<(int, Uint8List?, String?, String?)> recent6 = const [];

  /// 콜렉션 (collectionId, name, clipCount)  — third field kept as String? for compat
  List<(int, String, String?, int)> collections = const [];

  /// 헤더 카운트
  int clipCount = 0;

  /// 로딩 플래그
  bool isCounting = true;
  bool isLoadingRecents = true;
  bool isLoadingCollections = true;

  /// 헤더 인트로(애니) 노출 여부
  bool headerIntroShown = false;

  /// 랜덤 자막
  List<Segment> randomSegments = const [];
  bool loadingRandom = false;

  void markHeaderIntroShown() {
    if (!headerIntroShown) {
      headerIntroShown = true;
      notifyListeners();
    }
  }

  // ─────────────────────────────────────────────────────────────────
  // Public API
  // ─────────────────────────────────────────────────────────────────

  /// 최근 본 클립 기록
  Future<void> logRecent(int clipId, {bool prune = false}) async {
    await db.transaction(() async {
      await db.customUpdate(
        '''
      INSERT INTO recent_clip_views(clip_id, last_seq)
      VALUES(?, COALESCE((SELECT MAX(last_seq)+1 FROM recent_clip_views), 1))
      ON CONFLICT(clip_id) DO UPDATE SET
        last_seq = COALESCE((SELECT MAX(last_seq)+1 FROM recent_clip_views), 1);
      ''',
        variables: [Variable.withInt(clipId)],
        updates: {db.recentClipViews},
      );

      if (prune) {
        await db.customUpdate(
          '''
        DELETE FROM recent_clip_views
        WHERE last_seq < (
          SELECT MIN(last_seq) FROM (
            SELECT last_seq
            FROM recent_clip_views
            ORDER BY last_seq DESC
            LIMIT 100
          )
        )
        AND (SELECT COUNT(*) FROM recent_clip_views) > 100;
        ''',
          updates: {db.recentClipViews},
        );
      }
    });
  }

  /// 썸네일 캐시 무효화
  void invalidateThumb(int clipId) {
    _thumbCache.remove(clipId);
  }

  // ─────────────────────────────────────────────────────────────────
  // Internals: Streams
  // ─────────────────────────────────────────────────────────────────

  StreamSubscription<List<QueryRow>>? _countSub;
  StreamSubscription<List<QueryRow>>? _collectionsSub;
  StreamSubscription<List<QueryRow>>? _recentsSub;

  final _thumbCache = <int, Uint8List?>{};
  String? _docRoot;

  Future<String> _ensureDocRoot() async {
    if (_docRoot != null) return _docRoot!;
    final dir = await getApplicationDocumentsDirectory();
    _docRoot = dir.path;
    return _docRoot!;
  }

  void _initWatchers() {
    // 1) clipCount 자동 갱신
    _countSub = db
        .customSelect(
          'SELECT COUNT(*) AS cnt FROM clips;',
          readsFrom: {db.clips},
        )
        .watch()
        .listen((rows) {
          final cnt =
              rows.isNotEmpty ? (rows.first.data['cnt'] as int? ?? 0) : 0;
          clipCount = cnt;
          isCounting = false;
          notifyListeners();
        });

    // 2) collections 자동 갱신 (collections 테이블 기준 집계)
    _collectionsSub = db
        .customSelect(r'''
SELECT
  col.id          AS cid,
  col.name        AS colName,
  COUNT(c.id)     AS clipCount
FROM collections col
LEFT JOIN clips c ON c.collection_id = col.id
GROUP BY col.id
ORDER BY col.name;
''', readsFrom: {db.collections, db.clips})
        .watch()
        .listen((rows) {
          collections = rows
              .map<(int, String, String?, int)>((row) => (
                    row.data['cid'] as int,
                    (row.data['colName'] as String?) ?? '',
                    null,
                    (row.data['clipCount'] as int?) ?? 0,
                  ))
              .toList();
          isLoadingCollections = false;
          notifyListeners();
        });

    // 3) recent6 자동 갱신
    _recentsSub = db
        .customSelect(r'''
SELECT
  rc.clip_id    AS clipId,
  c.title       AS clipTitle,
  c.file_path   AS filePath,
  col.name      AS collectionName
FROM recent_clip_views rc
JOIN clips c ON c.id = rc.clip_id
LEFT JOIN collections col ON col.id = c.collection_id
ORDER BY rc.last_seq DESC
LIMIT 6;
''', readsFrom: {
          db.recentClipViews,
          db.clips,
          db.collections,
        })
        .watch()
        .listen((rows) {
          _rebuildRecents(rows);
        });
  }

  bool _buildingRecents = false;

  Future<void> _rebuildRecents(List<QueryRow> rows) async {
    if (_buildingRecents) return;
    _buildingRecents = true;
    try {
      final root = await _ensureDocRoot();
      final result = <(int, Uint8List?, String?, String?)>[];

      for (final row in rows) {
        final clipId = (row.data['clipId'] as int?) ?? 0;
        final clipTitle = row.data['clipTitle'] as String?;
        final filePath = (row.data['filePath'] as String?) ?? '';
        final collectionName = row.data['collectionName'] as String?;

        Uint8List? thumb = _thumbCache[clipId];
        if (thumb == null) {
          final absPath = '$root/$filePath';
          try {
            thumb = await VideoThumbnail.thumbnailData(
              video: absPath,
              imageFormat: ImageFormat.JPEG,
              maxWidth: 512,
              quality: 75,
              timeMs: 1000,
            );
          } catch (_) {
            thumb = null;
          }
          _thumbCache[clipId] = thumb;
        }

        result.add((clipId, thumb, clipTitle, collectionName));
      }

      recent6 = result;
      isLoadingRecents = false;
      notifyListeners();
    } finally {
      _buildingRecents = false;
    }
  }

  /// 랜덤 세그먼트 가져오기
  Future<List<Segment>> getRandomSegments() async {
    final countRow = await db.customSelect(
      'SELECT COUNT(*) AS c FROM segments',
      readsFrom: {db.segments},
    ).getSingle();

    final total = countRow.data['c'] as int? ?? 0;
    if (total == 0) return [];

    final limit = total < 10 ? total : 10;

    final q = (db.select(db.segments)
      ..orderBy([
        (tbl) => OrderingTerm(expression: const CustomExpression('RANDOM()')),
      ])
      ..limit(limit));

    return q.get();
  }

  Future<void> refreshRandomSegments() async {
    if (loadingRandom) return;
    loadingRandom = true;
    notifyListeners();

    try {
      randomSegments = await getRandomSegments();
    } finally {
      loadingRandom = false;
      notifyListeners();
    }
  }

  /// 랜덤 클립 + 컬렉션 이름
  Future<List<(int, Uint8List?, String?, String?)>> _getRandomClipsWithTitle({
    int count = 10,
  }) async {
    final countRow = await db.customSelect(
      '''
      SELECT COUNT(*) AS c
      FROM clips c
      WHERE EXISTS (SELECT 1 FROM segments s WHERE s.clip_id = c.id)
      ''',
      readsFrom: {db.clips, db.segments},
    ).getSingle();

    final total = (countRow.data['c'] as int?) ?? 0;
    if (total == 0) return const [];

    final limit = total < count ? total : count;

    final rows = await db.customSelect(
      '''
      SELECT
        c.id          AS clip_id,
        c.title       AS clip_title,
        col.name      AS collection_name
      FROM clips c
      LEFT JOIN collections col ON col.id = c.collection_id
      WHERE EXISTS (SELECT 1 FROM segments s WHERE s.clip_id = c.id)
      ORDER BY RANDOM()
      LIMIT ?
      ''',
      variables: [Variable<int>(limit)],
      readsFrom: {db.clips, db.collections, db.segments},
    ).get();

    return rows.map<(int, Uint8List?, String?, String?)>((r) {
      final clipId = r.data['clip_id'] as int;
      final clipTitle = r.data['clip_title'] as String?;
      final collectionName = r.data['collection_name'] as String?;
      return (clipId, null, clipTitle, collectionName);
    }).toList();
  }

  /// 랜덤 히어로 클립 1개 뽑기
  Future<void> refreshRandomHeroClip() async {
    if (loadingHero) return;
    loadingHero = true;
    notifyListeners();

    try {
      final list = await _getRandomClipsWithTitle(count: 1);
      heroClip = list.isNotEmpty ? list.first : null;
    } finally {
      loadingHero = false;
      notifyListeners();
    }
  }

  /// 최근 클립 목록 가져오기 (limit 지정 가능)
  Future<List<(int, Uint8List?, String?, String?)>> fetchRecentClips({
    int limit = 100,
    bool refreshThumb = false,
  }) async {
    final rows = await db.customSelect(
      '''
    SELECT
      rc.clip_id    AS clipId,
      c.title       AS clipTitle,
      c.file_path   AS filePath,
      col.name      AS collectionName
    FROM recent_clip_views rc
    JOIN clips c ON c.id = rc.clip_id
    LEFT JOIN collections col ON col.id = c.collection_id
    ORDER BY rc.last_seq DESC
    LIMIT ?
    ''',
      variables: [Variable<int>(limit)],
      readsFrom: {
        db.recentClipViews,
        db.clips,
        db.collections,
      },
    ).get();

    if (rows.isEmpty) return const [];

    final root = await _ensureDocRoot();
    final result = <(int, Uint8List?, String?, String?)>[];

    for (final row in rows) {
      final clipId = (row.data['clipId'] as int?) ?? 0;
      final clipTitle = row.data['clipTitle'] as String?;
      final filePath = (row.data['filePath'] as String?) ?? '';
      final collectionName = row.data['collectionName'] as String?;

      Uint8List? thumb;
      if (!refreshThumb && _thumbCache.containsKey(clipId)) {
        thumb = _thumbCache[clipId];
      } else {
        final absPath = filePath.startsWith('/') ? filePath : '$root/$filePath';
        try {
          thumb = await VideoThumbnail.thumbnailData(
            video: absPath,
            imageFormat: ImageFormat.JPEG,
            maxWidth: 512,
            quality: 75,
            timeMs: 1000,
          );
        } catch (_) {
          thumb = null;
        }
        _thumbCache[clipId] = thumb;
      }

      result.add((clipId, thumb, clipTitle, collectionName));
    }

    return result;
  }

  // ─────────────────────────────────────────────────────────────────
  // Cleanup
  // ─────────────────────────────────────────────────────────────────

  @override
  void dispose() {
    _countSub?.cancel();
    _collectionsSub?.cancel();
    _recentsSub?.cancel();
    super.dispose();
  }
}
