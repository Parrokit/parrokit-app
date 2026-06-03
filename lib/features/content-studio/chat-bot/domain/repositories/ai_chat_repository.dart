import '../entities/ai_chat_message.dart';

abstract class AiChatRepository {
  Future<AiChatMessage> sendMessage(String text);
}
