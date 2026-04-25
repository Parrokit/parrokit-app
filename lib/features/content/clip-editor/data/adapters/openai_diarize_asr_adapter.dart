// ============================================================================
// lib/features/_content/clip_editor/data/adapters/openai_diarize_asr_adapter.dart
// ============================================================================
//
// [역할]
// OpenAI gpt-4o-transcribe-diarize 모델 어댑터.
// 화자 분리(diarization)가 필요한 디테일 모드용.
//
// [레이어]
// Data Layer > Adapters
// ============================================================================

import 'package:http/http.dart' as http;

import 'openai_asr_base.dart';

/// gpt-4o-transcribe-diarize 모델용 ASR 어댑터.
class OpenAIDiarizeAsrAdapter extends OpenAIAsrBase {
  OpenAIDiarizeAsrAdapter({required super.apiKey});

  @override
  String get model => 'gpt-4o-transcribe-diarize';

  @override
  String get responseFormat => 'diarized_json';

  @override
  void configureExtraFields(http.MultipartRequest req) {
    req.fields['chunking_strategy'] =
        '{"type":"server_vad","prefix_padding_ms":300,'
        '"silence_duration_ms":500,"threshold":0.5}';
  }
}
