import 'dart:async';
import 'package:cloud_functions/cloud_functions.dart';
import 'package:parrokit/core/shared/utils/app_logger.dart';

class VideoRemoteDataSource {
  final FirebaseFunctions _functions = FirebaseFunctions.instance;

  Future<String> generateVideo({
    required String dialogue,
    required String scenePrompt,
    required String ratio,
    int duration = 5,
    bool debug = false,
  }) async {
    AppLogger.i('[VideoDataSource][Generate] start ratio=$ratio duration=$duration debug=$debug');
    try {
      final callable = _functions.httpsCallable('generateVideo');
      final result = await callable.call<Map<String, dynamic>>({
        'prompt': 'Dialogue: $dialogue\nScene: $scenePrompt',
        'aspectRatio': ratio,
        'duration': duration,
        'debug': debug,
      });

      final operationName = result.data['operationName'] as String;
      AppLogger.i('[VideoDataSource][Generate] success operationName=$operationName');
      return operationName;
    } catch (e, stack) {
      AppLogger.e('[VideoDataSource][Generate] error reason=$e', error: e, stackTrace: stack);
      throw Exception('Failed to generate video: $e');
    }
  }

  Future<Map<String, dynamic>> checkVideoOperation(String operationName) async {
    AppLogger.i('[VideoDataSource][CheckOperation] start operationName=$operationName');
    try {
      final callable = _functions.httpsCallable('getVideoOperationStatus');
      final result = await callable.call<Map<String, dynamic>>({
        'operationName': operationName,
      });

      AppLogger.i('[VideoDataSource][CheckOperation] success done=${result.data['done']}');
      return Map<String, dynamic>.from(result.data);
    } catch (e, stack) {
      AppLogger.e('[VideoDataSource][CheckOperation] error reason=$e', error: e, stackTrace: stack);
      throw Exception('Failed to check video operation: $e');
    }
  }
}
