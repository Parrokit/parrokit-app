// ============================================================================
// lib/features/_content/editor/presentation/view_model/editor_tag_mixin.dart
// ============================================================================
//
// [역할]
// 태그 관리 mixin.
//
// [레이어]
// Presentation Layer > ViewModel > Mixin
// ============================================================================

import 'package:flutter/foundation.dart';

/// 태그 관리 mixin.
mixin EditorTagMixin on ChangeNotifier {
  // ─────────────────────────────────────────────────────────────────
  // 상태
  // ─────────────────────────────────────────────────────────────────
  final List<String> tags = [];

  // ─────────────────────────────────────────────────────────────────
  // 태그 관리
  // ─────────────────────────────────────────────────────────────────
  void addTag(String tag) {
    final trimmed = tag.trim();
    if (trimmed.isNotEmpty && !tags.contains(trimmed)) {
      tags.add(trimmed);
      notifyListeners();
    }
  }

  void removeTag(String tag) {
    tags.remove(tag);
    notifyListeners();
  }

  void clearTags() {
    tags.clear();
    notifyListeners();
  }
}
