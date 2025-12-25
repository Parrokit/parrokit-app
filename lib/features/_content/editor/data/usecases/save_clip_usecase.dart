// ============================================================================
// lib/features/_content/editor/data/usecases/save_clip_usecase.dart
// ============================================================================
//
// [역할]
// 클립 저장 UseCase.
// 신규 생성 및 수정 모드 지원. 파일 스테이징 후 MediaProvider에 저장.
//
// [레이어]
// Data Layer > UseCases
// ============================================================================

import 'package:file_picker/file_picker.dart';
import 'package:parrokit/features/_content/editor/data/services/file_staging_service.dart';
import 'package:parrokit/core/provider/media_provider.dart';
import 'package:parrokit/data/local/app_database.dart' as db;

class SaveClipUseCase {
  final MediaProvider repo;
  final FileStagingService staging;
  SaveClipUseCase({required this.repo, required this.staging});

  Future<void> call({
    required bool isEdit,
    required int? clipId,
    required String type,
    required String name,
    required String nameNative,
    required String clipTitle,
    required String epiTitle,
    required int? seasonNum,
    required int? epiNumber,
    required int durationMs,
    required List<db.Segment> segments,
    required List<String> tags,
    required PlatformFile picked,
    String? existingRelPath,
  }) async {
    final stagedPath = picked.path!;

    // finalize or keep existing
    String relPath;
    if (isEdit &&
        existingRelPath != null &&
        existingRelPath.isNotEmpty &&
        !staging.isInStaging(stagedPath)) {
      relPath = existingRelPath;
    } else {
      relPath = await staging.finalize(stagedPath);
    }

    if (isEdit && clipId != null) {
      await repo.updateMedia(
        clipId: clipId,
        titleName: name,
        titleNameNative: nameNative,
        type: type,
        seasonNumber: type == 'season' ? seasonNum : null,
        episodeNumber: type == 'season' ? epiNumber : null,
        episodeTitle: epiTitle,
        clipTitle: clipTitle,
        filePath: relPath,
        durationMs: durationMs,
        segments: segments,
        tags: tags,
      );
    } else {
      await repo.addMedia(
        titleName: name,
        titleNameNative: nameNative,
        type: type,
        seasonNumber: type == 'season' ? seasonNum : null,
        episodeNumber: type == 'season' ? epiNumber : null,
        episodeTitle: epiTitle,
        clipTitle: clipTitle,
        filePath: relPath,
        durationMs: durationMs,
        segments: segments,
        tags: tags,
      );
    }
  }
}
