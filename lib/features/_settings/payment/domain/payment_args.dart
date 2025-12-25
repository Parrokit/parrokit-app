// ============================================================================
// lib/features/payment/domain/payment_args.dart
// ============================================================================
//
// [역할]
// 결제 인수 데이터 클래스.
// 결제 화면으로 전달할 파라미터 정의.
//
// [레이어]
// Domain Layer - Entity
// ============================================================================

/// 결제 화면 인수.
class PaymentArgs {
  final String merchantUid;
  final int amount;
  final int coins;
  final String productName;
  final String buyerEmail;

  const PaymentArgs({
    required this.merchantUid,
    required this.amount,
    required this.coins,
    required this.productName,
    required this.buyerEmail,
  });
}
