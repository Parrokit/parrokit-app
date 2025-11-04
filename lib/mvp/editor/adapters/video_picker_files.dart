import 'dart:io';
import 'package:file_picker/file_picker.dart';
import 'package:parrokit/mvp/editor/ports/video_picker_port.dart';

/// File Picker 구현
class VideoPickerFiles implements VideoPickerPort {
  @override
  Future<PickedVideo?> pick(PickSource from) async {
    if (from != PickSource.files) return null;
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['mp4', 'mov', 'mkv'],
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
