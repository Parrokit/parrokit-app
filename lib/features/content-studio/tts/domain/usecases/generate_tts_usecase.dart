import '../repositories/tts_generation_repository.dart';
import '../validators/tts_validator.dart';

class GenerateTtsUseCase {
  final TtsGenerationRepository repository;

  const GenerateTtsUseCase(this.repository);

  Future<String> call({
    required String text, 
    required String voiceType,
    String? language,
  }) async {
    TtsValidator.validateText(text);
    // TODO: 패롯(재화) 잔액 검증 로직 추가 (NFR-TTS-03)
    return repository.generateTts(
      text: text, 
      voiceType: voiceType,
      language: language,
    );
  }
}
