// ============================================================================
// lib/features/_content/clip_editor/data/usecases/save_clip_usecase.dart
// ============================================================================
//
// [역할]
// 클립 저장 UseCase.
// 실제 로직은 ClipSaveService에 위임.
//
// [레이어]
// Data Layer > UseCases
// ============================================================================

import '../../domain/clip_form_data.dart';
import '../../domain/editor_mode.dart';
import '../services/clip_save_service.dart';

/// 클립 저장 UseCase.
class SaveClipUseCase {
  final ClipSaveService _service;

  SaveClipUseCase({required ClipSaveService service}) : _service = service;

  /// ClipFormData와 EditorMode를 사용하여 클립을 저장합니다.
  Future<void> call({
    required ClipFormData formData,
    required EditorMode mode,
    required String stagedFilePath,
  }) =>
      _service.save(
        formData: formData,
        mode: mode,
        stagedFilePath: stagedFilePath,
      );
}
