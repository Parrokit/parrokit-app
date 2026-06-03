class AiChatMessage {
  final String text;
  final bool isUser;
  final String? recommendedPrompt;
  final String? actionType;
  final Map<String, dynamic>? actionData;
  final String? chatbotMode; // 메시지 생성 당시의 에이전트 모드

  const AiChatMessage({
    required this.text,
    required this.isUser,
    this.recommendedPrompt,
    this.actionType,
    this.actionData,
    this.chatbotMode,
  });

  AiChatMessage copyWith({
    String? text,
    bool? isUser,
    String? recommendedPrompt,
    String? actionType,
    Map<String, dynamic>? actionData,
    String? chatbotMode,
  }) {
    return AiChatMessage(
      text: text ?? this.text,
      isUser: isUser ?? this.isUser,
      recommendedPrompt: recommendedPrompt ?? this.recommendedPrompt,
      actionType: actionType ?? this.actionType,
      actionData: actionData ?? this.actionData,
      chatbotMode: chatbotMode ?? this.chatbotMode,
    );
  }
}
