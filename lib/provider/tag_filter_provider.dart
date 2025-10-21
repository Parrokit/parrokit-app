// lib/provider/tag_filter_provider.dart
import 'dart:async';
import 'dart:collection';
import 'dart:typed_data';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:drift/drift.dart';
import 'package:video_thumbnail/video_thumbnail.dart';
import 'package:path_provider/path_provider.dart';

import '../data/local/pa_database.dart';
import '../../data/models/clip_item.dart';

class TagFilterProvider extends ChangeNotifier {
  final PaDatabase pdb;

  TagFilterProvider(this.pdb);

  /// tagId -> clipIds (OR 집합 계산용 인덱스)
  final Map<int, Set<int>> _tagToClipIds = {};

  /// ClipItem 풀 캐시 (LRU)
  final _cache = LinkedHashMap<int, ClipItem>();
  static const int _maxCacheSize = 400;

  /// 현재 필터 결과 clipIds
  List<int> filteredClipIds = [];

  /// 중복 방지
  final Set<int> _building = {};
  String? _docsPath;


  /// 화면에서 깜빡임 없이 그대로 쓸 데이터/상태
  List<ClipItem> _items = const [];
  bool _isLoading = false;

  ///  결과 세트 버전 (UI 전환 키로 사용)
  int _resultsVersion = 0;
  int get resultsVersion => _resultsVersion;


  List<ClipItem> get items => _items;
  bool get isLoading => _isLoading;

  final Set<String> _activeTagNames = {};

  List<String> get activeTagNames => _activeTagNames.toList();

  final Map<int, ImageProvider> _thumbProviders = {}; // clipId -> provider

  ImageProvider? imageProviderFor(int clipId) => _thumbProviders[clipId];

  /// 디바운스
  Timer? _debounce;

  // scheduleApply에서 디바운스 끝나면 applyNow 호출하도록
  void scheduleApply(VoidCallback mutateFilter) {
    mutateFilter();
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 300), () {
      applyNow(); // ✅ 여기서 결과까지 계산해서 보관
    });
  }

  bool _sameIds(List<ClipItem> a, List<ClipItem> b) {
    if (a.length != b.length) return false;
    for (var i = 0; i < a.length; i++) {
      if (a[i].clip.id != b[i].clip.id) return false;
    }
    return true;
  }

  Future<void> applyNow() async {
    _setLoading(true);
    try {
      final next = await fetchItemsForCurrentFilter();

      // ✅ 결과가 이전과 동일하면 알림/교체 생략
      if (_sameIds(_items, next)) return;

      _items = next;
      _resultsVersion++;

      notifyListeners();
    } finally {
      _setLoading(false);
    }
  }

  void _setLoading(bool v) {
    if (_isLoading == v) return;
    _isLoading = v;
    notifyListeners();
  }
  /// DB 변경 감시 -> 필요한 캐시 무효화
  StreamSubscription? _clipsSub, _segmentsSub, _clipTagsSub;

  Future<void> showAll() async {
    // 모든 clip id 조회
    final rows = await (pdb.select(pdb.clips)
      ..orderBy([(c) => OrderingTerm.asc(c.id)]))
        .get();
    filteredClipIds = rows.map((c) => c.id).toList();
    await applyNow(); // 내부 items까지 채워서 깜빡임 최소화
  }

  Future<void> startWatching() async {
    await _clipsSub?.cancel();
    await _segmentsSub?.cancel();
    await _clipTagsSub?.cancel();

    _clipsSub = (pdb.select(pdb.clips)).watch().listen((rows) {
      final ids = rows.map((e) => e.id).toSet();
      _cache.removeWhere((k, _) => !ids.contains(k));
      notifyListeners(); // OK (1회)
    });



    _segmentsSub = (pdb.select(pdb.segments)).watch().listen((rows) {
      final dirty = <int>{};
      for (final cid in rows.map((s) => s.clipId)) {
        if (_cache.containsKey(cid)) {
          _cache.remove(cid);
          dirty.add(cid);
        }
      }
      if (dirty.isNotEmpty) notifyListeners();
    });

    _clipTagsSub = (pdb.select(pdb.clipTags)).watch().listen((rows) {
      _tagToClipIds.clear();
      final dirty = <int>{};
      for (final ct in rows) {
        (_tagToClipIds[ct.tagId] ??= <int>{}).add(ct.clipId);
        if (_cache.containsKey(ct.clipId)) {
          _cache.remove(ct.clipId);
          dirty.add(ct.clipId);
        }
      }
      if (dirty.isNotEmpty) notifyListeners();
    });

    if (_activeTagNames.isNotEmpty) {
      await applyNow();
    }
  }

  void clearOnDispose() {
    // 메모리 커지는 대신 재빌드 비용 줄일려면 주석 처리
    _cache.clear();
    _building.clear();
    _tagToClipIds.clear();
    _items = const [];
    _isLoading = false;
    _debounce?.cancel();
    _clipsSub?.cancel();
    _segmentsSub?.cancel();
    _clipTagsSub?.cancel();
    _activeTagNames.clear();
    filteredClipIds = [];
    _thumbProviders.clear();
    _resultsVersion = 0;
  }

  @override
  void dispose() {
    clearOnDispose();
    super.dispose();
  }

  /// ======== 공개 API ========

  Future<List<int>> applyOrByTagNames(List<String> names) async {
    if (names.isEmpty) {
      filteredClipIds = [];
      notifyListeners();
      return filteredClipIds;
    }
    final rows =
        await (pdb.select(pdb.tags)..where((t) => t.name.isIn(names))).get();

    return applyOrByTagIds(rows.map((t) => t.id).toList());
  }

  Future<List<int>> applyOrByTagIds(List<int> ids) async {
    if (ids.isEmpty) {
      filteredClipIds = [];
      notifyListeners();
      return filteredClipIds;
    }
    await _ensureTagIndex(ids);
    final union = <int>{};
    for (final id in ids) {
      union.addAll(_tagToClipIds[id] ?? <int>{});
    }

    filteredClipIds = union.toList()..sort();
    notifyListeners();
    return filteredClipIds;
  }

  Future<List<ClipItem>> fetchItemsForCurrentFilter() async {
    final ids = filteredClipIds;
    if (ids.isEmpty) return [];
    final order = <int, int>{};
    for (var i = 0; i < ids.length; i++) {
      order[ids[i]] = i;
    }

    final out = <ClipItem>[];

    for (final id in ids) {
      final hit = _cache[id];
      if (hit != null) {
        _touch(id);
        out.add(hit);
      }
    }
    for (final id in ids) {
      if (_cache.containsKey(id)) continue;
      out.add(await _getOrBuild(id));
    }

    out.sort((a, b) => (order[a.clip.id] ?? 0).compareTo(order[b.clip.id] ?? 0));
    return out;
  }

  /// ======== 내부 ========
  Future<void> _ensureTagIndex(Iterable<int> tagIds) async {
    final missing = <int>[];

    for (final id in tagIds) {
      if (!_tagToClipIds.containsKey(id)) {
        missing.add(id);
      }
    }
    if (missing.isEmpty) return;
    final jt = pdb.clipTags;
    final rows =
        await (pdb.select(jt)..where((jt) => jt.tagId.isIn(missing))).get();
    for (final id in missing) {
      _tagToClipIds[id] = <int>{};
    }
    for (final row in rows) {
      (_tagToClipIds[row.tagId] ??= <int>{}).add(row.clipId);
    }
  }

  Future<ClipItem> _getOrBuild(int clipId) async {
    final hit = _cache[clipId];
    if (hit != null) {
      _touch(clipId);
      return hit;
    }
    /// 다른 스레드에서 이미 빌드 중인 경우 대기
    if (_building.contains(clipId)) {
      final start = DateTime.now();
      while (_building.contains(clipId) &&
          DateTime.now().difference(start).inMilliseconds < 500) {
        await Future<void>.delayed(const Duration(milliseconds: 20));
      }
      final again = _cache[clipId];
      if (again != null) return again;
    }

    _building.add(clipId);
    try{
      // clip
      final clip = await (pdb.select(pdb.clips)
      ..where((c) => c.id.equals(clipId))
      ..limit(1))
          .getSingleOrNull();
      if (clip == null)  throw StateError('Clip not found: $clipId');

      // segments
      final segments = await (pdb.select(pdb.segments)
      ..where((s) => s.clipId.equals(clipId))
      ..orderBy([(s) => OrderingTerm.asc(s.startMs)])).get();

      // tags
      final jt = pdb.clipTags;
      final tagRows = await(pdb.select(pdb.tags).join([
        innerJoin(jt, jt.tagId.equalsExp(pdb.tags.id)),
      ])..where(jt.clipId.equals(clipId))).get();
      final tags = [for (final r in tagRows) r.readTable(pdb.tags)];

      // thumbnail

      Uint8List? thumb;
      try{
        final abs =await _absolutePathFor(clip.filePath);
        thumb = await VideoThumbnail.thumbnailData(
          video: abs,
          imageFormat: ImageFormat.JPEG,
          quality: 70,
          timeMs: 0,
        );
      } catch(_){
        thumb = null;
      }

      if (thumb != null) {
        _thumbProviders[clipId] = MemoryImage(thumb);
      }
      final item = ClipItem(
        clip: clip,
        segments: segments,
        tags: tags,
        thumbnail: thumb,
      );

      _put(clipId, item);
      return item;
    } finally{
      _building.remove(clipId);
    }
  }

  Future<String> _absolutePathFor(String path) async {
    if (path.startsWith('/')) return path;
    _docsPath ??= (await getApplicationDocumentsDirectory()).path;
    return '$_docsPath/$path';
  }

  /// LRU 갱신
  void _touch(int id) {
    final v = _cache.remove(id);
    if (v != null) _cache[id] = v;
  }

  void _put(int id, ClipItem item) {
    _cache[id] = item;
    if (_cache.length > _maxCacheSize) {
      final evictId = _cache.keys.first;
      _cache.remove(evictId);
      _thumbProviders.remove(evictId);
    }
  }
}
