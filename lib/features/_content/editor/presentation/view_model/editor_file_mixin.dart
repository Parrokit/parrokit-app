// ============================================================================
// lib/features/_content/editor/presentation/view_model/editor_file_mixin.dart
// ============================================================================
//
// [역할]
// 파일 선택/제거 로직 mixin.
//
// [레이어]
// Presentation Layer > ViewModel > Mixin
// ============================================================================

import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import '../../data/adapters/video_picker_files.dart';
import '../../data/adapters/video_picker_gallery.dart';
import '../../data/ports/video_picker_port.dart';
import '../../data/services/audio_to_video.dart';
import '../../data/services/file_staging_service.dart';
import '../../data/services/video_meta_service.dart';
import '../../data/usecases/extract_duration_usecase.dart';
import '../../data/usecases/extract_thumbnail_usecase.dart';
import '../../data/usecases/pick_video_usecase.dart';

/// 파일 선택/제거 mixin.
mixin EditorFileMixin on ChangeNotifier {
  // 의존성 (추상 getter - 메인 ViewModel에서 구현)
  FileStagingService get staging;
  AudioToVideoService get audioToVideo;
  ExtractThumbnailUseCase get extractThumb;
  ExtractDurationUseCase get extractDuration;
  PickVideoUseCase get pickVideo;
  TextEditingController get durationCtl;
  void showToast(String msg);

  // ─────────────────────────────────────────────────────────────────
  // 상태
  // ─────────────────────────────────────────────────────────────────
  PlatformFile? _picked;
  PlatformFile? get picked => _picked;

  Uint8List? _thumb;
  Uint8List? get thumb => _thumb;

  // ─────────────────────────────────────────────────────────────────
  // 파일 선택
  // ─────────────────────────────────────────────────────────────────
  Future<void> pickFromSandbox() async {
    final picked = await pickVideo(PickSource.files);
    if (picked == null) return;
    final (rawPath, pf) = picked;
    final stagedPath =
        await staging.stageFromPath(rawPath, suggestedName: pf.name);
    await _afterPick(path: stagedPath, name: pf.name, size: pf.size);
  }

  Future<void> pickFromPhotos() async {
    final picked = await pickVideo(PickSource.gallery);
    if (picked == null) return;
    final (rawPath, pf) = picked;
    final stagedPath =
        await staging.stageFromPath(rawPath, suggestedName: pf.name);
    await _afterPick(path: stagedPath, name: pf.name, size: pf.size);
  }

  Future<void> _afterPick({
    required String path,
    required String name,
    required int size,
  }) async {
    String effectivePath = path;
    try {
      effectivePath = await audioToVideo.ensureMp4(path);
    } catch (e) {
      showToast('오디오를 영상으로 변환 중 오류: $e');
      return;
    }

    _picked = PlatformFile(name: name, size: size, path: effectivePath);
    _thumb = null;
    notifyListeners();

    await _setThumb(effectivePath);
    final ms = await _probeDurationMs(effectivePath);
    if (ms != null) {
      durationCtl.text = ms.toString();
    }
    notifyListeners();
  }

  void removePicked() {
    final p = _picked?.path;
    _picked = null;
    _thumb = null;
    if (p != null && staging.isInStaging(p)) {
      staging.discard(p);
    }
    notifyListeners();
  }

  Future<void> _setThumb(String path) async {
    final bytes = await extractThumb(path);
    _thumb = bytes;
    notifyListeners();
  }

  Future<int?> _probeDurationMs(String path) async {
    return await extractDuration(path);
  }

  // Mixin 초기화 헬퍼
  (PickVideoUseCase, ExtractThumbnailUseCase, ExtractDurationUseCase)
      initFileDeps() {
    return (
      PickVideoUseCase(
          files: VideoPickerFiles(), gallery: VideoPickerGallery()),
      ExtractThumbnailUseCase(VideoMetaServiceImpl()),
      ExtractDurationUseCase(VideoMetaServiceImpl()),
    );
  }
}
