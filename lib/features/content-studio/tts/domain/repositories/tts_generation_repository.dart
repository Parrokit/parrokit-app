enum TtsProviderType {
  google,
  elevenlabs,
}

class ElevenLabsVoiceSettings {
  final double? stability;
  final double? similarityBoost;
  final double? style;
  final bool? useSpeakerBoost;

  const ElevenLabsVoiceSettings({
    this.stability,
    this.similarityBoost,
    this.style,
    this.useSpeakerBoost,
  });

  Map<String, dynamic> toJson() => {
    if (stability != null) 'stability': stability,
    if (similarityBoost != null) 'similarity_boost': similarityBoost,
    if (style != null) 'style': style,
    if (useSpeakerBoost != null) 'use_speaker_boost': useSpeakerBoost,
  };
}

abstract class TtsGenerationRepository {
  /// TTS를 생성하고 로컬에 임시 저장된 오디오 파일 경로를 반환합니다.
  Future<String> generateTts({
    required String text,
    required String language,
    TtsProviderType provider = TtsProviderType.google,
    String? voiceId,
    String? modelId,
    ElevenLabsVoiceSettings? elevenLabsSettings,
  });
}
