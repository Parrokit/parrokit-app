// ============================================================================
// lib/features/content-studio/captioning/presentation/providers/mixins/edit_autocomplete_mixin.dart
// ============================================================================
//
// [역할]
// 자동완성 데이터 로드 mixin.
// 컬렉션 이름 목록 로드.
//
// [레이어]
// Presentation Layer > Provider > Mixin
// ============================================================================

import 'package:flutter/material.dart';
import 'package:parrokit/core/shared/utils/show_toast.dart';
import 'package:parrokit/data/local/dao/collections_dao.dart';

/// 자동완성 데이터 로드 mixin.
mixin EditAutocompleteMixin on ChangeNotifier {
  // 의존성 (추상 getter)
  CollectionsDao get collectionsDao;

  // ─────────────────────────────────────────────────────────────────
  // 상태
  // ─────────────────────────────────────────────────────────────────
  List<String> allCollectionNames = [];

  // ─────────────────────────────────────────────────────────────────
  // 데이터 로드
  // ─────────────────────────────────────────────────────────────────

  /// DB에 저장된 모든 컬렉션 이름 목록을 로드합니다. (자동완성용)
  Future<void> loadCollectionNames() async {
    try {
      final names = await collectionsDao.fetchAllNames();
      allCollectionNames = names;
      notifyListeners();
    } catch (e) {
      showToast('컬렉션 목록 로드 오류: $e');
    }
  }
}
