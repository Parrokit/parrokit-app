// ============================================================================
// lib/core/provider/mixins/media_tag_mixin.dart
// ============================================================================
//
// [역할]
// 미디어 태그 스트리밍 및 캐싱 로직 분리 (Mixin)
//
// [레이어]
// Core > Provider > Mixins
// ============================================================================

import 'dart:async';
import 'package:drift/drift.dart';
import 'package:flutter/foundation.dart';
import '../../../../../data/local/app_database.dart';

mixin MediaTagMixin on ChangeNotifier {
  AppDatabase get db;

  /// 전체 태그.
  List<Tag> _distinctTags = [];
  StreamSubscription<List<Tag>>? _tagSub;

  List<Tag> get distinctTags => _distinctTags;

  // ─────────────────────────────────────────────────────────────────
  // Methods
  // ─────────────────────────────────────────────────────────────────

  /// DB에 있는 태그를 중복 제거하여 저장, 구독하여 갱신.
  Stream<List<Tag>> _distinctTagsStream({bool onlyUsed = false}) {
    if (onlyUsed) {
      final jt = db.clipTags;
      final q = db.select(db.tags).join([
        innerJoin(jt, jt.tagId.equalsExp(db.tags.id)),
      ]);

      return q.watch().map((rows) {
        final all = rows.map((r) => r.readTable(db.tags)).toList();
        final map = <String, Tag>{};
        for (final t in all) {
          map.putIfAbsent(t.name, () => t);
        }
        final list = map.values.toList()
          ..sort((a, b) => a.name.compareTo(b.name));
        return list;
      });
    } else {
      return (db.select(db.tags)..orderBy([(t) => OrderingTerm.asc(t.name)]))
          .watch()
          .map((all) {
        final map = <String, Tag>{};
        for (final t in all) {
          map.putIfAbsent(t.name, () => t);
        }
        final list = map.values.toList()
          ..sort((a, b) => a.name.compareTo(b.name));
        return list;
      });
    }
  }

  void startWatchingDistinctTags({bool onlyUsed = false}) {
    _tagSub?.cancel();
    _tagSub = _distinctTagsStream(onlyUsed: onlyUsed).listen((list) {
      _distinctTags = list;
      notifyListeners();
    });
  }

  void stopWatchingDistinctTags() {
    _tagSub?.cancel();
    _tagSub = null;
  }
}
