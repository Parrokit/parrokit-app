class TtsElevenLabsVoice {
  final String id;
  final String name;
  final String category;
  final String language;
  
  const TtsElevenLabsVoice({
    required this.id,
    required this.name,
    required this.category,
    required this.language,
  });

  factory TtsElevenLabsVoice.fromJson(Map<String, dynamic> json) {
    return TtsElevenLabsVoice(
      id: (json['voice_id'] ?? json['voiceId']) as String? ?? '',
      name: json['name'] as String? ?? '',
      category: json['category'] as String? ?? '',
      language: 'en', // ElevenLabs는 다국어 모델을 쓰면 언어가 동적이 되지만, 기본적으로 속성에는 en 등 라벨을 쓰기도 합니다.
    );
  }
}
