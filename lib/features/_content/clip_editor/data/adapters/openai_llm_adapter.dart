// ============================================================================
// lib/features/_content/clip_editor/data/adapters/openai_llm_adapter.dart
// ============================================================================
//
// [역할]
// OpenAI Chat Completions API 어댑터.
// LLMPort 인터페이스 구현. 범용 LLM 호출.
//
// [레이어]
// Data Layer > Adapters
// ============================================================================

import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:parrokit/features/_content/clip_editor/data/ports/llm_port.dart';
import '../constants/openai_constants.dart';

/// OpenAI LLM 어댑터.
class OpenAILlmAdapter implements LLMPort {
  final String apiKey;

  OpenAILlmAdapter({required this.apiKey});

  @override
  Future<String> complete({
    required String systemPrompt,
    required String userPrompt,
    Duration? timeout,
  }) async {
    // sanitize API key (strip smart quotes / surrounding quotes)
    final cleanKey =
        apiKey.trim().replaceAll('\u201C', '').replaceAll('\u201D', '');
    if (cleanKey.isEmpty) {
      throw ArgumentError('OPENAI_API_KEY is empty after sanitization.');
    }

    final uri = Uri.parse(OpenAIConstants.chatEndpoint);
    final headers = <String, String>{
      'Authorization': 'Bearer $cleanKey',
      'Content-Type': 'application/json',
    };

    final body = jsonEncode({
      'model': OpenAIConstants.chatDefaultModel,
      // Force JSON-safe output
      'response_format': {'type': 'json_object'},
      'temperature': 0.2,
      'messages': [
        {'role': 'system', 'content': systemPrompt},
        {'role': 'user', 'content': userPrompt},
      ],
    });

    final resp = await http
        .post(uri, headers: headers, body: body)
        .timeout(timeout ?? const Duration(seconds: 240));

    if (resp.statusCode != 200) {
      throw Exception('OpenAI chat failed (${resp.statusCode}): ${resp.body}');
    }

    final data = jsonDecode(resp.body) as Map<String, dynamic>;
    final choices = (data['choices'] as List?) ?? const [];
    if (choices.isEmpty) {
      throw Exception('OpenAI chat returned no choices.');
    }
    final msg = (choices.first as Map)['message'] as Map<String, dynamic>;
    final content = (msg['content'] as String?) ?? '';
    return content;
  }
}
