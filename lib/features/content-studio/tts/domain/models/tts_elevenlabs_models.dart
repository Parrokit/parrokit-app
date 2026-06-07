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

class TtsElevenLabsModel {
  final String id;
  final String name;
  final String description;

  const TtsElevenLabsModel({
    required this.id,
    required this.name,
    required this.description,
  });
}

const List<TtsElevenLabsModel> elevenLabsModels = [
  TtsElevenLabsModel(
    id: 'eleven_multilingual_v2',
    name: 'Multilingual v2',
    description: '고품질의 다국어 음성 모델 (가장 자연스러움)',
  ),
  TtsElevenLabsModel(
    id: 'eleven_turbo_v2_5',
    name: 'Turbo v2.5',
    description: '매우 빠른 속도와 고품질, 다국어 지원',
  ),
  TtsElevenLabsModel(
    id: 'eleven_turbo_v2',
    name: 'Turbo v2',
    description: '빠른 생성 속도를 자랑하는 모델 (영어 위주)',
  ),
  TtsElevenLabsModel(
    id: 'eleven_multilingual_v1',
    name: 'Multilingual v1',
    description: '구버전 다국어 모델',
  ),
];
