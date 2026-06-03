import '../../domain/repositories/tts_generation_repository.dart';
import '../data_sources/tts_remote_data_source.dart';

class TtsGenerationRepositoryImpl implements TtsGenerationRepository {
  final TtsRemoteDataSource remoteDataSource;

  const TtsGenerationRepositoryImpl(this.remoteDataSource);

  @override
  Future<String> generateTts({
    required String text,
    required String voiceType,
    String? language,
  }) async {
    return remoteDataSource.generateTts(
      text: text, 
      voiceType: voiceType,
      language: language,
    );
  }
}
