// ============================================================================
// lib/features/_content/clip_editor/data/adapters/openai_whisper_asr_adapter.dart
// ============================================================================
//
// [역할]
// OpenAI whisper-1 모델 어댑터.
// 무음 많은 입력/긴 파일에서도 안정적이고 segment 타임스탬프를 제공.
//
// [레이어]
// Data Layer > Adapters
// ============================================================================

import 'package:http/http.dart' as http;

import 'openai_asr_base.dart';

/// whisper-1 모델용 ASR 어댑터.
class OpenAIWhisperAsrAdapter extends OpenAIAsrBase {
  OpenAIWhisperAsrAdapter({required super.apiKey});

  @override
  String get model => 'whisper-1';

  @override
  String get responseFormat => 'verbose_json';

  @override
  void configureExtraFields(http.MultipartRequest req) {
    req.fields['timestamp_granularities[]'] = 'segment';
  }
}
