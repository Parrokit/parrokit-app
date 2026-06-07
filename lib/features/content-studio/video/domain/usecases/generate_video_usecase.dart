import '../repositories/video_generation_repository.dart';
import '../validators/video_validator.dart';

class GenerateVideoUseCase {
  final VideoGenerationRepository repository;

  const GenerateVideoUseCase(this.repository);

  Future<String> call({
    required String dialogue,
    required String scenePrompt,
    required String ratio,
    int duration = 5,
    String model = 'veo3.1-lite',
    bool debug = false,
  }) async {
    VideoValidator.validatePrompts(dialogue: dialogue, scenePrompt: scenePrompt);
    // TODO: 패롯(재화) 잔액 검증 로직 추가 (NFR-VID-09)
    return repository.generateVideo(
      dialogue: dialogue,
      scenePrompt: scenePrompt,
      ratio: ratio,
      duration: duration,
      model: model,
      debug: debug,
    );
  }
}
