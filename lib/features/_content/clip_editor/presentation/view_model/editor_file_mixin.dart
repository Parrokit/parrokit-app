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

import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';

import 'package:parrokit/core/utils/show_toast.dart';

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

  /// 로컬 파일 시스템에서 영상 파일을 선택하고 Staging 영역으로 복사합니다.
  Future<void> pickFromSandbox() async {
    final picked = await pickVideo(PickSource.files);
    if (picked == null) return;
    final (rawPath, pf) = picked;
    final stagedPath =
        await staging.stageFromPath(rawPath, suggestedName: pf.name);
    await _afterPick(path: stagedPath, name: pf.name, size: pf.size);
  }

  /// 갤러리(Phoots)에서 영상 파일을 선택하고 Staging 영역으로 복사합니다.
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

  /// 기존 파일 경로를 설정합니다 (편집 모드용).
  /// DB에 저장된 상대 경로를 절대 경로로 변환합니다.
  Future<void> setExistingFile(String relPath) async {
    final docsDir = await getApplicationDocumentsDirectory();
    final absPath = '${docsDir.path}/$relPath';

    final file = File(absPath);
    if (!await file.exists()) {
      showToast('기존 파일을 찾을 수 없습니다.');
      return;
    }

    final stat = await file.stat();
    final name = absPath.split('/').last;

    _picked = PlatformFile(name: name, size: stat.size, path: absPath);
    _thumb = null;
    notifyListeners();

    await _setThumb(absPath);
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
