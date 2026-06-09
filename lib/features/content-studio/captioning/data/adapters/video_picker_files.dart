// ============================================================================
// lib/features/_content/editor/data/adapters/video_picker_files.dart
// ============================================================================
//
// [역할]
// FilePicker 기반 비디오 선택 어댑터.
// VideoPickerPort 인터페이스 구현.
//
// [레이어]
// Data Layer > Adapters
// ============================================================================

import 'dart:io';
import 'package:file_picker/file_picker.dart';
import 'package:parrokit/features/content-studio/captioning/data/ports/video_picker_port.dart';

/// File Picker 구현
class VideoPickerFiles implements VideoPickerPort {
  @override
  Future<PickedVideo?> pick(PickSource from) async {
    if (from != PickSource.files) return null;
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: [
        // Video formats
        'mp4', 'mov', 'mkv', 'avi', 'webm', 'wmv', 'flv', '3gp', 'm4v', 'mpeg',
        'mpg', 'ts', 'vob',
        // Audio formats
        'mp3', 'm4a', 'wav', 'aac', 'flac', 'ogg', 'caf', 'wma', 'alac', 'aiff',
        'amr', 'opus', 'mid', 'midi',
      ],
      allowMultiple: false,
    );
    if (result == null || result.files.isEmpty) return null;
    final f = result.files.first;
    if (f.path == null) return null;
    final size = await File(f.path!).length();
    return PickedVideo(
      path: f.path!,
      platformFile: PlatformFile(name: f.name, size: size, path: f.path!),
    );
  }
}
