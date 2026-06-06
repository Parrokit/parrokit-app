class TtsGeminiModel {
  final String id;
  final String name;
  final String description;

  const TtsGeminiModel({
    required this.id,
    required this.name,
    required this.description,
  });
}

class TtsGeminiVoice {
  final String id;
  final String name;
  final String description;

  const TtsGeminiVoice({
    required this.id,
    required this.name,
    required this.description,
  });
}

const List<TtsGeminiModel> geminiModels = [
  TtsGeminiModel(
    id: 'gemini-2.5-flash',
    name: 'Gemini 2.5 Flash',
    description: '빠르고 범용적인 음성 합성에 적합',
  ),
  TtsGeminiModel(
    id: 'gemini-2.5-flash-lite-preview',
    name: 'Gemini 2.5 Flash-Lite 프리뷰',
    description: '더 빠르고 가벼운 음성 합성',
  ),
  TtsGeminiModel(
    id: 'gemini-3.1-flash',
    name: 'Gemini 3.1 Flash 프리뷰',
    description: '최신 프리뷰 모델',
  ),
  TtsGeminiModel(
    id: 'gemini-2.5-pro',
    name: 'Gemini 2.5 Pro',
    description: '최상의 품질과 복잡한 추론',
  ),
];

const List<TtsGeminiVoice> geminiVoices = [
  TtsGeminiVoice(
    id: 'Aoede',
    name: 'Aoede',
    description: '차분하고 명확한 음성',
  ),
  TtsGeminiVoice(
    id: 'Puck',
    name: 'Puck',
    description: '에너지 넘치는 친근한 음성',
  ),
  TtsGeminiVoice(
    id: 'Charon',
    name: 'Charon',
    description: '진중하고 신뢰감 있는 음성',
  ),
  TtsGeminiVoice(
    id: 'Kore',
    name: 'Kore',
    description: '부드럽고 따뜻한 음성',
  ),
  TtsGeminiVoice(
    id: 'Fenrir',
    name: 'Fenrir',
    description: '강력하고 묵직한 음성',
  ),
];
