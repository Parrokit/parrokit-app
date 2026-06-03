import 'package:cloud_functions/cloud_functions.dart';
import '../../domain/entities/ai_chat_message.dart';

class AiChatRemoteDataSource {
  Future<Map<String, dynamic>> sendMessage(String text, List<AiChatMessage> history, String model) async {
    // 1. 대화 기록을 Genkit 및 Cloud Functions 요구 구조로 매핑 (시간순 정렬)
    final mappedHistory = history.reversed.map((msg) {
      return {
        'role': msg.isUser ? 'user' : 'model',
        'text': msg.text,
      };
    }).toList();

    // 2. Gemini 대화 시작 규칙 준수: 첫 시작은 반드시 'user'이어야 하므로 
    // 첫 'user' 메시지가 나타나기 전의 앞선 'model' 메시지(예: 최초 웰컴 메시지)들은 제외합니다.
    final firstUserIndex = mappedHistory.indexWhere((msg) => msg['role'] == 'user');
    final List<Map<String, String>> historyData = firstUserIndex != -1
        ? mappedHistory.sublist(firstUserIndex)
        : [];

    // 3. Firebase Cloud Functions 호출
    final callable = FirebaseFunctions.instance.httpsCallable('generateChatbotResponse');

    final response = await callable.call({
      'message': text,
      'history': historyData,
      'model': model,
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
