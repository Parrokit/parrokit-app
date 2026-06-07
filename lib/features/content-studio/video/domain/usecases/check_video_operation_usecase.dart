import '../repositories/video_generation_repository.dart';

class CheckVideoOperationUseCase {
  final VideoGenerationRepository repository;

  const CheckVideoOperationUseCase(this.repository);

  Future<Map<String, dynamic>> call(String operationName) async {
    return repository.checkVideoOperation(operationName);
  }
}
