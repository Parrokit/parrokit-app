// ============================================================================
// lib/features/_content/clip_editor/domain/editor_mode.dart
// ============================================================================
//
// [역할]
// 에디터 모드 정의 (생성/수정).
//
// [레이어]
// Domain Layer
// ============================================================================

/// 에디터 모드 (생성 또는 수정).
sealed class EditorMode {
  const EditorMode();
}

/// 새 클립 생성 모드.
class CreateMode extends EditorMode {
  const CreateMode();
}

/// 기존 클립 수정 모드.
class EditMode extends EditorMode {
  final int clipId;
  final String? existingFilePath;

  const EditMode({
    required this.clipId,
    this.existingFilePath,
  });
}
