// ============================================================================
// lib/features/content-studio/captioning/data/adapters/openai_api_exception.dart
// ============================================================================
//
// [역할]
// OpenAI API 오류 응답을 사용자에게 보여줄 수 있는 메시지로 변환합니다.
//
// [레이어]
// Data Layer > Adapters
// ============================================================================

import 'dart:convert';

/// OpenAI API 호출 실패를 표현하는 예외.
class OpenAIApiException implements Exception {
  const OpenAIApiException({
    required this.statusCode,
    required this.userMessage,
    this.code,
    this.type,
  });

  final int statusCode;
  final String userMessage;
  final String? code;
  final String? type;

  factory OpenAIApiException.fromResponse({
    required int statusCode,
    required String body,
    required String fallbackAction,
  }) {
    final error = _parseError(body);
    final code = error?['code'] as String?;
    final type = error?['type'] as String?;

    return OpenAIApiException(
      statusCode: statusCode,
      code: code,
      type: type,
      userMessage: _messageFor(
        statusCode: statusCode,
        code: code,
        type: type,
        fallbackAction: fallbackAction,
      ),
    );
  }

  static Map<String, dynamic>? _parseError(String body) {
    try {
      final decoded = jsonDecode(body);
      if (decoded is! Map<String, dynamic>) return null;
      final error = decoded['error'];
      if (error is Map<String, dynamic>) return error;
    } catch (_) {
      return null;
    }
    return null;
  }

  static String _messageFor({
    required int statusCode,
    required String fallbackAction,
    String? code,
    String? type,
  }) {
    if (code == 'insufficient_quota' || type == 'insufficient_quota') {
      return 'OpenAI API 할당량이 부족합니다. 결제 상태나 사용량 한도를 확인한 뒤 다시 시도해 주세요.';
    }

    if (statusCode == 429 || code == 'rate_limit_exceeded') {
      return 'OpenAI 요청 한도를 초과했습니다. 잠시 후 다시 시도해 주세요.';
    }

    if (statusCode == 401 || code == 'invalid_api_key') {
      return 'OpenAI API 키가 유효하지 않습니다. 설정된 키를 확인해 주세요.';
    }

    if (statusCode == 400) {
      return '$fallbackAction 요청 형식을 확인할 수 없습니다. 파일 형식이나 입력값을 다시 확인해 주세요.';
    }

    return '$fallbackAction 중 OpenAI API 오류가 발생했습니다. 잠시 후 다시 시도해 주세요. ($statusCode)';
  }

  @override
  String toString() => userMessage;
}
