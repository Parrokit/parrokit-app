// ============================================================================
// lib/features/_content/shorts/presentation/providers/ad_provider.dart
// ============================================================================
//
// [역할]
// 쇼츠 스와이프 시 광고 노출 로직 관리.
//
// [레이어]
// Presentation Layer > Provider
//
// ============================================================================

import 'package:flutter/foundation.dart';
import 'package:parrokit/features/_content/shorts/data/shorts_ad_repository.dart';

/// [역할]
/// 쇼츠 스와이프 시 광고 노출 로직 관리.
///
/// [AdProvider]는 프리미엄 여부와 스와이프 횟수를 추적하여
/// 특정 횟수([threshold])마다 광고 노출 신호를 보냅니다.
class AdProvider extends ChangeNotifier {
  static const int threshold = 10;

  final ShortsAdRepository _repository;

  int _count = 0;
  bool _premium = false;

  AdProvider({
    required ShortsAdRepository repository,
    required bool initialPremium,
  }) : _repository = repository {
    _premium = initialPremium;
    _loadCount();
  }

  // ─────────────────────────────────────────────────────────────────
  // State
  // ─────────────────────────────────────────────────────────────────

  bool get premium => _premium;
  set premium(bool value) {
    if (_premium != value) {
      _premium = value;
      notifyListeners();
    }
  }

  int get count => _count;

  // ─────────────────────────────────────────────────────────────────
  // Actions
  // ─────────────────────────────────────────────────────────────────

  Future<void> _loadCount() async {
    final raw = await _repository.loadCount();
    _count = _norm(raw);
    notifyListeners();
  }

  /// 0 ~ threshold-1 범위로 정규화
  static int _norm(int v) => ((v % threshold) + threshold) % threshold;

  /// 스와이프 카운트를 증가시키고, 광고 노출 시점인지 판별합니다.
  ///
  /// [delta]만큼 카운트를 증가시키며, [delta]가 양수(다음 영상으로 이동)일 때만 동작합니다.
  /// 프리미엄([_premium]) 사용자인 경우 카운트를 증가시키지 않고 항상 `false`를 반환합니다.
  ///
  /// 반환값:
  /// - `true`: 기준([threshold])에 도달하여 광고를 보여줘야 함.
  /// - `false`: 아직 노출 시점이 아님.
  bool incrementBy(int delta) {
    if (delta <= 0 || _premium) return false;

    _count = _norm(_count + delta);
    _repository.saveCount(_count); // 굳이 await 안 해도 됨 (fire and forget)

    notifyListeners();
    return _count == 0;
  }

  void reset() {
    _count = 0;
    _repository.clearCount();
    notifyListeners();
  }
}
