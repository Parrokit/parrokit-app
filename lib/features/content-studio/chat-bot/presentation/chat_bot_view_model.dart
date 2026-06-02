import 'package:flutter/material.dart';

class ChatMessage {
  final String text;
  final bool isUser;

  const ChatMessage({
    required this.text,
    required this.isUser,
  });
}

class ChatBotViewModel extends ChangeNotifier {
  final List<ChatMessage> _messages = [
    const ChatMessage(
      text: '안녕하세요! TTS 생성 및 비디오 생성을 도와드릴 챗봇입니다.\n어떤 작업을 원하시나요?',
      isUser: false,
    ),
  ];

  List<ChatMessage> get messages => _messages;

  bool _isTyping = false;
  bool get isTyping => _isTyping;

  void sendMessage(String text) {
    if (text.trim().isEmpty) return;
    
    _messages.insert(0, ChatMessage(text: text, isUser: true));
    notifyListeners();

    _simulateBotResponse();
  }

  void _simulateBotResponse() async {
    _isTyping = true;
    notifyListeners();

    // 임시 지연 효과
    await Future.delayed(const Duration(seconds: 1));

    _messages.insert(0, const ChatMessage(
      text: '아직 준비 중인 기능입니다. 초안 확인 후 실제 AI 연동을 진행해 주세요!',
      isUser: false,
    ));
    _isTyping = false;
    notifyListeners();
  }
}
