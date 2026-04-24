// ============================================================================
// lib/features/_content/editor/data/usecases/transcribe_usecase.dart
// ============================================================================
//
// [역할]
// 음성 인식(STT) UseCase.
// ASRPort를 통해 오디오/비디오 파일에서 텍스트 추출.
//
// [레이어]
// Data Layer > UseCases
// ============================================================================

import 'dart:typed_data';
import 'package:parrokit/features/content/clip_editor/data/ports/asr_port.dart';

class TranscribeUseCase {
  final ASRPort asr;
  TranscribeUseCase(this.asr);

  Future<ASRResult> call({
    String? filePath,
    Uint8List? bytes,
    String language = 'ja', // 기본값: 일본어
    bool withSegments = true, // 세그먼트 포함
  }) {
    return asr.transcribe(
      filePath: filePath,
      bytes: bytes,
      language: language,
      withSegments: withSegments,
    );
  }
}
