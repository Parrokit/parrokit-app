// ============================================================================
// lib/features/content-studio/captioning/domain/models/editor_mode.dart
// ============================================================================
//
// [역할]
// 에디터 모드 정의 (생성/수정).
//
// [레이어]
// Domain Layer
// ============================================================================

sealed class EditorMode {
  const EditorMode();
}

class CreateMode extends EditorMode {
  const CreateMode();
}

class EditMode extends EditorMode {
  final int clipId;
  final String? existingFilePath;

  const EditMode({
    required this.clipId,
    this.existingFilePath,
  });
}
