class ActivityItem {
  final String id;
  final String title;
  final String content;
  final DateTime createdAt;
  final String boardType; // 'board', 'question', 'vote'
  final String activityType; // 'written', 'commented', etc.
  final int likeCount;
  final int commentCount;
  final int viewCount;

  const ActivityItem({
    required this.id,
    required this.title,
    required this.content,
    required this.createdAt,
    required this.boardType,
    required this.activityType,
    this.likeCount = 0,
    this.commentCount = 0,
    this.viewCount = 0,
  });
}
