// ============================================================================
// lib/features/_content/clip_editor/data/services/clip_save_service.dart
// ============================================================================
//
// [역할]
// 클립 저장 서비스.
//
// [레이어]
// Data Layer > Services
// ============================================================================

import 'package:parrokit/core/provider/media_provider.dart';
import 'package:parrokit/data/local/app_database.dart' as db;

import '../../domain/clip_form_data.dart';
import '../../domain/editor_mode.dart';
import '../../domain/editor_state.dart';
import 'file_staging_service.dart';
import 'time_code_service.dart';

/// 클립 저장 서비스.
class ClipSaveService {
  final MediaProvider repo;
  final FileStagingService staging;
  final TimecodeService _timecode = TimecodeService();

  ClipSaveService({required this.repo, required this.staging});

  /// ClipFormData와 EditorMode를 사용하여 클립을 저장합니다.
  Future<void> save({
    required ClipFormData formData,
    required EditorMode mode,
    required String stagedFilePath,
  }) async {
    // 파일 경로 결정
    String relPath;
    if (mode is EditMode &&
        mode.existingFilePath != null &&
        mode.existingFilePath!.isNotEmpty &&
        !staging.isInStaging(stagedFilePath)) {
      relPath = mode.existingFilePath!;
    } else {
      relPath = await staging.finalize(stagedFilePath);
    }

    // SegmentInput -> db.Segment 변환
    final segments = formData.segments
        .map((s) => db.Segment(
              id: 0,
              clipId: 0,
              startMs: _timecode.parseToMs(s.start),
              endMs: _timecode.parseToMs(s.end),
              original: s.original,
              pron: s.pron,
              trans: s.ko,
            ))
        .toList();

    if (mode is EditMode) {
      await repo.updateMedia(
        clipId: mode.clipId,
        titleName: formData.titleName,
        titleNameNative: formData.titleNameNative,
        type: formData.typeString,
        seasonNumber: formData.contentType == ContentType.season
            ? formData.seasonNumber
            : null,
        episodeNumber: formData.contentType == ContentType.season
            ? formData.episodeNumber
            : null,
        episodeTitle: formData.epiTitle,
        clipTitle: formData.clipTitle,
        filePath: relPath,
        durationMs: formData.durationMs!,
        segments: segments,
        tags: formData.tags,
      );
    } else {
      await repo.addMedia(
        titleName: formData.titleName,
        titleNameNative: formData.titleNameNative,
        type: formData.typeString,
        seasonNumber: formData.contentType == ContentType.season
            ? formData.seasonNumber
            : null,
        episodeNumber: formData.contentType == ContentType.season
            ? formData.episodeNumber
            : null,
        episodeTitle: formData.epiTitle,
        clipTitle: formData.clipTitle,
        filePath: relPath,
        durationMs: formData.durationMs!,
        segments: segments,
        tags: formData.tags,
      );
    }
  }
}
