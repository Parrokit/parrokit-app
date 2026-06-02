class CommunityNotificationItem {
  final String id;
  final String recipientUserId;
  final String notificationType;
  final String boardType;
  final String postId;
  final String? commentId;
  final String? parentCommentId;
  final String actorId;
  final String? actorDisplayName;
  final String title;
  final String body;
  final bool isRead;
  final DateTime createdAt;
  final DateTime? readAt;

  const CommunityNotificationItem({
    required this.id,
    required this.recipientUserId,
    required this.notificationType,
    required this.boardType,
    required this.postId,
    this.commentId,
    this.parentCommentId,
    required this.actorId,
    this.actorDisplayName,
    required this.title,
    required this.body,
    required this.isRead,
    required this.createdAt,
    this.readAt,
  });
}
