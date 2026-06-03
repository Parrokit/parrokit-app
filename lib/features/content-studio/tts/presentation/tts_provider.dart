import 'package:flutter/material.dart';
import '../domain/usecases/generate_tts_usecase.dart';
import '../data/data_sources/tts_remote_data_source.dart';
import '../data/repositories/tts_generation_repository_impl.dart';
import '../domain/repositories/tts_generation_repository.dart';

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

  String _voiceId = '';
  String get voiceId => _voiceId;

  String _language = 'ko-KR';
  String get language => _language;

  TtsProviderType _providerType = TtsProviderType.google;
  TtsProviderType get providerType => _providerType;

  String? _modelId;
  String? get modelId => _modelId;

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

  void updateVoiceId(String newVoiceId) {
    _voiceId = newVoiceId;
    notifyListeners();
  }

  void updateLanguage(String newLanguage) {
    _language = newLanguage;
    notifyListeners();
  }

  void updateProviderType(TtsProviderType newProviderType) {
    _providerType = newProviderType;
    notifyListeners();
  }

  void updateModelId(String? newModelId) {
    _modelId = newModelId;
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
        language: _language,
        provider: _providerType,
        voiceId: _voiceId.isEmpty ? null : _voiceId,
        modelId: _modelId,
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
