import 'package:flutter/material.dart';
import '../domain/usecases/generate_tts_usecase.dart';
import '../data/data_sources/tts_remote_data_source.dart';
import '../data/repositories/tts_generation_repository_impl.dart';

class TtsProvider extends ChangeNotifier {
  late final GenerateTtsUseCase _useCase;

  TtsProvider({GenerateTtsUseCase? useCase}) {
    _useCase = useCase ??
        GenerateTtsUseCase(
          TtsGenerationRepositoryImpl(TtsRemoteDataSource()),
        );
  }

  String _text = '';
  String get text => _text;

  String _voiceType = 'female_1';
  String get voiceType => _voiceType;

  bool _isGenerating = false;
  bool get isGenerating => _isGenerating;

  String? _generatedFilePath;
  String? get generatedFilePath => _generatedFilePath;

  String? _errorMessage;
  String? get errorMessage => _errorMessage;

  void updateText(String newText) {
    if (newText.length <= 240) {
      _text = newText;
      notifyListeners();
    }
  }

  void updateVoiceType(String newVoiceType) {
    _voiceType = newVoiceType;
    notifyListeners();
  }

  Future<void> generateTts() async {
    if (_text.trim().isEmpty) return;

    _isGenerating = true;
    _errorMessage = null;
    _generatedFilePath = null;
    notifyListeners();

    try {
      final path = await _useCase.call(
        text: _text,
        voiceType: _voiceType,
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
