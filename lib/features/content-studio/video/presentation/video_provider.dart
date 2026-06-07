import 'dart:async';
import 'package:flutter/material.dart';
import '../domain/usecases/generate_video_usecase.dart';
import '../domain/usecases/check_video_operation_usecase.dart';
import '../data/data_sources/video_remote_data_source.dart';
import '../data/repositories/video_generation_repository_impl.dart';
import 'package:parrokit/core/shared/utils/app_logger.dart';

class VideoProvider extends ChangeNotifier {
  late final GenerateVideoUseCase _generateUseCase;
  late final CheckVideoOperationUseCase _checkOperationUseCase;

  VideoProvider({
    GenerateVideoUseCase? generateUseCase,
    CheckVideoOperationUseCase? checkOperationUseCase,
  }) {
    final repository = VideoGenerationRepositoryImpl(VideoRemoteDataSource());
    _generateUseCase = generateUseCase ?? GenerateVideoUseCase(repository);
    _checkOperationUseCase = checkOperationUseCase ?? CheckVideoOperationUseCase(repository);
  }

  String _dialogue = '';
  String get dialogue => _dialogue;

  String _scenePrompt = '';
  String get scenePrompt => _scenePrompt;

  String _ratio = '16:9';
  String get ratio => _ratio;

  int _duration = 5;
  int get duration => _duration;

  String _model = 'veo3.1-lite';
  String get model => _model;

  bool _isGenerating = false;
  bool get isGenerating => _isGenerating;

  String? _generatedFilePath;
  String? get generatedFilePath => _generatedFilePath;

  String? _errorMessage;
  String? get errorMessage => _errorMessage;

  Timer? _pollingTimer;

  @override
  void dispose() {
    _pollingTimer?.cancel();
    super.dispose();
  }

  void updateDialogue(String newDialogue) {
    _dialogue = newDialogue;
    notifyListeners();
  }

  void updateScenePrompt(String newPrompt) {
    _scenePrompt = newPrompt;
    notifyListeners();
  }

  void updateRatio(String newRatio) {
    _ratio = newRatio;
    notifyListeners();
  }

  void updateDuration(int newDuration) {
    _duration = newDuration;
    notifyListeners();
  }

  void updateModel(String newModel) {
    _model = newModel;
    notifyListeners();
  }

  Future<void> generateVideo() async {
    if (_dialogue.trim().isEmpty && _scenePrompt.trim().isEmpty) return;

    _isGenerating = true;
    _errorMessage = null;
    _generatedFilePath = null;
    notifyListeners();

    AppLogger.i('[VideoProvider][Generate] start ratio=$_ratio duration=$_duration model=$_model');

    try {
      final operationName = await _generateUseCase.call(
        dialogue: _dialogue,
        scenePrompt: _scenePrompt,
        ratio: _ratio,
        duration: _duration,
        model: _model,
        debug: true, // 디버그 모드 기본 켜짐
      );
      
      AppLogger.i('[VideoProvider][Generate] success operationName=$operationName');
      _startPolling(operationName);
    } catch (e, stack) {
      AppLogger.e('[VideoProvider][Generate] error reason=$e', error: e, stackTrace: stack);
      _errorMessage = e.toString();
      _isGenerating = false;
      notifyListeners();
    }
  }

  void _startPolling(String operationName) {
    AppLogger.i('[VideoProvider][Polling] start operationName=$operationName');
    _pollingTimer?.cancel();
    _pollingTimer = Timer.periodic(const Duration(seconds: 5), (timer) async {
      AppLogger.d('[VideoProvider][Polling] check operationName=$operationName');
      try {
        final result = await _checkOperationUseCase.call(operationName);
        if (result['done'] == true) {
          timer.cancel();
          if (result['error'] != null) {
            AppLogger.e('[VideoProvider][Polling] error reason=${result['error']}');
            _errorMessage = result['error'].toString();
          } else {
            AppLogger.i('[VideoProvider][Polling] success videoUri=${result['videoUri']}');
            _generatedFilePath = result['videoUri'];
          }
          _isGenerating = false;
          notifyListeners();
        }
      } catch (e, stack) {
        AppLogger.e('[VideoProvider][Polling] error reason=$e', error: e, stackTrace: stack);
        timer.cancel();
        _errorMessage = 'Polling failed: $e';
        _isGenerating = false;
        notifyListeners();
      }
    });
  }
}
