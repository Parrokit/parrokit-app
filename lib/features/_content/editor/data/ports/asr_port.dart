// ============================================================================
// lib/features/_content/editor/data/ports/asr_port.dart
// ============================================================================
//
// [역할]
// 음성인식(ASR) 포트 인터페이스.
// ASRSegment, ASRResult DTO 및 ASRPort 추상 클래스 정의.
//
// [레이어]
// Data Layer > Ports
// ============================================================================

import 'dart:typed_data';

class ASRSegment {
  final int startMs;
  final int endMs;
  final String text;

  const ASRSegment({
    required this.startMs,
    required this.endMs,
    required this.text,
  });
}

class ASRResult {
  final String text;
  final List<ASRSegment> segments;

  ASRResult({required this.text, List<ASRSegment>? segments})
      : segments = segments ?? const [];
}

abstract class ASRPort {
  Future<ASRResult> transcribe({
    String? filePath,
    Uint8List? bytes,
    String? language,
    bool withSegments = true,
    Duration? timeout,
    String? model,
  });
}
