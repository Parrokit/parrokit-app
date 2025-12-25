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