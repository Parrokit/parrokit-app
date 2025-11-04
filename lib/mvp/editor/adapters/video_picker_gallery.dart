import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:image_picker/image_picker.dart';
import 'package:parrokit/mvp/editor/ports/video_picker_port.dart';

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
