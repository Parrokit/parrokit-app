// ============================================================================
// lib/features/_content/clip_editor/data/usecases/generate_draft_usecase.dart
// ============================================================================
//
// [역할]
// STT 및 LLM을 사용하여 세그먼트 초안을 생성하는 UseCase.
// 실제 로직은 DraftGenerationService에 위임.
//
// [레이어]
// Data Layer > UseCases
// ============================================================================

import '../services/draft_generation_service.dart';

export '../services/draft_generation_service.dart' show DraftResult;

/// STT + LLM 초안 생성 UseCase.
class GenerateDraftUseCase {
  final DraftGenerationService _service;

  GenerateDraftUseCase({required DraftGenerationService service})
      : _service = service;

  /// 영상 파일에서 STT를 수행하고 번역/발음 초안을 생성합니다.
  Future<DraftResult> call({
    required String filePath,
    required int durationMs,
    String language = 'ja',
  }) =>
      _service.generate(
        filePath: filePath,
        durationMs: durationMs,
        language: language,
      );
}
