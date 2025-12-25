// ============================================================================
// lib/features/_content/editor/data/ports/video_picker_port.dart
// ============================================================================
//
// [역할]
// 비디오 피커 포트 인터페이스.
// PickSource enum, PickedVideo DTO, VideoPickerPort 추상 클래스 정의.
//
// [레이어]
// Data Layer > Ports
// ============================================================================

import 'package:file_picker/file_picker.dart';

/// 선택 소스
enum PickSource { files, gallery }

/// 픽 결과 DTO
class PickedVideo {
  final String path;
  final PlatformFile platformFile;
  PickedVideo({required this.path, required this.platformFile});
}

/// 비디오 피커 포트
abstract class VideoPickerPort {
  Future<PickedVideo?> pick(PickSource from);
}
