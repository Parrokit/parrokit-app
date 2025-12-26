// ============================================================================
// lib/features/_content/clip_editor/data/usecases/load_clip_for_edit_usecase.dart
// ============================================================================
//
// [역할]
// 기존 클립 데이터를 편집용으로 로드하는 UseCase.
// 실제 로직은 ClipLoadService에 위임.
//
// [레이어]
// Data Layer > UseCases
// ============================================================================

import '../services/clip_load_service.dart';

export '../services/clip_load_service.dart' show LoadClipResult;

/// 기존 클립을 편집용으로 로드하는 UseCase.
class LoadClipForEditUseCase {
  final ClipLoadService _service;

  LoadClipForEditUseCase({required ClipLoadService service})
      : _service = service;

  /// 클립 ID로 편집 데이터를 로드합니다.
  Future<LoadClipResult> call(int clipId) => _service.loadForEdit(clipId);
}
