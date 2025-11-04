
import 'package:file_picker/file_picker.dart';
import 'package:parrokit/mvp/editor/services/file_staging_service.dart';
import 'package:parrokit/provider/media_provider.dart';
import 'package:parrokit/data/local/pa_database.dart' as db;

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
    if (isEdit && existingRelPath != null && existingRelPath.isNotEmpty && !staging.isInStaging(stagedPath)) {
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
