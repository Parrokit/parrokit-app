// ============================================================================
// lib/features/payment/data/payment_adapter.dart
// ============================================================================
//
// [역할]
// 아임포트 결제 어댑터.
// 아임포트 SDK를 사용한 결제 위젯 빌더.
//
// [레이어]
// Data Layer - Adapter
// ============================================================================

import 'package:flutter/material.dart';
import 'package:iamport_flutter/iamport_payment.dart';
import 'package:iamport_flutter/model/payment_data.dart';

typedef PaymentResult = Map<String, String>;
typedef PaymentResultCallback = void Function(PaymentResult result);

/// 아임포트 userCode / PG 코드
const String _iamportUserCode = 'imp23824220';
const String _pgCode = 'html5_inicis.INIpayTest';
const String _appScheme = 'parrokit';

/// 아임포트 결제 어댑터.
///
/// 아임포트 SDK를 사용한 결제 위젯 빌더.
class PaymentAdapter {
  const PaymentAdapter();

  /// 아임포트 결제 위젯 생성
  Widget buildIamportPayment({
    required String merchantUid,
    required int amount,
    required String productName,
    required String buyerEmail,
    required PaymentResultCallback onResult,
  }) {
    return IamportPayment(
      userCode: _iamportUserCode,
      data: PaymentData(
        pg: _pgCode,
        payMethod: 'card',
        name: productName,
        merchantUid: merchantUid,
        amount: amount,
        buyerEmail: buyerEmail,
        buyerTel: '',
        appScheme: _appScheme,
      ),
      callback: (PaymentResult result) {
        onResult(result);
      },
    );
  }
}
