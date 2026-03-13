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
  // 작품명 섹션 (WorkNameSection)
  // ─────────────────────────────────────────────────────────────────────────
  static const workNameLabel = '작품명';
  static const workNameHint = '예: 스파이 패밀리, 너의 이름은';

  static const workNameNativeLabel = '원어 작품명';
  static const workNameNativeHint = '예: SPY×FAMILY, 君の名は。';
  static const workNameNativeLookupButton = '자동 입력';
  static const workNameNativeLookupLoading = '조회 중...';

  // ─────────────────────────────────────────────────────────────────────────
  // 타입 섹션 (TypeSection)
  // ─────────────────────────────────────────────────────────────────────────
  static const typeSectionTitle = '시즌 또는 영화';

  // ─────────────────────────────────────────────────────────────────────────
  // 시즌/에피소드 섹션 (SeasonEpisodeSection)
  // ─────────────────────────────────────────────────────────────────────────
  static const seasonEpisodeSectionTitle = '시즌/화';
  static const movieTypeMessage = '영화는 시즌/회차 정보가 필요 없어요.';

  static const seasonLabel = '시즌';
  static const seasonHint = '예: 1, 2, 3';

  static const episodeLabel = '화 (에피소드)';
  static const episodeHint = '예: 1, 12, 25';

  // ─────────────────────────────────────────────────────────────────────────
  // 제목 섹션 (TitlesSection)
  // ─────────────────────────────────────────────────────────────────────────
  static const titlesSectionTitle = '제목';

  static const movieTitleLabel = '영화 제목';
  static const movieTitleHint = '예: 너의 이름은';
  static const movieTitleHelper = '단독 영화라면 작품명과 동일해도 괜찮아요.';

  static const episodeTitleLabel = '회차 제목';
  static const episodeTitleHint = '예: 보이드의 하룻밤';
  static const episodeTitleHelper = '기존 에피소드 정보가 있으면 자동으로 채워져요.';

  static const clipTitleLabel = '클립 제목';
  static const clipTitleHint = '예: 아냐 땅콩 먹방';
  static const clipTitleHelper = '이 클립이 어떤 장면인지 알 수 있게 적어주세요.';

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
  static const pronHelper = '로마자, 한글, 원어 등 편한 방식으로 적으세요.';

  static const originalLabel = '원문';
  static const originalHint = '예: merci, gracias, 谢谢';
  static const originalHelper = '대사의 원문을 그대로 적어주세요.';

  static const koLabel = '해석';
  static const koHint = '예: 고마워, 감사합니다';
  static const koHelper = '본인이 이해하기 쉬운 표현으로 번역해주세요.';

  // ─────────────────────────────────────────────────────────────────────────
  // 태그 섹션 (TagsSection)
  // ─────────────────────────────────────────────────────────────────────────
  static const tagsSectionTitle = '태그 추가';
  static const tagsLabel = '태그(선택)';
  static const tagsHint = '예: 먹방, 웃김, 감동';
  static const tagsHelper = '나중에 클립을 쉽게 찾을 수 있는 키워드를 추가하세요.';
  static const addTagButtonLabel = '태그 추가';
  static const clearAllTagsButtonLabel = '모두 지우기';
}
