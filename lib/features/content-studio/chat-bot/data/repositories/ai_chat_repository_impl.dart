import '../../domain/entities/ai_chat_message.dart';
import '../../domain/repositories/ai_chat_repository.dart';
import '../data_sources/ai_chat_remote_data_source.dart';

class AiChatRepositoryImpl implements AiChatRepository {
  final AiChatRemoteDataSource remoteDataSource;

  const AiChatRepositoryImpl(this.remoteDataSource);

  @override
  Future<AiChatMessage> sendMessage(String text, List<AiChatMessage> history, String model) async {
    final response = await remoteDataSource.sendMessage(text, history, model);
    return AiChatMessage(
      text: response['text'] as String,
      isUser: false,
      recommendedPrompt: response['recommendedPrompt'] as String?,
      actionType: response['actionType'] as String?,
    );
  }
}
