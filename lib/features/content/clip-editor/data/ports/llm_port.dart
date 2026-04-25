// ============================================================================
// lib/features/_content/editor/data/ports/llm_port.dart
// ============================================================================
//
// [역할]
// LLM(대규모 언어 모델) 포트 인터페이스.
// Chat Completions API 추상화.
//
// [레이어]
// Data Layer > Ports
// ============================================================================

/// LLM Chat Completions 포트.
abstract class LLMPort {
  Future<String> complete({
    required String systemPrompt,
    required String userPrompt,
    Duration? timeout,
  });
}
