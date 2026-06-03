class TtsValidator {
  static void validateText(String text) {
    if (text.trim().isEmpty) {
      throw Exception('텍스트를 입력해 주세요.');
    }
    if (text.length > 240) {
      throw Exception('텍스트는 240자를 초과할 수 없습니다.');
    }
  }
}
