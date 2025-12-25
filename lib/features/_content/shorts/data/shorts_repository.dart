// ============================================================================
// lib/features/_content/shorts/data/shorts_repository.dart
// ============================================================================
//
// [역할]
// 쇼츠(Shorts) 데이터 관리 및 접근 담당.
// 랜덤 클립 조회를 위한 쿼리 및 데이터 조립 수행.
//
// [레이어]
// Data Layer > Repository
//
// ============================================================================

import 'package:drift/drift.dart';
import 'package:parrokit/data/local/app_database.dart'; // Import AppDatabase and Tag
import 'package:parrokit/data/models/clip_item.dart';
import 'package:path_provider/path_provider.dart';
import 'package:video_thumbnail/video_thumbnail.dart';

/// [역할]
/// 쇼츠(Shorts) 데이터 관리 및 접근 담당.
///
/// 랜덤 클립을 가져오고, 관련된 태그 및 세그먼트 정보를 로드하여 [ClipItem]으로 조립합니다.
/// 썸네일 생성도 이곳에서 처리합니다.
class ShortsRepository {
  final AppDatabase pdb;

  ShortsRepository(this.pdb);

  /// 무작위 클립 목록을 로드하여 무한 스크롤 피드를 구성합니다.
  ///
  /// [limit] 개수만큼의 클립을 랜덤하게 선택하여 반환합니다.
  /// 다음과 같은 단계로 데이터를 조립합니다:
  /// 1. **클립 조회**: `RANDOM()` SQL 함수를 사용하여 무작위 [Clip] 데이터를 조회합니다.
  /// 2. **태그 매핑**: 조회된 클립 ID 리스트를 기반으로 관련 태그([Tag])들을 일괄 조회(Batch)하여 매핑합니다.
  /// 3. **세그먼트 로드**: 각 클립의 자막 구간([Segment]) 데이터를 로드합니다.
  /// 4. **썸네일 생성**: 비디오 파일 경로를 확인하고, 미리보기용 썸네일 이미지를 생성합니다.
  Future<List<ClipItem>> getRandomClips({required int limit}) async {
    // 1. 랜덤 클립 조회
    final clips = await (pdb.select(pdb.clips)
          ..orderBy([
            (c) => OrderingTerm(expression: const CustomExpression('RANDOM()'))
          ])
          ..limit(limit))
        .get();

    if (clips.isEmpty) return [];

    // 2. 태그 정보 로드 (효율적인 Batch 조회)
    final clipIds = clips.map((c) => c.id).toList();
    final jt = pdb.clipTags;
    final tagRows = await (pdb.select(pdb.tags).join([
      innerJoin(jt, jt.tagId.equalsExp(pdb.tags.id)),
    ])
          ..where(jt.clipId.isIn(clipIds)))
        .get();

    final tagsByClip = <int, List<Tag>>{};
    for (final row in tagRows) {
      final tag = row.readTable(pdb.tags);
      final ct = row.readTable(jt);
      tagsByClip.putIfAbsent(ct.clipId, () => []).add(tag);
    }

    final result = <ClipItem>[];

    // 3. ClipItem 조립 (썸네일 생성 포함)
    for (final c in clips) {
      final absPath = await _absolutePathFor(c.filePath);
      final clipWithAbs = c.copyWith(filePath: absPath);

      final segments = await (pdb.select(pdb.segments)
            ..where((s) => s.clipId.equals(c.id))
            ..orderBy([(s) => OrderingTerm.asc(s.startMs)]))
          .get();

      Uint8List? thumbBytes;
      try {
        thumbBytes = await VideoThumbnail.thumbnailData(
          video: absPath,
          imageFormat: ImageFormat.JPEG,
          quality: 70,
          timeMs: 500,
        );
      } catch (_) {
        // 썸네일 생성 실패 시 무시 (기본 아이콘 등 처리)
      }

      result.add(ClipItem(
        clip: clipWithAbs,
        tags: tagsByClip[c.id] ?? const [],
        segments: segments,
        thumbnail: thumbBytes,
      ));
    }

    return result;
  }

  /// 파일 경로를 절대 경로로 변환합니다.
  Future<String> _absolutePathFor(String pathFromClip) async {
    if (pathFromClip.startsWith('/')) return pathFromClip;
    final dir = await getApplicationDocumentsDirectory();
    return '${dir.path}/$pathFromClip';
  }
}
