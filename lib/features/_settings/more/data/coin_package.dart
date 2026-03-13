// ============================================================================
// lib/features/auth/domain/coin_package.dart
// ============================================================================
//
// [역할]
// 코인 충전 패키지 모델.
// 결제 금액, 기본 코인, 보너스 코인 정보를 담고 있음.
//
// [레이어]
// Domain Layer - 비즈니스 로직에서 사용하는 순수 모델.
// UI나 외부 의존성 없이 독립적으로 존재.
//
// [사용처]
// - CoinStoreSection: 코인 충전 UI
// - PaymentScreen: 결제 처리
// ============================================================================

/// 코인 충전 패키지 모델.
///
/// 각 패키지는 가격, 기본 코인 수, 보너스 코인 수를 포함.
/// [totalCoins]로 총 지급 코인 계산 가능.
class CoinPackage {
  /// 결제 금액 (KRW, 원화)
  final int price;

  /// 기본 지급 코인 수
  final int coins;

  /// 보너스 코인 수 (추가 지급)
  final int bonusCoins;

  const CoinPackage({
    required this.price,
    required this.coins,
    required this.bonusCoins,
  });

  /// 총 지급 코인 수 (기본 + 보너스)
  int get totalCoins => coins + bonusCoins;

  // ─────────────────────────────────────────────────────────────────
  // 사전 정의된 패키지 목록
  // ─────────────────────────────────────────────────────────────────

  /// 사전 정의된 코인 패키지 목록 (10% 보너스 적용)
  ///
  /// | 가격 | 기본 | 보너스 | 총 코인 |
  /// |------|------|--------|---------|
  /// | ₩1,000 | 80 | 8 | 88 |
  /// | ₩3,000 | 240 | 24 | 264 |
  /// | ₩5,000 | 400 | 40 | 440 |
  /// | ₩10,000 | 800 | 80 | 880 |
  static const List<CoinPackage> packages = [
    CoinPackage(price: 1000, coins: 80, bonusCoins: 8),
    CoinPackage(price: 3000, coins: 240, bonusCoins: 24),
    CoinPackage(price: 5000, coins: 400, bonusCoins: 40),
    CoinPackage(price: 10000, coins: 800, bonusCoins: 80),
  ];
}
