import 'package:flutter/material.dart';
import '../../domain/usecases/generate_tts_usecase.dart';
import '../../data/data_sources/tts_remote_data_source.dart';
import '../../data/repositories/tts_generation_repository_impl.dart';
import '../../domain/repositories/tts_generation_repository.dart';

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

  double _speakingRate = 1.0;
  double get speakingRate => _speakingRate;

  double _pitch = 0.0;
  double get pitch => _pitch;

  List<Map<String, dynamic>> _availableVoices = [];
  List<Map<String, dynamic>> get availableVoices => _availableVoices;

  bool _isLoadingVoices = false;
  bool get isLoadingVoices => _isLoadingVoices;

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

  void updateSpeakingRate(double rate) {
    _speakingRate = rate;
    notifyListeners();
  }

  void updatePitch(double newPitch) {
    _pitch = newPitch;
    notifyListeners();
  }

  Future<void> fetchAvailableVoices() async {
    if (_providerType != TtsProviderType.google) return;
    
    _isLoadingVoices = true;
    notifyListeners();

    try {
      final voices = await _useCase.repository.listVoices(_language);
      _availableVoices = voices;
      
      // 언어가 바뀌었는데 현재 선택된 voiceId가 새 언어 목록에 없다면 초기화
      if (_voiceId.isNotEmpty) {
        final exists = voices.any((v) => v['name'] == _voiceId);
        if (!exists) {
          _voiceId = '';
        }
      }
    } catch (e) {
      debugPrint('Failed to load voices: $e');
      _availableVoices = [];
    } finally {
      _isLoadingVoices = false;
      notifyListeners();
    }
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
        speakingRate: _speakingRate,
        pitch: _pitch,
      );
      _generatedFilePath = path;
    } catch (e) {
      _errorMessage = e.toString();
    } finally {
      _isGenerating = false;
      notifyListeners();
    }
  }
  void clearGeneratedAudio() {
    _generatedFilePath = null;
    notifyListeners();
  }
}
