// ============================================================================
// lib/features/_content/clip_editor/data/usecases/translate_segment_usecase.dart
// ============================================================================
//
// [역할]
// 세그먼트 번역 UseCase.
// LLMPort를 통해 일본어→한국어 번역.
//
// [레이어]
// Data Layer > UseCases
// ============================================================================

import 'package:parrokit/features/content/clip-editor/data/ports/llm_port.dart';
import '../prompts/prompt_loader.dart';

class TranslateSegmentUseCase {
  final LLMPort llm;

  TranslateSegmentUseCase(this.llm);

  Future<String> call({required String jp}) async {
    final sys = await PromptLoader.loadTranslateSystem();
    final userPrefix = await PromptLoader.loadTranslateUser();
    return await llm.complete(systemPrompt: sys, userPrompt: '$userPrefix$jp');
  }
}
