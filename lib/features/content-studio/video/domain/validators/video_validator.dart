class VideoValidator {
  static void validatePrompts({
    required String dialogue,
    required String scenePrompt,
  }) {
    if (dialogue.trim().isEmpty && scenePrompt.trim().isEmpty) {
      throw Exception('대사나 상황 프롬프트 중 하나는 입력해야 합니다.');
    }
  }
}
