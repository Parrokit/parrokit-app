class AiChatMessage {
  final String text;
  final bool isUser;
  final String? recommendedPrompt;
  final String? actionType;
  final Map<String, dynamic>? actionData;

  const AiChatMessage({
    required this.text,
    required this.isUser,
    this.recommendedPrompt,
    this.actionType,
    this.actionData,
  });
}
