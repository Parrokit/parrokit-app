import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:parrokit/mvp/payment/payment_adapter.dart';
import 'package:parrokit/pa_router.dart';
import 'package:provider/provider.dart';
import 'package:parrokit/provider/user_provider.dart';

class PaymentScreen extends StatelessWidget {
  final String merchantUid;
  final int amount;
  final int coins;
  final String productName;
  final String buyerEmail;
  final PaymentResultCallback onResult;
  final PaymentAdapter _adapter;

  const PaymentScreen({
    super.key,
    required this.merchantUid,
    required this.amount,
    required this.coins,
    required this.productName,
    required this.buyerEmail,
    required this.onResult,
    PaymentAdapter? adapter,
  }) : _adapter = adapter ?? const PaymentAdapter();

  @override
  Widget build(BuildContext context) {
    final userProvider = context.read<UserProvider>();
    return Scaffold(
      appBar: AppBar(
        title: const Text('결제'),
      ),
      body: _adapter.buildIamportPayment(
        merchantUid: merchantUid,
        amount: amount,
        productName: productName,
        buyerEmail: buyerEmail,
        onResult: (result)  async {
          // 1) 상위에서 내려온 콜백 먼저 실행 (코인 적립, 서버 검증 등)
          onResult(result);

          // 2) PortOne/아임포트 결과에서 성공 여부 추출
          dynamic successRaw;
          if (result is Map) {
            successRaw = result['imp_success'] ?? result['success'];
          } else {
            successRaw = null;
          }

          final isSuccess = successRaw == true ||
              successRaw == 'true' ||
              successRaw == 1 ||
              successRaw == '1';

          // 3) 성공 시 코인 증가, 실패 시 실패 화면으로 이동
          if (isSuccess) {
            // userProvider.coins 에 결제 금액만큼 코인 추가
            await userProvider.addCoins(coins);
            if (!context.mounted) return;
            context.go(PaRoutes.paymentSuccessPath);
          } else {
            context.go(PaRoutes.paymentFailPath);
          }
        },
      ),
    );
  }
}

class PaymentSuccessScreen extends StatelessWidget {
  const PaymentSuccessScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            context.go(PaRoutes.authPath);
          },
        ),
        title: const Text('결제 성공'),
      ),
      body: const Center(
        child: Text(
          '결제가 성공적으로 완료되었습니다!',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
        ),
      ),
    );
  }
}

class PaymentFailScreen extends StatelessWidget {
  const PaymentFailScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            context.go(PaRoutes.authPath);
          },
        ),
        title: const Text('결제 실패'),
      ),
      body: const Center(
        child: Text(
          '결제가 정상적으로 처리되지 않았습니다.',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
        ),
      ),
    );
  }
}