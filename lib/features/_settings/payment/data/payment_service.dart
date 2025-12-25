// ============================================================================
// lib/features/payment/data/payment_service.dart
// ============================================================================
//
// [역할]
// 결제 서비스.
// 서버와의 결제 관련 API 통신.
//
// [레이어]
// Data Layer - Service
// ============================================================================

import 'package:dio/dio.dart';

/// 결제 서비스.
///
/// 서버와의 결제 관련 API 통신.
class PaymentService {
  final Dio dio;

  PaymentService(this.dio);

  /// 결제 생성 요청
  Future<String> createPayment({
    required String userId,
    required int amount,
    required String productId,
  }) async {
    final res = await dio.post("/payments/create", data: {
      "userId": userId,
      "amount": amount,
      "productId": productId,
    });

    return res.data["merchant_uid"]; // 서버가 생성한 결제 ID
  }
}
