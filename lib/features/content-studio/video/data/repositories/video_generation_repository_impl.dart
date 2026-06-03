import '../../domain/repositories/video_generation_repository.dart';
import '../data_sources/video_remote_data_source.dart';

class VideoGenerationRepositoryImpl implements VideoGenerationRepository {
  final VideoRemoteDataSource remoteDataSource;

  const VideoGenerationRepositoryImpl(this.remoteDataSource);

  @override
  Future<String> generateVideo({
    required String dialogue,
    required String scenePrompt,
    required String ratio,
  }) async {
    return remoteDataSource.generateVideo(
      dialogue: dialogue,
      scenePrompt: scenePrompt,
      ratio: ratio,
    );
  }
}
