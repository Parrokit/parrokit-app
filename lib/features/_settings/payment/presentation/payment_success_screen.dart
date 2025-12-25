// ============================================================================
// lib/features/payment/presentation/payment_success_screen.dart
// ============================================================================
//
// [역할]
// 결제 성공 화면.
//
// [레이어]
// Presentation Layer - View
// ============================================================================

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:parrokit/core/router/app_router.dart';

/// 결제 성공 화면.
class PaymentSuccessScreen extends StatelessWidget {
  const PaymentSuccessScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.go(AppRoutes.authPath),
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
