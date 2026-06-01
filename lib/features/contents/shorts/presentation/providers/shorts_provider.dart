// ============================================================================
// lib/features/_content/shorts/presentation/providers/shorts_provider.dart
// ============================================================================
//
// [역할]
// 쇼츠(Shorts) 화면의 UI 상태 및 데이터 로딩 관리.
//
// [레이어]
// Presentation Layer > Provider (ViewModel)
//
// ============================================================================

import 'package:flutter/foundation.dart';
import 'package:parrokit/features/contents/shorts/data/shorts_repository.dart';
import 'package:parrokit/data/models/clip_item.dart';

/// [역할]
/// 쇼츠(Shorts) 화면의 UI 상태 및 데이터 로딩 관리.
///
/// 데이터 로딩은 [ShortsRepository]에 위임합니다.
/// - 자동 재생 설정(AutoNext) 관리
/// - 무한 스크롤(LoadMore) / 새로고침 관리
class ShortsProvider extends ChangeNotifier {
  final ShortsRepository _repository;

  ShortsProvider(this._repository);

  // ─────────────────────────────────────────────────────────────────
  // State
  // ─────────────────────────────────────────────────────────────────
  final List<ClipItem> _shorts = [];

  /// 표시할 클립 데이터 목록
  List<ClipItem> get shorts => List.unmodifiable(_shorts);

  bool _autoNext = true;

  /// 영상 종료 시 다음 영상 자동 재생 여부
  bool get autoNext => _autoNext;

  bool _loading = false;

  /// 데이터 로딩 중 여부
  bool get loading => _loading;

  /// 한 번에 로드할 클립 개수 (배치 크기)
  static const int pageSize = 10;

  // ─────────────────────────────────────────────────────────────────
  // Actions
  // ─────────────────────────────────────────────────────────────────

  void toggleAutoNext() {
    _autoNext = !_autoNext;
    notifyListeners();
  }

  void setAutoNext(bool value) {
    if (_autoNext == value) return;
    _autoNext = value;
    notifyListeners();
  }

  /// 초기 데이터 로드 (첫 진입 또는 완전 초기화 시).
  ///
  /// 기존에 로드된 클립 목록을 모두 비우고([clear]),
  /// 새로운 랜덤 클립을 [limit]만큼 로드하여 채웁니다.
  /// 화면 진입 시 한 번 호출됩니다.
  Future<void> loadInitial() async {
    _shorts.clear();
    await _loadRandomClips(limit: pageSize);
  }

  /// 목록 새로고침.
  ///
  /// 사용자가 당겨서 새로고침(Pull-to-refresh)을 수행할 때 사용됩니다.
  /// [loadInitial]과 유사하게 목록을 비우고 다시 로드합니다.
  Future<void> refresh() async {
    _shorts.clear();
    await _loadRandomClips(limit: pageSize);
  }

  /// 추가 데이터 로드 (무한 스크롤).
  ///
  /// 현재 목록의 끝에 도달했을 때 추가로 랜덤 클립을 로드하여 붙입니다.
  /// 이미 로딩 중이면 중복 요청을 무시합니다.
  Future<void> loadMore() async {
    await _loadRandomClips(limit: pageSize);
  }

  /// [ShortsRepository]를 통해 랜덤 클립을 로드하여 목록에 추가
  Future<void> _loadRandomClips({required int limit}) async {
    if (_loading) return;
    _loading = true;
    notifyListeners();
    try {
      final newClips = await _repository.getRandomClips(limit: limit);

      if (newClips.isNotEmpty) {
        _shorts.addAll(newClips);
      }
    } finally {
      _loading = false;
      notifyListeners();
    }
  }

  /// 리스트의 앞부분 [count]개를 삭제합니다.
  ///
  /// 무한 롤링(Cycle Refresh) 구현 시, 이전 배치를 제거하고
  /// 인덱스를 초기화하기 위해 사용됩니다.
  void removeItems(int count) {
    if (count <= 0 || count > _shorts.length) return;
    _shorts.removeRange(0, count);
    notifyListeners();
  }
}
