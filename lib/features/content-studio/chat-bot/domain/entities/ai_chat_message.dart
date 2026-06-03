class AiChatMessage {
  final String text;
  final bool isUser;
  final String? recommendedPrompt;
  final String? actionType;

  const AiChatMessage({
    required this.text,
    required this.isUser,
    this.recommendedPrompt,
    this.actionType,
  });
}
