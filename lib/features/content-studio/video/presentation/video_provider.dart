import 'dart:async';
import 'dart:io';

import 'package:path_provider/path_provider.dart';
import 'package:flutter/material.dart';
import '../domain/usecases/generate_video_usecase.dart';
import '../domain/usecases/check_video_operation_usecase.dart';
import '../domain/usecases/list_recent_video_generations_usecase.dart';
import '../data/data_sources/video_remote_data_source.dart';
import '../data/repositories/video_generation_repository_impl.dart';
import '../domain/models/video_generation_models.dart';
import 'package:parrokit/core/shared/utils/app_logger.dart';

class VideoProvider extends ChangeNotifier {
  late final GenerateVideoUseCase _generateUseCase;
  late final CheckVideoOperationUseCase _checkOperationUseCase;
  late final ListRecentVideoGenerationsUseCase _listRecentUseCase;

  VideoProvider({
    GenerateVideoUseCase? generateUseCase,
    CheckVideoOperationUseCase? checkOperationUseCase,
    ListRecentVideoGenerationsUseCase? listRecentUseCase,
  }) {
    final repository = VideoGenerationRepositoryImpl(VideoRemoteDataSource());
    _generateUseCase = generateUseCase ?? GenerateVideoUseCase(repository);
    _checkOperationUseCase =
        checkOperationUseCase ?? CheckVideoOperationUseCase(repository);
    _listRecentUseCase =
        listRecentUseCase ?? ListRecentVideoGenerationsUseCase(repository);
  }

  String _dialogue = '';
  String get dialogue => _dialogue;

  String _scenePrompt = '';
  String get scenePrompt => _scenePrompt;

  String _ratio = '16:9';
  String get ratio => _ratio;

  int _duration = 5;
  int get duration => _duration;

  String _model = veo31LiteModelId;
  String get model => _model;

  bool _isGenerating = false;
  bool get isGenerating => _isGenerating;

  String? _generatedFilePath;
  String? get generatedFilePath => _generatedFilePath;

  String? _errorMessage;
  String? get errorMessage => _errorMessage;

  bool _isExportingForCaptioning = false;
  bool get isExportingForCaptioning => _isExportingForCaptioning;

  List<VideoGenerationRecord> _recentVideos = const [];
  List<VideoGenerationRecord> get recentVideos => _recentVideos;

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

  void showSavedVideo(String videoUrl) {
    _generatedFilePath = videoUrl;
    _errorMessage = null;
    notifyListeners();
  }

  Future<String?> prepareGeneratedVideoForCaptioning() async {
    final source = _generatedFilePath;
    if (source == null || source.isEmpty) {
      return null;
    }

    if (source.startsWith('file://')) {
      return Uri.parse(source).toFilePath();
    }

    if (source.startsWith('/')) {
      return source;
    }

    if (source.startsWith('data:')) {
      return null;
    }

    _isExportingForCaptioning = true;
    notifyListeners();

    try {
      final client = HttpClient();
      final request = await client.getUrl(Uri.parse(source));
      final response = await request.close();
      if (response.statusCode < 200 || response.statusCode >= 300) {
        throw Exception('download failed: ${response.statusCode}');
      }

      final tempDir = await getTemporaryDirectory();
      final file = File(
        '${tempDir.path}/parrokit_caption_video_${DateTime.now().millisecondsSinceEpoch}.mp4',
      );
      final sink = file.openWrite();
      await response.pipe(sink);
      await sink.close();
      return file.path;
    } catch (e, stack) {
      AppLogger.e('[VideoProvider][ExportToCaptioning] error reason=$e',
          error: e, stackTrace: stack);
      _errorMessage = '캡션 편집기로 보낼 영상을 준비하지 못했습니다.';
      notifyListeners();
      return null;
    } finally {
      _isExportingForCaptioning = false;
      notifyListeners();
    }
  }

  Future<void> loadRecentVideos() async {
    AppLogger.i('[VideoProvider][Recent] start');
    try {
      _recentVideos = await _listRecentUseCase.call();
      AppLogger.i(
          '[VideoProvider][Recent] success count=${_recentVideos.length}');
      notifyListeners();
    } catch (e, stack) {
      AppLogger.e('[VideoProvider][Recent] error reason=$e',
          error: e, stackTrace: stack);
    }
  }

  Future<void> generateVideo() async {
    if (_dialogue.trim().isEmpty && _scenePrompt.trim().isEmpty) return;

    _isGenerating = true;
    _errorMessage = null;
    _generatedFilePath = null;
    notifyListeners();

    AppLogger.i(
        '[VideoProvider][Generate] start ratio=$_ratio duration=$_duration model=$_model');

    try {
      final operationName = await _generateUseCase.call(
        dialogue: _dialogue,
        scenePrompt: _scenePrompt,
        ratio: _ratio,
        duration: _duration,
        model: _model,
        debug: false,
      );

      AppLogger.i(
          '[VideoProvider][Generate] success operationName=$operationName');
      _startPolling(operationName);
    } catch (e, stack) {
      AppLogger.e('[VideoProvider][Generate] error reason=$e',
          error: e, stackTrace: stack);
      _errorMessage = e.toString();
      _isGenerating = false;
      notifyListeners();
    }
  }

  void _startPolling(String operationName) {
    AppLogger.i('[VideoProvider][Polling] start operationName=$operationName');
    _pollingTimer?.cancel();
    _pollingTimer = Timer.periodic(const Duration(seconds: 5), (timer) async {
      AppLogger.d(
          '[VideoProvider][Polling] check operationName=$operationName');
      try {
        final result = await _checkOperationUseCase.call(operationName);
        if (result['done'] == true) {
          timer.cancel();
          if (result['error'] != null) {
            AppLogger.e(
                '[VideoProvider][Polling] error reason=${result['error']}');
            _errorMessage = result['error'].toString();
          } else {
            AppLogger.i(
                '[VideoProvider][Polling] success videoUri=${result['videoUri']}');
            _generatedFilePath = result['videoUri'];
            await loadRecentVideos();
          }
          _isGenerating = false;
          notifyListeners();
        }
      } catch (e, stack) {
        AppLogger.e('[VideoProvider][Polling] error reason=$e',
            error: e, stackTrace: stack);
        timer.cancel();
        _errorMessage = 'Polling failed: $e';
        _isGenerating = false;
        notifyListeners();
      }
    });
  }
}
