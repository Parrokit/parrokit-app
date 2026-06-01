class CommunityFilters {
  static const List<String> board = ['전체', '자유', '추천해요', '꿀팁', '일상', '분석'];
  static const List<String> question = ['채택 완료', '답변 대기중', '화제의 질문', '오래된 질문'];
  static const List<String> vote = ['랜덤', '전체', '완료', '만료'];

  static const String defaultBoard = '전체';
  static const String defaultQuestion = '답변 대기중';
  static const String defaultVote = '랜덤 보기';

  const CommunityFilters._();
}
