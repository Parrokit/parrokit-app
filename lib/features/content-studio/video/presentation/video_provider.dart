import 'package:flutter/material.dart';
import '../domain/usecases/generate_video_usecase.dart';
import '../data/data_sources/video_remote_data_source.dart';
import '../data/repositories/video_generation_repository_impl.dart';

class VideoProvider extends ChangeNotifier {
  late final GenerateVideoUseCase _useCase;

  VideoProvider({GenerateVideoUseCase? useCase}) {
    _useCase = useCase ??
        GenerateVideoUseCase(
          VideoGenerationRepositoryImpl(VideoRemoteDataSource()),
        );
  }

  String _dialogue = '';
  String get dialogue => _dialogue;

  String _scenePrompt = '';
  String get scenePrompt => _scenePrompt;

  String _ratio = '16:9';
  String get ratio => _ratio;

  bool _isGenerating = false;
  bool get isGenerating => _isGenerating;

  String? _generatedFilePath;
  String? get generatedFilePath => _generatedFilePath;

  String? _errorMessage;
  String? get errorMessage => _errorMessage;

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

  Future<void> generateVideo() async {
    if (_dialogue.trim().isEmpty && _scenePrompt.trim().isEmpty) return;

    _isGenerating = true;
    _errorMessage = null;
    _generatedFilePath = null;
    notifyListeners();

    try {
      final path = await _useCase.call(
        dialogue: _dialogue,
        scenePrompt: _scenePrompt,
        ratio: _ratio,
      );
      _generatedFilePath = path;
    } catch (e) {
      _errorMessage = e.toString();
    } finally {
      _isGenerating = false;
      notifyListeners();
    }
  }
}
