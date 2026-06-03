import 'package:flutter/material.dart';
import '../domain/entities/ai_chat_message.dart';
import '../domain/usecases/send_chat_message_usecase.dart';
import '../data/data_sources/ai_chat_remote_data_source.dart';
import '../data/repositories/ai_chat_repository_impl.dart';

class ChatBotProvider extends ChangeNotifier {
  late final SendChatMessageUseCase _sendMessageUseCase;

  final List<AiChatMessage> _messages = [
    const AiChatMessage(
      text: '안녕하세요! TTS 생성 및 비디오 생성을 도와드릴 챗봇입니다.\n어떤 영상이나 음성을 만들고 싶으신가요?',
      isUser: false,
    ),
  ];

  ChatBotProvider({SendChatMessageUseCase? useCase}) {
    // 임시 의존성 주입 (차후 get_it 등으로 교체 가능)
    _sendMessageUseCase = useCase ??
        SendChatMessageUseCase(
          AiChatRepositoryImpl(AiChatRemoteDataSource()),
        );
  }

  List<AiChatMessage> get messages => _messages;

  bool _isTyping = false;
  bool get isTyping => _isTyping;

  Future<void> sendMessage(String text) async {
    if (text.trim().isEmpty) return;

    // 사용자 메시지 추가
    _messages.insert(0, AiChatMessage(text: text, isUser: true));
    _isTyping = true;
    notifyListeners();

    try {
      // AI 응답 (프롬프트 추천 및 액션 버튼 포함 가능성)
      final aiResponse = await _sendMessageUseCase.call(text);
      _messages.insert(0, aiResponse);
    } catch (e) {
      _messages.insert(
        0,
        const AiChatMessage(text: '오류가 발생했습니다. 다시 시도해 주세요.', isUser: false),
      );
    } finally {
      _isTyping = false;
      notifyListeners();
    }
  }
}
