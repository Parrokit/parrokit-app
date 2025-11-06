// mvp/editor/usecases/translate_segment_usecase.dart

import 'package:parrokit/mvp/editor/ports/llm_port.dart';

class TranslateSegmentUseCase {
  final LLMPort llm;

  TranslateSegmentUseCase(this.llm);

  Future<String> call({required String jp}) async {
    final sys = "너는 일본어→한국어 자막 번역가야. 존댓말 유지, 줄바꿈/기호 보존.";
    final usr = "다음 문장을 자연스럽고 간결하게 번역해줘:\n$jp";
    return await llm.complete(systemPrompt: sys, userPrompt: usr);
  }
}
