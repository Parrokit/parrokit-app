import '../models/video_generation_models.dart';
import '../repositories/video_generation_repository.dart';

class ListRecentVideoGenerationsUseCase {
  final VideoGenerationRepository repository;

  const ListRecentVideoGenerationsUseCase(this.repository);

  Future<List<VideoGenerationRecord>> call() async {
    return repository.listRecentVideoGenerations();
  }
}
