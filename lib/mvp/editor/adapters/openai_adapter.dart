import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:parrokit/mvp/editor/ports/llm_port.dart';

class OpenAIAdapter implements LLMPort {
  final String apiKey;
  final String defaultModel;

  OpenAIAdapter({required this.apiKey, this.defaultModel = "gpt-4o-mini"});

  @override
  Future<String> complete({
    required String systemPrompt,
    required String userPrompt,
    String? model,
    Duration? timeout,
  }) async {
    final chosenModel = model ?? defaultModel;

    // sanitize API key (strip smart quotes / surrounding quotes)
    final cleanKey = apiKey
        .trim()
        .replaceAll('\u201C', '')
        .replaceAll('\u201D', '');
    if (cleanKey.isEmpty) {
      throw ArgumentError('OPENAI_API_KEY is empty after sanitization.');
    }

    final uri = Uri.parse('https://api.openai.com/v1/chat/completions');
    final headers = <String, String>{
      'Authorization': 'Bearer $cleanKey',
      'Content-Type': 'application/json',
    };

    final body = jsonEncode({
      'model': chosenModel,
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