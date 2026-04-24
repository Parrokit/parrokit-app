// ============================================================================
// lib/features/_content/editor/data/usecases/pick_video_usecase.dart
// ============================================================================
//
// [역할]
// 비디오 파일 선택 UseCase.
// FilePicker 또는 Gallery에서 비디오 선택.
//
// [레이어]
// Data Layer > UseCases
// ============================================================================

import 'package:file_picker/file_picker.dart';
import 'package:parrokit/features/content/clip_editor/data/ports/video_picker_port.dart';

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
