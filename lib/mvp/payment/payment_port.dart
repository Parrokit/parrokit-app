
import 'package:flutter/cupertino.dart';
import 'package:parrokit/mvp/payment/payment_adapter.dart';
import 'package:parrokit/mvp/payment/payment_screen.dart';

abstract class PaymentPort {
  /// 결제 진행을 위한 화면 위젯을 만들어서 넘겨준다.
  ///
  /// - [merchantUid] : 서버에서 생성한 주문 번호
  /// - [amount]      : 결제 금액
  /// - [productName] : 상품명 (예: '코인 100개')
  /// - [buyerEmail]  : 사용자 이메일
  /// - [onResult]    : 결제 창이 닫힌 뒤 콜백 (성공/실패 여부는 서버에서 최종 판단)
  Widget buildPaymentScreen({
    required String merchantUid,
    required int amount,
    required String productName,
    required String buyerEmail,
    required PaymentResultCallback onResult,
  });
}

class IamportPaymentPort implements PaymentPort {
  const IamportPaymentPort();

  @override
  Widget buildPaymentScreen({
    required String merchantUid,
    required int amount,
    required String productName,
    required String buyerEmail,
    required PaymentResultCallback onResult,
  }) {
    return PaymentScreen(
      merchantUid: merchantUid,
      amount: amount,
      productName: productName,
      buyerEmail: buyerEmail,
      onResult: onResult,
    );
  }
}