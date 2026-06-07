import '../../domain/repositories/tts_generation_repository.dart';
import '../data_sources/tts_remote_data_source.dart';

class TtsGenerationRepositoryImpl implements TtsGenerationRepository {
  final TtsRemoteDataSource remoteDataSource;

  const TtsGenerationRepositoryImpl(this.remoteDataSource);

  @override
  Future<String> generateTts({
    required String text,
    required String language,
    TtsProviderType provider = TtsProviderType.google,
    String? voiceId,
    String? modelId,
    double? speakingRate,
    double? pitch,
    ElevenLabsVoiceSettings? elevenLabsSettings,
  }) async {
    return remoteDataSource.generateTts(
      text: text, 
      language: language,
      provider: provider,
      voiceId: voiceId,
      modelId: modelId,
      speakingRate: speakingRate,
      pitch: pitch,
      elevenLabsSettings: elevenLabsSettings,
    );
  }

  @override
  Future<List<Map<String, dynamic>>> listVoices(String languageCode) async {
    return remoteDataSource.listVoices(languageCode);
  }
}
