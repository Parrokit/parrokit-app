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

    throw UnimplementedError();
  }
}