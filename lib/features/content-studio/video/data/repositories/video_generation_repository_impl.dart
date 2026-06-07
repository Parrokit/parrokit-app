import 'package:flutter/foundation.dart';
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
    int duration = 5,
    bool debug = false,
  }) async {
    debugPrint('[VideoRepository][Generate] start ratio=$ratio duration=$duration debug=$debug');
    try {
      final result = await remoteDataSource.generateVideo(
        dialogue: dialogue,
        scenePrompt: scenePrompt,
        ratio: ratio,
        duration: duration,
        debug: debug,
      );
      debugPrint('[VideoRepository][Generate] success');
      return result;
    } catch (e) {
      debugPrint('[VideoRepository][Generate] error reason=$e');
      rethrow;
    }
  }

  @override
  Future<Map<String, dynamic>> checkVideoOperation(String operationName) async {
    debugPrint('[VideoRepository][CheckOperation] start operationName=$operationName');
    try {
      final result = await remoteDataSource.checkVideoOperation(operationName);
      debugPrint('[VideoRepository][CheckOperation] success');
      return result;
    } catch (e) {
      debugPrint('[VideoRepository][CheckOperation] error reason=$e');
      rethrow;
    }
  }
}
