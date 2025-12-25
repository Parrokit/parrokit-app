// lib/mvp/payment/payment_service.dart
import 'package:dio/dio.dart';

class PaymentService {
  final Dio dio;

  PaymentService(this.dio);

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