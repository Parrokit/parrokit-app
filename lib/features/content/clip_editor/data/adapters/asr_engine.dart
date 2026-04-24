// ============================================================================
// lib/features/_content/clip_editor/data/adapters/asr_engine.dart
// ============================================================================
//
// [역할]
// 사용자가 선택 가능한 ASR 엔진 enum.
//
// [레이어]
// Data Layer > Adapters
// ============================================================================

/// ASR(STT) 엔진 종류.
enum AsrEngine {
  /// gpt-4o-transcribe-diarize. 화자 분리, 디테일 모드.
  diarize,

  /// whisper-1. 무음/긴 파일에 안정적, 화자 분리 없음.
  whisper,
}

extension AsrEngineLabel on AsrEngine {
  String get label => switch (this) {
        AsrEngine.diarize => '디테일 (화자 분리)',
        AsrEngine.whisper => '안정 (Whisper)',
      };

  String get description => switch (this) {
        AsrEngine.diarize => '정확도와 화자 구분이 필요한 짧은 영상에 권장',
        AsrEngine.whisper => '무음이 많거나 긴 파일에 안정적',
      };
}
