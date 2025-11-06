// mvp/editor/ports/llm_port.dart

abstract class LLMPort{
  Future<String> complete({
    required String systemPrompt,
    required String userPrompt,
    String? model,
    Duration? timeout,
});
}