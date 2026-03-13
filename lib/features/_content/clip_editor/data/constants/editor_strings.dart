// ============================================================================
// lib/features/_content/clip_editor/data/editor_strings.dart
// ============================================================================
//
// [역할]
// Clip Editor에서 사용하는 UI 문자열 상수 모음.
// 라벨, 힌트, 헬퍼 텍스트 등을 한 곳에서 관리.
//
// [레이어]
// Data Layer > Constants
// ============================================================================

/// Clip Editor UI 문자열 상수.
class EditorStrings {
  EditorStrings._();

  // ─────────────────────────────────────────────────────────────────────────
  // 컬렉션 섹션 (WorkNameSection)
  // ─────────────────────────────────────────────────────────────────────────
  static const collectionLabel = '컬렉션 *';
  static const collectionHint = '예: 스파이 패밀리, 공부용';

  // ─────────────────────────────────────────────────────────────────────────
  // 제목 섹션 (TitlesSection)
  // ─────────────────────────────────────────────────────────────────────────
  static const clipTitleLabel = '클립 제목 *';
  static const clipTitleHint = '예: 아냐 땅콩 먹방';

  // ─────────────────────────────────────────────────────────────────────────
  // 세그먼트 섹션 (SegmentsSection)
  // ─────────────────────────────────────────────────────────────────────────
  static const segmentsSectionTitle = '자막 정보';
  static const segmentsNotice = '소음이나 음악이 많은 영상에선 자동 자막 정확도가 낮을 수 있어요.';
  static const sttButtonLabel = '자동 자막 달기';
  static const addSegmentButtonLabel = '구간 추가';
  static const removeSegmentButtonLabel = '구간 삭제';

  // ─────────────────────────────────────────────────────────────────────────
  // 세그먼트 카드 (SegmentCard)
  // ─────────────────────────────────────────────────────────────────────────
  static String segmentCardTitle(int index) => '구간 #$index';

  static const pronLabel = '발음';
  static const pronHint = '예: bonjour, 봉주르';

  static const originalLabel = '원문';
  static const originalHint = '예: merci, gracias, 谢谢';

  static const koLabel = '해석';
  static const koHint = '예: 고마워, 감사합니다';

  // ─────────────────────────────────────────────────────────────────────────
  // 태그 섹션 (TagsSection)
  // ─────────────────────────────────────────────────────────────────────────
  static const addTagButtonLabel = '태그 추가';
  static const tagsLabel = '태그';
  static const tagsHint = '예: 먹방, 웃김, 감동';
  static const clearAllTagsButtonLabel = '모두 지우기';
}
