// ============================================================================
// lib/features/_content/clip_editor/data/adapters/openai_llm_adapter.dart
// ============================================================================
//
// [역할]
// OpenAI Chat Completions API 어댑터.
// LLMPort 인터페이스 구현. 범용 LLM 호출 (자막 번역, 원어 작품명 조회 등).
//
// [레이어]
// Data Layer > Adapters
// ============================================================================

// dart 내장
import 'dart:convert';

// package
import 'package:http/http.dart' as http;

// relative
import '../constants/openai_constants.dart';
import '../ports/llm_port.dart';

/// OpenAI LLM 어댑터.
///
/// Chat Completions API를 통해 프롬프트 기반 텍스트 생성.
/// JSON 형식 응답을 강제하여 파싱 안정성 보장.
class OpenAILlmAdapter implements LLMPort {
  // ─────────────────────────────────────────────────────────────────
  // 필드
  // ─────────────────────────────────────────────────────────────────
  final String apiKey;

  OpenAILlmAdapter({required this.apiKey});

  // ─────────────────────────────────────────────────────────────────
  // LLMPort 구현
  // ─────────────────────────────────────────────────────────────────

  @override
  Future<String> complete({
    required String systemPrompt,
    required String userPrompt,
    Duration? timeout,
  }) async {
    // API 키 정리 (스마트 따옴표 등 제거)
    final cleanKey =
        apiKey.trim().replaceAll('\u201C', '').replaceAll('\u201D', '');
    if (cleanKey.isEmpty) {
      throw ArgumentError('OPENAI_API_KEY가 비어있습니다.');
    }

    // HTTP 요청 구성
    final uri = Uri.parse(OpenAIConstants.chatEndpoint);
    final headers = <String, String>{
      'Authorization': 'Bearer $cleanKey',
      'Content-Type': 'application/json',
    };

    final body = jsonEncode({
      'model': OpenAIConstants.chatDefaultModel,
      'response_format': {'type': 'json_object'}, // JSON 응답 강제
      'temperature': 0.2,
      'messages': [
        {'role': 'system', 'content': systemPrompt},
        {'role': 'user', 'content': userPrompt},
      ],
    });

    // API 호출
    final resp = await http
        .post(uri, headers: headers, body: body)
        .timeout(timeout ?? const Duration(seconds: 240));

    if (resp.statusCode != 200) {
      throw Exception('LLM 호출 실패(${resp.statusCode}): ${resp.body}');
    }

    // 응답 파싱
    return _parseContent(resp.body);
  }

  // ─────────────────────────────────────────────────────────────────
  // 응답 파싱
  // ─────────────────────────────────────────────────────────────────

  /// API 응답에서 content 추출.
  String _parseContent(String responseBody) {
    final data = jsonDecode(responseBody) as Map<String, dynamic>;
    final choices = (data['choices'] as List?) ?? const [];

    if (choices.isEmpty) {
      throw Exception('LLM 응답에 choices가 없습니다.');
    }

    final msg = (choices.first as Map)['message'] as Map<String, dynamic>;
    return (msg['content'] as String?) ?? '';
  }
}
