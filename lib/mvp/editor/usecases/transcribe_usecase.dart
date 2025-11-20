// mvp/editor/usecases/transcribe_usecase.dart
import 'dart:typed_data';
import 'package:parrokit/mvp/editor/ports/asr_port.dart';

class TranscribeUseCase {
  final ASRPort asr;
  TranscribeUseCase(this.asr);

  Future<ASRResult> call({
    String? filePath,
    Uint8List? bytes,
    String language = 'ja',   // 기본값: 일본어
    bool withSegments = true, // 세그먼트 포함
    String? model = 'gpt-4o-transcribe-diarize',
  }) {
    return asr.transcribe(
      filePath: filePath,
      bytes: bytes,
      language: language,
      withSegments: withSegments,
      model: model,
    );
  }
}