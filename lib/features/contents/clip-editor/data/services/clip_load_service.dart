// ============================================================================
// lib/features/_content/clip_editor/data/services/clip_load_service.dart
// ============================================================================
//
// [역할]
// 편집용 클립 데이터 로드 서비스.
//
// [레이어]
// Data Layer > Services
// ============================================================================

import 'package:parrokit/core/provider/media_provider.dart';
import 'package:parrokit/data/local/app_database.dart' as db;

import '../../../../../features/contents/clip-editor/domain/clip_form_data.dart';
import '../../../../../features/contents/clip-editor/domain/editor_mode.dart';
import '../../../../../features/contents/clip-editor/data/services/time_code_service.dart';

/// 편집용 클립 로드 결과.
class LoadClipResult {
  final ClipFormData formData;
  final EditMode mode;
  final List<db.Segment> rawSegments;

  const LoadClipResult({
    required this.formData,
    required this.mode,
    required this.rawSegments,
  });
}

/// 편집용 클립 데이터 로드 서비스.
class ClipLoadService {
  final MediaProvider mediaProvider;
  final TimecodeService _timecode = TimecodeService();

  ClipLoadService({required this.mediaProvider});

  /// 클립 ID로 편집 데이터를 로드합니다.
  Future<LoadClipResult> loadForEdit(int clipId) async {
    // 클립 조회
    final db.Clip clip;
    try {
      clip = mediaProvider.clips.firstWhere((c) => c.id == clipId);
    } catch (_) {
      throw Exception('편집할 클립을 찾을 수 없습니다.');
    }

    // 컬렉션 이름 조회 (collectionId가 있는 경우)
    String? collectionName;
    if (clip.collectionId != null) {
      final collection = mediaProvider.collections
          .cast<db.Collection?>()
          .firstWhere(
            (c) => c?.id == clip.collectionId,
            orElse: () => null,
          );
      collectionName = collection?.name;
    }

    // 태그 조회
    final tagList = (mediaProvider.tagsByClip[clipId] ?? const <db.Tag>[])
        .map((t) => t.name)
        .toList();

    // 세그먼트 조회
    final clipView = await mediaProvider.fetchClipById(clipId);
    if (clipView == null) {
      throw Exception('편집할 클립을 찾을 수 없습니다.');
    }

    // SegmentInput으로 변환
    final segmentInputs = clipView.segments
        .map((s) => SegmentInput(
              start: _timecode.msToMMSSmmm(s.startMs),
              end: _timecode.msToMMSSmmm(s.endMs),
              original: s.original,
              pron: s.pron,
              ko: s.trans,
            ))
        .toList();

    // ClipFormData 생성
    final formData = ClipFormData(
      collectionName: collectionName,
      clipTitle: clip.title,
      durationMs: clip.durationMs > 0 ? clip.durationMs : null,
      segments: segmentInputs,
      tags: tagList,
      filePath: clip.filePath,
    );

    return LoadClipResult(
      formData: formData,
      mode: EditMode(clipId: clipId, existingFilePath: clip.filePath),
      rawSegments: clipView.segments,
    );
  }
}
