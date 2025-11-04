import 'package:file_picker/file_picker.dart';
import 'package:parrokit/mvp/editor/ports/video_picker_port.dart';

class PickVideoUseCase {
  final VideoPickerPort files;
  final VideoPickerPort gallery;
  PickVideoUseCase({required this.files, required this.gallery});

  Future<(String path, PlatformFile pf)?> call(PickSource from) async {
    final port = from == PickSource.files ? files : gallery;
    final picked = await port.pick(from);
    if (picked == null) return null;
    return (picked.path, picked.platformFile);
  }
}
