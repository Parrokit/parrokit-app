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

  String _selectedModel = 'gemini-2.5-flash';
  String get selectedModel => _selectedModel;

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

  void updateSelectedModel(String model) {
    if (_selectedModel != model) {
      _selectedModel = model;
      notifyListeners();
    }
  }

  String _chatbotMode = 'general';
  String get chatbotMode => _chatbotMode;

  void updateChatbotMode(String mode) {
    if (_chatbotMode != mode) {
      _chatbotMode = mode;
      notifyListeners();
    }
  }

  bool _hasPendingRouting = false;
  bool get hasPendingRouting => _hasPendingRouting;

  void consumePendingRouting() {
    if (_hasPendingRouting) {
      _hasPendingRouting = false;
      notifyListeners();
    }
  }

  void resetChatbot() {
    _chatbotMode = 'general';
    _hasPendingRouting = false;
    _messages.clear();
    _messages.insert(
      0,
      const AiChatMessage(
        text: '안녕하세요! TTS 생성 및 비디오 생성을 도와드릴 챗봇입니다.\n어떤 영상이나 음성을 만들고 싶으신가요?',
        isUser: false,
      ),
    );
    notifyListeners();
  }

  Future<void> sendMessage(String text) async {
    if (text.trim().isEmpty) return;

    // 현재까지의 대화 목록 복사 (새 사용자 메시지 추가 전)
    final history = List<AiChatMessage>.from(_messages);

    // 사용자 메시지 추가
    _messages.insert(0, AiChatMessage(text: text, isUser: true));
    _isTyping = true;
    notifyListeners();

    try {
      debugPrint('[Chatbot][Provider] Calling sendMessageUseCase text=$text chatbotMode=$_chatbotMode');
      // AI 응답 호출 (대화 히스토리, 모델 정보, 챗봇 모드 포함)
      final aiResponse = await _sendMessageUseCase.call(text, history, _selectedModel, _chatbotMode);
      
      // AI 응답의 actionType이 change_mode인 경우, 클라이언트의 챗봇 모드 전환 처리
      if (aiResponse.actionType == 'change_mode' && aiResponse.actionData != null) {
        final targetMode = aiResponse.actionData!['targetMode'] as String?;
        if (targetMode != null) {
          _chatbotMode = targetMode;
          debugPrint('[Chatbot][Provider] Mode changed dynamically targetMode=$_chatbotMode');
        }
      }
      
      debugPrint('[Chatbot][Provider] AI Response actionType=${aiResponse.actionType} actionData=${aiResponse.actionData}');

      if (aiResponse.actionType == 'ask_routing') {
        _hasPendingRouting = true;
        debugPrint('[Chatbot][Provider] Routing action pending flag set to true');
      }

      debugPrint('[Chatbot][Provider] Send message success replyLength=${aiResponse.text.length} actionType=${aiResponse.actionType}');
      _messages.insert(0, aiResponse);
    } catch (e) {
      debugPrint('[Chatbot][Provider] Send message failed error=$e');
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
