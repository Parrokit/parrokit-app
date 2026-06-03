import 'dart:async';

class TtsRemoteDataSource {
  Future<String> generateTts({
    required String text,
    required String voiceType,
  }) async {
    // 실제 서버(Genkit) 연동 대신 2초 대기 후 가상의 파일 경로 반환
    await Future.delayed(const Duration(seconds: 2));
    
    // 성공했다고 가정하고 임시 로컬 파일 경로 반환
    return '/mock/local/path/generated_tts_${DateTime.now().millisecondsSinceEpoch}.mp3';
  }
}
