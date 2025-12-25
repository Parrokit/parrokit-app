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
  void showToast(String msg);

  // ─────────────────────────────────────────────────────────────────
  // 상태
  // ─────────────────────────────────────────────────────────────────
  List<String> allTitleNames = [];
  List<int> seasonNumbers = [];
  List<int> episodeNumbers = [];

  // ─────────────────────────────────────────────────────────────────
  // 데이터 로드
  // ─────────────────────────────────────────────────────────────────
  Future<void> loadTitleNames() async {
    try {
      final names = await titlesDao.fetchAllTitleNames();
      allTitleNames = names;
      notifyListeners();
    } catch (e) {
      showToast('작품 목록 로드 오류: $e');
    }
  }

  Future<void> loadSeasonOptions(String titleName) async {
    if (titleName.isEmpty || contentType != ContentType.season) return;
    try {
      final nums = await titlesDao.fetchSeasonNumbersByTitleName(titleName);
      seasonNumbers = nums;
      notifyListeners();
    } catch (e) {
      showToast('시즌 정보 로드 오류: $e');
    }
  }

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
      showToast('회차 정보 로드 오류: $e');
    }
  }

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
}
