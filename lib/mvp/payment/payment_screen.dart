import 'package:flutter/material.dart';
import 'package:parrokit/mvp/payment/payment_adapter.dart';

class PaymentScreen extends StatelessWidget {
  final String merchantUid;
  final int amount;
  final String productName;
  final String buyerEmail;
  final PaymentResultCallback onResult;
  final PaymentAdapter _adapter;

  const PaymentScreen({
    super.key,
    required this.merchantUid,
    required this.amount,
    required this.productName,
    required this.buyerEmail,
    required this.onResult,
    PaymentAdapter? adapter,
  }) : _adapter = adapter ?? const PaymentAdapter();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('결제'),
      ),
      body: _adapter.buildIamportPayment(
        merchantUid: merchantUid,
        amount: amount,
        productName: productName,
        buyerEmail: buyerEmail,
        onResult: (result) {
          onResult(result);
          // 필요하면 여기서 Navigator.of(context).pop() 도 같이 호출 가능
        },
      ),
    );
  }
}