// ============================================================================
// lib/features/payment/presentation/payment_fail_screen.dart
// ============================================================================
//
// [역할]
// 결제 실패 화면.
//
// [레이어]
// Presentation Layer - View
// ============================================================================

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:parrokit/core/router/app_router.dart';

/// 결제 실패 화면.
class PaymentFailScreen extends StatelessWidget {
  const PaymentFailScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.go(AppRoutes.authPath),
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
