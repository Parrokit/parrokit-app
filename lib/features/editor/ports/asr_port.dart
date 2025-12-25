// mvp/editor/ports/asr_port.dart

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
