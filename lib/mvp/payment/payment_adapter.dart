import 'package:flutter/material.dart';
import 'package:iamport_flutter/iamport_payment.dart';
import 'package:iamport_flutter/model/payment_data.dart';

typedef PaymentResult = Map<String, String>;
typedef PaymentResultCallback = void Function(PaymentResult result);

/// 아임포트 userCode / PG 코드 (지금은 테스트용 상수)
const String _iamportUserCode = 'imp23824220';
const String _pgCode = 'html5_inicis.INIpayTest';
const String _appScheme = 'parrokit';

class PaymentAdapter {
  const PaymentAdapter();

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