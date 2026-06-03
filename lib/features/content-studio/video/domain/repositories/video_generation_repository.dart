abstract class VideoGenerationRepository {
  /// 프롬프트를 바탕으로 비디오를 생성하고 로컬 임시 파일 경로를 반환합니다.
  Future<String> generateVideo({
    required String dialogue,
    required String scenePrompt,
    required String ratio,
  });
}
