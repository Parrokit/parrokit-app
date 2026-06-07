// ============================================================================
// lib/features/_content/editor/data/adapters/video_picker_gallery.dart
// ============================================================================
//
// [역할]
// ImagePicker(갤러리) 기반 비디오 선택 어댑터.
// VideoPickerPort 인터페이스 구현.
//
// [레이어]
// Data Layer > Adapters
// ============================================================================

import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:image_picker/image_picker.dart';
import 'package:parrokit/features/content-studio/captioning/data/ports/video_picker_port.dart';

/// Gallery(ImagePicker) 구현
class VideoPickerGallery implements VideoPickerPort {
  final ImagePicker _picker = ImagePicker();

  @override
  Future<PickedVideo?> pick(PickSource from) async {
    if (from != PickSource.gallery) return null;
    final x = await _picker.pickVideo(source: ImageSource.gallery);
    if (x == null) return null;
    final size = await File(x.path).length();
    return PickedVideo(
      path: x.path,
      platformFile: PlatformFile(name: x.name, size: size, path: x.path),
    );
  }
}
