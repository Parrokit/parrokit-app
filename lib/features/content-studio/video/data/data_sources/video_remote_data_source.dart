import 'dart:async';

class VideoRemoteDataSource {
  Future<String> generateVideo({
    required String dialogue,
    required String scenePrompt,
    required String ratio,
  }) async {
    // 실제 서버(Genkit) 연동 대신 3초 대기 후 가상의 파일 경로 반환
    await Future.delayed(const Duration(seconds: 3));
    
    // 성공했다고 가정하고 임시 로컬 파일 경로 반환
    return '/mock/local/path/generated_video_${DateTime.now().millisecondsSinceEpoch}.mp4';
  }
}
