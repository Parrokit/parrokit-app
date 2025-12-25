// lib/provider/dashboard_ui_provider.dart
import 'dart:async';
import 'dart:typed_data';
import 'package:drift/drift.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:video_thumbnail/video_thumbnail.dart';

import 'package:parrokit/data/local/pa_database.dart';

class DashboardUiProvider extends ChangeNotifier {
  final PaDatabase pdb;

  DashboardUiProvider(this.pdb) {
    _initWatchers(); // ✅ 생성 시 한 번만 스트림 연결
  }

  // ---------------- State ----------------
  /// ⬇️ HeroCard용 상태
  (
    int,
    Uint8List?,
    String?,
    String?
  )? heroClip; // (clipId, imageBytes?, clipTitle?, titleName?)
  bool loadingHero = false;

  /// 이어보기 (clipId, thumbnail, clipTitle, titleName)
  List<(int, Uint8List?, String?, String?)> recent6 = const [];

  /// 콜렉션 (titleId, titleKo, titleJa, clipCount)
  List<(int, String, String?, int)> collections = const [];

  /// 헤더 카운트
  int clipCount = 0;

  /// 로딩 플래그 (초기 구독 중/첫 수신 전)
  bool isCounting = true;
  bool isLoadingRecents = true;
  bool isLoadingCollections = true;

  /// 헤더 인트로(애니) 노출 여부
  bool headerIntroShown = false;

  List<Segment> randomSegments = const [];
  bool loadingRandom = false;

  void markHeaderIntroShown() {
    if (!headerIntroShown) {
      headerIntroShown = true;
      notifyListeners();
    }
  }

  // ---------------- Public API ----------------
  /// 최근 본 클립 기록 (watcher가 자동 반영)
  Future<void> logRecent(int clipId, {bool prune = false}) async {
    await pdb.transaction(() async {
      // 1) UPSERT: 최근 시청 순서 증가
      await pdb.customUpdate(
        '''
      INSERT INTO recent_clip_views(clip_id, last_seq)
      VALUES(?, COALESCE((SELECT MAX(last_seq)+1 FROM recent_clip_views), 1))
      ON CONFLICT(clip_id) DO UPDATE SET
        last_seq = COALESCE((SELECT MAX(last_seq)+1 FROM recent_clip_views), 1);
      ''',
        variables: [Variable.withInt(clipId)],
        // 🔑 Drift에게 "이 테이블이 바뀌었어"라고 알려줌
        updates: {pdb.recentClipViews},
      );

      // 2) (옵션) 오래된 로그 정리
      if (prune) {
        await pdb.customUpdate(
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
          updates: {pdb.recentClipViews},
        );
      }
    });
    // 별도 refresh/notify 불필요: watch()들이 자동으로 재쿼리됨
  }

  /// 썸네일 캐시 무효화 (파일 경로 바꼈을 때 등)
  void invalidateThumb(int clipId) {
    _thumbCache.remove(clipId);
  }

  // ---------------- Internals: Streams ----------------
  StreamSubscription<List<QueryRow>>? _countSub;
  StreamSubscription<List<QueryRow>>? _collectionsSub;
  StreamSubscription<List<QueryRow>>? _recentsSub;

  final _thumbCache = <int, Uint8List?>{}; // clipId → 썸네일
  String? _docRoot;

  Future<String> _ensureDocRoot() async {
    if (_docRoot != null) return _docRoot!;
    final dir = await getApplicationDocumentsDirectory();
    _docRoot = dir.path;
    return _docRoot!;
  }

  void _initWatchers() {
    // 1) clipCount 자동 갱신
    _countSub = pdb
        .customSelect(
          'SELECT COUNT(*) AS cnt FROM clips;',
          readsFrom: {pdb.clips},
        )
        .watch()
        .listen((rows) {
          final cnt =
              rows.isNotEmpty ? (rows.first.data['cnt'] as int? ?? 0) : 0;
          clipCount = cnt;
          isCounting = false;
          notifyListeners();
        });

    // 2) collections 자동 갱신 (titles 기준 집계)
    _collectionsSub = pdb
        .customSelect(r'''
SELECT 
  t.id              AS tid,
  t.name            AS nameKo,
  t.name_native     AS nameOriginal,
  COUNT(c.id)       AS clipCount
FROM titles t
LEFT JOIN releases r ON r.title_id   = t.id
LEFT JOIN episodes e ON e.release_id = r.id
LEFT JOIN clips    c ON c.episode_id = e.id
GROUP BY t.id
ORDER BY t.name;
''', readsFrom: {pdb.titles, pdb.releases, pdb.episodes, pdb.clips})
        .watch()
        .listen((rows) {
          collections = rows
              .map<(int, String, String?, int)>((row) => (
                    row.data['tid'] as int,
                    (row.data['nameKo'] as String?) ?? '',
                    row.data['nameOriginal'] as String?,
                    (row.data['clipCount'] as int?) ?? 0,
                  ))
              .toList();
          isLoadingCollections = false;
          notifyListeners();
        });

    // 3) recent6 자동 갱신 (N+1 제거한 JOIN)
    _recentsSub = pdb
        .customSelect(r'''
SELECT 
  rc.clip_id   AS clipId,
  c.title      AS clipTitle,
  c.file_path  AS filePath,
  t.name       AS titleName
FROM recent_clip_views rc
JOIN clips    c ON c.id = rc.clip_id
LEFT JOIN episodes e ON e.id = c.episode_id
LEFT JOIN releases r ON r.id = e.release_id
LEFT JOIN titles   t ON t.id = r.title_id
ORDER BY rc.last_seq DESC
LIMIT 6;
''', readsFrom: {
          pdb.recentClipViews,
          pdb.clips,
          pdb.episodes,
          pdb.releases,
          pdb.titles,
        })
        .watch()
        .listen((rows) {
          _rebuildRecents(rows); // 썸네일 포함 비동기 재구성
        });
  }

  bool _buildingRecents = false;

  Future<void> _rebuildRecents(List<QueryRow> rows) async {
    if (_buildingRecents) return; // 중복 호출 방지
    _buildingRecents = true;
    try {
      final root = await _ensureDocRoot();
      final result = <(int, Uint8List?, String?, String?)>[];

      for (final row in rows) {
        final clipId = (row.data['clipId'] as int?) ?? 0;
        final clipTitle = row.data['clipTitle'] as String?;
        final filePath = (row.data['filePath'] as String?) ?? '';
        final titleName = row.data['titleName'] as String?;

        // 썸네일 캐시
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

        result.add((clipId, thumb, clipTitle, titleName));
      }

      recent6 = result;
      isLoadingRecents = false;
      notifyListeners();
    } finally {
      _buildingRecents = false;
    }
  }

  /// 프로바이더 관리 X
  Future<List<Segment>> getRandomSegments() async {
    // 1) 전체 개수 조회
    final countExp = const CustomExpression<int>('COUNT(*)');
    final countRow = await pdb.customSelect(
      'SELECT COUNT(*) AS c FROM segments',
      readsFrom: {pdb.segments},
    ).getSingle();

    final total = countRow.data['c'] as int? ?? 0;
    if (total == 0) return [];

    // 2) limit = min(10, total)
    final limit = total < 10 ? total : 10;

    // 3) 랜덤으로 limit개 가져오기
    final q = (pdb.select(pdb.segments)
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

// 랜덤 클립 + 작품 제목 (episode → release → title)
// segments가 1개 이상 존재하는 clip만 대상

  Future<List<(int, Uint8List?, String?, String?)>> _getRandomClipsWithTitle({
    int count = 10,
  }) async {
    // 세그먼트가 있는 클립만 대상
    final countRow = await pdb.customSelect(
      '''
      SELECT COUNT(*) AS c
      FROM clips c
      WHERE EXISTS (SELECT 1 FROM segments s WHERE s.clip_id = c.id)
      ''',
      readsFrom: {pdb.clips, pdb.segments},
    ).getSingle();

    final total = (countRow.data['c'] as int?) ?? 0;
    if (total == 0) return const [];

    final limit = total < count ? total : count;

    final rows = await pdb.customSelect(
      '''
      SELECT
        c.id     AS clip_id,
        c.title  AS clip_title,
        t.name   AS title_name
      FROM clips c
      JOIN episodes e ON e.id = c.episode_id
      JOIN releases r ON r.id = e.release_id
      JOIN titles   t ON t.id = r.title_id
      WHERE EXISTS (SELECT 1 FROM segments s WHERE s.clip_id = c.id)
      ORDER BY RANDOM()
      LIMIT ?
      ''',
      variables: [Variable<int>(limit)],
      readsFrom: {
        pdb.clips,
        pdb.episodes,
        pdb.releases,
        pdb.titles,
        pdb.segments
      },
    ).get();

    return rows.map<(int, Uint8List?, String?, String?)>((r) {
      final clipId = r.data['clip_id'] as int;
      final clipTitle = r.data['clip_title'] as String?;
      final titleName = r.data['title_name'] as String?;
      return (clipId, null, clipTitle, titleName);
    }).toList();
  }

  // 랜덤 클립 + 타이틀 1개 뽑기
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

  Future<List<(int, Uint8List?, String?, String?)>> fetchRecentClips({
    int limit = 100,
    bool refreshThumb = false,
  }) async {
    // 1) recent_clip_views 기준으로 JOIN하여 메타 조회
    final rows = await pdb.customSelect(
      '''
    SELECT 
      rc.clip_id   AS clipId,
      c.title      AS clipTitle,
      c.file_path  AS filePath,
      t.name       AS titleName
    FROM recent_clip_views rc
    JOIN clips    c ON c.id = rc.clip_id
    LEFT JOIN episodes e ON e.id = c.episode_id
    LEFT JOIN releases r ON r.id = e.release_id
    LEFT JOIN titles   t ON t.id = r.title_id
    ORDER BY rc.last_seq DESC
    LIMIT ?
    ''',
      variables: [Variable<int>(limit)],
      readsFrom: {
        pdb.recentClipViews,
        pdb.clips,
        pdb.episodes,
        pdb.releases,
        pdb.titles,
      },
    ).get();

    if (rows.isEmpty) return const [];

    final root = await _ensureDocRoot();
    final result = <(int, Uint8List?, String?, String?)>[];

    for (final row in rows) {
      final clipId = (row.data['clipId'] as int?) ?? 0;
      final clipTitle = row.data['clipTitle'] as String?;
      final filePath = (row.data['filePath'] as String?) ?? '';
      final titleName = row.data['titleName'] as String?;

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

      result.add((clipId, thumb, clipTitle, titleName));
    }

    return result;
  }

  // ---------------- Cleanup ----------------
  @override
  void dispose() {
    _countSub?.cancel();
    _collectionsSub?.cancel();
    _recentsSub?.cancel();
    super.dispose();
  }
}
