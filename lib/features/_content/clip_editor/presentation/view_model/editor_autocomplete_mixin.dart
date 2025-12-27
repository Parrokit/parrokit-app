// ============================================================================
// lib/features/_content/editor/presentation/view_model/editor_autocomplete_mixin.dart
// ============================================================================
//
// [역할]
// 자동완성 데이터 로드 mixin.
// 작품명, 시즌, 에피소드 목록 로드.
//
// [레이어]
// Presentation Layer > ViewModel > Mixin
// ============================================================================

import 'package:flutter/material.dart';
import 'package:parrokit/core/router/app_router.dart';
import 'package:parrokit/core/utils/show_toast.dart';
import 'package:parrokit/data/local/dao/titles_dao.dart';

import '../../domain/editor_state.dart';

/// 자동완성 데이터 로드 mixin.
mixin EditorAutocompleteMixin on ChangeNotifier {
  // 의존성 (추상 getter)
  TitlesDao get titlesDao;
  ContentType get contentType;
  TextEditingController get nameCtl;
  TextEditingController get seasonCtl;
  TextEditingController get episodeCtl;
  TextEditingController get epiTitleCtl;
  TextEditingController get nameNativeCtl;

  // ─────────────────────────────────────────────────────────────────
  // 상태
  // ─────────────────────────────────────────────────────────────────
  List<String> allTitleNames = [];
  List<int> seasonNumbers = [];
  List<int> episodeNumbers = [];

  // ─────────────────────────────────────────────────────────────────
  // 데이터 로드
  // ─────────────────────────────────────────────────────────────────

  /// DB에 저장된 모든 작품 이름 목록을 로드합니다. (자동완성용)
  Future<void> loadTitleNames() async {
    try {
      final names = await titlesDao.fetchAllTitleNames();
      allTitleNames = names;
      notifyListeners();
    } catch (e) {
      if (rootNavigatorKey.currentContext != null) {
        showToast(rootNavigatorKey.currentContext!, '작품 목록 로드 오류: $e');
      }
    }
  }

  /// 특정 작품([titleName])의 시즌 번호 목록을 로드합니다.
  Future<void> loadSeasonOptions(String titleName) async {
    if (titleName.isEmpty || contentType != ContentType.season) return;
    try {
      final nums = await titlesDao.fetchSeasonNumbersByTitleName(titleName);
      seasonNumbers = nums;
      notifyListeners();
    } catch (e) {
      if (rootNavigatorKey.currentContext != null) {
        showToast(rootNavigatorKey.currentContext!, '시즌 정보 로드 오류: $e');
      }
    }
  }

  /// 입력된 작품명/시즌번호를 기반으로 에피소드 번호 목록을 로드합니다.
  Future<void> loadEpisodeOptions() async {
    final titleName = nameCtl.text.trim();
    final seasonText = seasonCtl.text.trim();
    if (titleName.isEmpty ||
        seasonText.isEmpty ||
        contentType != ContentType.season) {
      return;
    }
    final seasonNumber = int.tryParse(seasonText);
    if (seasonNumber == null) return;

    try {
      final nums = await titlesDao.fetchEpisodeNumbers(
        titleName: titleName,
        seasonNumber: seasonNumber,
      );
      episodeNumbers = nums;
      notifyListeners();
    } catch (e) {
      if (rootNavigatorKey.currentContext != null) {
        showToast(rootNavigatorKey.currentContext!, '회차 정보 로드 오류: $e');
      }
    }
  }

  /// 작품명, 시즌, 에피소드 번호가 모두 입력되었을 때,
  /// 해당 에피소드의 제목이 DB에 있다면 자동 완성합니다.
  Future<void> autoFillEpisodeTitle() async {
    final titleName = nameCtl.text.trim();
    final seasonText = seasonCtl.text.trim();
    final episodeText = episodeCtl.text.trim();
    if (titleName.isEmpty || seasonText.isEmpty || episodeText.isEmpty) return;
    if (contentType != ContentType.season) return;

    final seasonNumber = int.tryParse(seasonText);
    final episodeNumber = int.tryParse(episodeText);
    if (seasonNumber == null || episodeNumber == null) return;

    try {
      final title = await titlesDao.findEpisodeTitle(
        titleName: titleName,
        seasonNumber: seasonNumber,
        episodeNumber: episodeNumber,
      );
      if (title != null && title.isNotEmpty) {
        epiTitleCtl.text = title;
        notifyListeners();
      }
    } catch (_) {}
  }

  /// 작품명이 선택되었을 때, 해당 작품의 원어 작품명이 있으면 자동 완성합니다.
  Future<void> autoFillNativeTitle(String titleName) async {
    if (titleName.isEmpty) return;

    try {
      final nativeName = await titlesDao.findNativeByName(titleName);
      if (nativeName != null && nativeName.isNotEmpty) {
        nameNativeCtl.text = nativeName;
        notifyListeners();
      }
    } catch (_) {}
  }
}
