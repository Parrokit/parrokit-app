// ============================================================================
// lib/features/content-studio/captioning/domain/models/edit_mode.dart
// ============================================================================
//
// [역할]
// 에디터 모드 정의 (생성/수정).
//
// [레이어]
// Domain Layer
// ============================================================================

sealed class EditModeBase {
  const EditModeBase();
}

class CreateMode extends EditModeBase {
  const CreateMode();
}

class EditMode extends EditModeBase {
  final int clipId;
  final String? existingFilePath;

  const EditMode({
    required this.clipId,
    this.existingFilePath,
  });
}
