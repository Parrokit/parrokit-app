import 'dart:async';

class AiChatRemoteDataSource {
  Future<Map<String, dynamic>> sendMessage(String text) async {
    await Future.delayed(const Duration(seconds: 2));

    if (text.contains('영상') || text.contains('비디오')) {
      return {
        'text': '이 프롬프트를 추천해 드려요! 마음에 드시면 아래 버튼을 눌러 바로 영상을 생성할 수 있습니다.',
        'recommendedPrompt': '푸른 하늘을 날아오르는 화려한 깃털의 앵무새, 시네마틱 4k',
        'actionType': 'video',
      };
    } else if (text.contains('음성') || text.contains('tts') || text.contains('TTS') || text.contains('목소리')) {
      return {
        'text': '멋진 대사네요! 이 대사로 바로 음성을 생성할까요?',
        'recommendedPrompt': text,
        'actionType': 'tts',
      };
    } else {
      return {
        'text': 'TTS나 Video 생성에 대해 무엇이든 물어보세요! 제가 더 좋은 프롬프트로 다듬어드릴게요.',
        'recommendedPrompt': null,
        'actionType': null,
      };
    }
  }
}
