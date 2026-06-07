abstract class VideoGenerationRepository {
  /// 프롬프트를 바탕으로 비디오 생성을 요청하고 operationName을 반환합니다.
  Future<String> generateVideo({
    required String dialogue,
    required String scenePrompt,
    required String ratio,
    int duration = 5,
    bool debug = false,
  });

  /// 생성 중인 비디오의 상태를 확인합니다.
  Future<Map<String, dynamic>> checkVideoOperation(String operationName);
}
