// lib/provider/shorts_provider.dart
import 'dart:convert';
import 'dart:typed_data';
import 'dart:io';

import 'package:drift/drift.dart';
import 'package:flutter/foundation.dart';
import 'package:path_provider/path_provider.dart';
import 'package:video_thumbnail/video_thumbnail.dart';

import 'package:parrokit/data/models/clip_item.dart';
import '../data/local/pa_database.dart';

class ShortsProvider extends ChangeNotifier {
  final PaDatabase pdb;

  ShortsProvider(this.pdb);

  final List<ClipItem> _shorts = [];

  List<ClipItem> get shorts => List.unmodifiable(_shorts);

  bool _autoNext = true;

  bool get autoNext => _autoNext;


  void toggleAutoNext() {
    _autoNext = !_autoNext;
    notifyListeners();
  }

  void setAutoNext(bool value) {
    if (_autoNext == value) return;
    _autoNext = value;
    notifyListeners();
  }

  bool _loading = false;

  bool get loading => _loading;

  static const int _pageSize = 10;

  Future<void> loadInitial() async {
    _shorts.clear();
    await _loadRandomClips(limit: _pageSize);
  }

  Future<void> refresh() async {
    _shorts.clear(); // ✅ getter가 아닌 실제 리스트를 비워야 함
    await _loadRandomClips(limit: _pageSize);
  }

  Future<void> loadMore() async {
    await _loadRandomClips(limit: _pageSize);
  }

  Future<void> _loadRandomClips({required int limit}) async {
    if (_loading) return;
    _loading = true;
    notifyListeners();
    try {
      final clips = await (pdb.select(pdb.clips)
            ..orderBy([
              (c) =>
                  OrderingTerm(expression: const CustomExpression('RANDOM()'))
            ])
            ..limit(limit))
          .get();

      if (clips.isEmpty) {
        _loading = false;
        notifyListeners();
        return;
      }

      // 미리 tag 맵 구성
      final clipIds = clips.map((c) => c.id).toList();
      final jt = pdb.clipTags;
      final tagRows = await (pdb.select(pdb.tags).join([
        innerJoin(jt, jt.tagId.equalsExp(pdb.tags.id)),
      ])
            ..where(jt.clipId.isIn(clipIds)))
          .get();

      final tagsByClip = <int, List<Tag>>{};
      for (final row in tagRows) {
        final tag = row.readTable(pdb.tags);
        final ct = row.readTable(jt);
        tagsByClip.putIfAbsent(ct.clipId, () => []).add(tag);
      }

      // 각 클립에 대해: 절대경로 보정 + segments 로드 + 메모리 썸네일 생성
      for (final c in clips) {
        final absPath = await _absolutePathFor(c.filePath);
        // Drift 데이터클래스 copyWith 사용 (필드명은 스키마에 맞게)
        final clipWithAbs = c.copyWith(filePath: absPath);

        final segments = await (pdb.select(pdb.segments)
              ..where((s) => s.clipId.equals(c.id))
              ..orderBy([(s) => OrderingTerm.asc(s.startMs)]))
            .get();

        Uint8List? thumbBytes;
        try {
          thumbBytes = await VideoThumbnail.thumbnailData(
            video: absPath,
            imageFormat: ImageFormat.JPEG,
            quality: 70,
            timeMs: 500,
          );
        } catch (_) {
          // 썸네일 실패는 무시
        }

        _shorts.add(ClipItem(
          clip: clipWithAbs,
          tags: tagsByClip[c.id] ?? const [],
          segments: segments,
          thumbnail: thumbBytes,
        ));
      }
    } finally {
      _loading = false;
      notifyListeners();
    }
  }

  Future<String> _absolutePathFor(String pathFromClip) async {
    if (pathFromClip.startsWith('/')) return pathFromClip;
    // 필요 시 package:path의 isAbsolute 사용 가능
    final dir = await getApplicationDocumentsDirectory();
    return '${dir.path}/$pathFromClip';
  }
}
