import 'package:cloud_functions/cloud_functions.dart';
import '../../domain/entities/ai_chat_message.dart';

class AiChatRemoteDataSource {
  Future<Map<String, dynamic>> sendMessage(String text, List<AiChatMessage> history) async {
    // 1. 대화 기록을 Genkit 및 Cloud Functions 요구 구조로 매핑 (시간순 정렬을 위해 reversed 적용)
    final historyData = history.reversed.map((msg) {
      return {
        'role': msg.isUser ? 'user' : 'model',
        'text': msg.text,
      };
    }).toList();

    // 2. Firebase Cloud Functions 호출
    final callable = FirebaseFunctions.instance.httpsCallable('generateChatbotResponse');

    final response = await callable.call({
      'message': text,
      'history': historyData,
    });

    final String aiText = response.data as String;

    // 3. AI 응답 텍스트로부터 액션 타입 및 프롬프트 추천 파싱 규칙 적용
    String? actionType;
    String? recommendedPrompt;

    final promptMatch = RegExp(r'["“]([^"“]+)["”]').firstMatch(aiText);
    final extracted = promptMatch?.group(1)?.trim();

    if (aiText.contains('영상') || aiText.contains('비디오') || aiText.contains('장면')) {
      actionType = 'video';
      recommendedPrompt = extracted ?? '푸른 하늘을 날아오르는 화려한 깃털의 앵무새, 시네마틱 4k';
    } else if (aiText.contains('음성') || aiText.contains('tts') || aiText.contains('TTS') || aiText.contains('목소리') || aiText.contains('대사')) {
      actionType = 'tts';
      recommendedPrompt = extracted ?? text;
    }

    return {
      'text': aiText,
      'recommendedPrompt': recommendedPrompt,
      'actionType': actionType,
    };
  }
}
