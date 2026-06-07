class TtsLanguage {
  final String mlKitCode;
  final String ttsCode;
  final String displayName;

  const TtsLanguage({
    required this.mlKitCode,
    required this.ttsCode,
    required this.displayName,
  });
}

const List<TtsLanguage> supportedTtsLanguages = [
  TtsLanguage(mlKitCode: 'ko', ttsCode: 'ko-KR', displayName: '한국어 (ko-KR)'),
  TtsLanguage(mlKitCode: 'en', ttsCode: 'en-US', displayName: '영어 (en-US)'),
  TtsLanguage(mlKitCode: 'ja', ttsCode: 'ja-JP', displayName: '일본어 (ja-JP)'),
  TtsLanguage(mlKitCode: 'zh', ttsCode: 'cmn-CN', displayName: '중국어 (cmn-CN)'),
  TtsLanguage(mlKitCode: 'es', ttsCode: 'es-ES', displayName: '스페인어 (es-ES)'),
  TtsLanguage(mlKitCode: 'fr', ttsCode: 'fr-FR', displayName: '프랑스어 (fr-FR)'),
  TtsLanguage(mlKitCode: 'de', ttsCode: 'de-DE', displayName: '독일어 (de-DE)'),
];

TtsLanguage? getLanguageByMlKitCode(String code) {
  try {
    return supportedTtsLanguages.firstWhere((lang) => lang.mlKitCode == code);
  } catch (e) {
    return null;
  }
}

TtsLanguage getLanguageByTtsCode(String code) {
  try {
    return supportedTtsLanguages.firstWhere((lang) => lang.ttsCode == code);
  } catch (e) {
    return supportedTtsLanguages.first; // 기본값 한국어
  }
}
