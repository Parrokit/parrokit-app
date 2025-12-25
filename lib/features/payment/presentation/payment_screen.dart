// ============================================================================
// lib/features/payment/presentation/payment_screen.dart
// ============================================================================
//
// [역할]
// 결제 메인 화면. 아임포트 결제 위젯 표시.
// 결제 완료 시 성공/실패 화면으로 라우팅.
//
// [레이어]
// Presentation Layer - View
//
// [구성 요소]
// - PaymentAdapter: 아임포트 결제 위젯 빌더
// ============================================================================

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:parrokit/core/router/pa_router.dart';
import 'package:parrokit/core/provider/user_provider.dart';
import '../data/payment_adapter.dart';

/// 결제 화면.
///
/// 아임포트 결제 위젯을 표시하고 결과 처리.
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
        onResult: (result) async {
          // 1) 상위에서 내려온 콜백 먼저 실행
          onResult(result);

          // 2) 결과에서 성공 여부 추출
          final isSuccess = _parseSuccess(result);

          // 3) 성공 시 코인 증가, 실패 시 실패 화면으로 이동
          if (isSuccess) {
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

  /// PortOne/아임포트 결과에서 성공 여부 파싱
  bool _parseSuccess(dynamic result) {
    dynamic successRaw;
    if (result is Map) {
      successRaw = result['imp_success'] ?? result['success'];
    } else {
      successRaw = null;
    }

    return successRaw == true ||
        successRaw == 'true' ||
        successRaw == 1 ||
        successRaw == '1';
  }
}
