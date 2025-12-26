// ============================================================================
// lib/features/payment/domain/payment_port.dart
// ============================================================================
//
// [역할]
// 결제 포트 인터페이스.
// 결제 화면 빌더의 추상화 계층.
//
// [레이어]
// Domain Layer - Port (Interface)
// ============================================================================

import 'package:flutter/cupertino.dart';
import '../data/payment_adapter.dart';
import '../presentation/payment_screen.dart';

/// 결제 포트 인터페이스.
///
/// 결제 화면 위젯 빌더 추상화.
abstract class PaymentPort {
  /// 결제 화면 위젯 생성
  Widget buildPaymentScreen({
    required String merchantUid,
    required int amount,
    required int coins,
    required String productName,
    required String buyerEmail,
    required PaymentResultCallback onResult,
  });
}

/// 아임포트 결제 포트 구현체.
class IamportPaymentPort implements PaymentPort {
  const IamportPaymentPort();

  @override
  Widget buildPaymentScreen({
    required String merchantUid,
    required int amount,
    required int coins,
    required String productName,
    required String buyerEmail,
    required PaymentResultCallback onResult,
  }) {
    return PaymentScreen(
      merchantUid: merchantUid,
      amount: amount,
      coins: coins,
      productName: productName,
      buyerEmail: buyerEmail,
      onResult: onResult,
    );
  }
}
