// ============================================================================
// lib/features/_content/editor/data/usecases/extract_duration_usecase.dart
// ============================================================================
//
// [역할]
// 비디오 재생 시간 추출 UseCase.
//
// [레이어]
// Data Layer > UseCases
// ============================================================================

import 'package:parrokit/features/_content/editor/data/services/video_meta_service.dart';

class ExtractDurationUseCase {
  final VideoMetaService meta;
  ExtractDurationUseCase(this.meta);
  Future<int?> call(String path) => meta.durationMs(path);
}
