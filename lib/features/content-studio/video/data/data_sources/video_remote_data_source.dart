import 'dart:async';
import 'package:cloud_functions/cloud_functions.dart';
import 'package:flutter/foundation.dart';

class VideoRemoteDataSource {
  final FirebaseFunctions _functions = FirebaseFunctions.instance;

  Future<String> generateVideo({
    required String dialogue,
    required String scenePrompt,
    required String ratio,
    int duration = 5,
    bool debug = false,
  }) async {
    debugPrint('[VideoDataSource][Generate] start ratio=$ratio duration=$duration debug=$debug');
    try {
      final callable = _functions.httpsCallable('generateVideo');
      final result = await callable.call<Map<String, dynamic>>({
        'prompt': 'Dialogue: $dialogue\nScene: $scenePrompt',
        'aspectRatio': ratio,
        'duration': duration,
        'debug': debug,
      });

      final operationName = result.data['operationName'] as String;
      debugPrint('[VideoDataSource][Generate] success operationName=$operationName');
      return operationName;
    } catch (e) {
      debugPrint('[VideoDataSource][Generate] error reason=$e');
      throw Exception('Failed to generate video: $e');
    }
  }

  Future<Map<String, dynamic>> checkVideoOperation(String operationName) async {
    debugPrint('[VideoDataSource][CheckOperation] start operationName=$operationName');
    try {
      final callable = _functions.httpsCallable('getVideoOperationStatus');
      final result = await callable.call<Map<String, dynamic>>({
        'operationName': operationName,
      });

      debugPrint('[VideoDataSource][CheckOperation] success done=${result.data['done']}');
      return Map<String, dynamic>.from(result.data);
    } catch (e) {
      debugPrint('[VideoDataSource][CheckOperation] error reason=$e');
      throw Exception('Failed to check video operation: $e');
    }
  }
}
