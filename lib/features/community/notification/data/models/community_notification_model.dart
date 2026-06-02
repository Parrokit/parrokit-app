import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:parrokit/features/community/notification/domain/entities/community_notification_item.dart';

class CommunityNotificationModel extends CommunityNotificationItem {
  const CommunityNotificationModel({
    required super.id,
    required super.recipientUserId,
    required super.notificationType,
    required super.boardType,
    required super.postId,
    super.commentId,
    super.parentCommentId,
    required super.actorId,
    super.actorDisplayName,
    required super.title,
    required super.body,
    required super.isRead,
    required super.createdAt,
    super.readAt,
  });

  factory CommunityNotificationModel.fromJson({
    required String id,
    required Map<String, dynamic> json,
  }) {
    return CommunityNotificationModel(
      id: id,
      recipientUserId: json['recipientUserId'] as String? ?? '',
      notificationType: json['notificationType'] as String? ?? 'post_comment',
      boardType: json['boardType'] as String? ?? 'board',
      postId: json['postId'] as String? ?? '',
      commentId: json['commentId'] as String?,
      parentCommentId: json['parentCommentId'] as String?,
      actorId: json['actorId'] as String? ?? '',
      actorDisplayName: json['actorDisplayName'] as String?,
      title: json['title'] as String? ?? '',
      body: json['body'] as String? ?? '',
      isRead: json['isRead'] as bool? ?? false,
      createdAt: _parseDateTime(json['createdAt']) ?? DateTime.now(),
      readAt: _parseDateTime(json['readAt']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'recipientUserId': recipientUserId,
      'notificationType': notificationType,
      'boardType': boardType,
      'postId': postId,
      'commentId': commentId,
      'parentCommentId': parentCommentId,
      'actorId': actorId,
      'actorDisplayName': actorDisplayName,
      'title': title,
      'body': body,
      'isRead': isRead,
      'createdAt': Timestamp.fromDate(createdAt),
      'readAt': readAt != null ? Timestamp.fromDate(readAt!) : null,
    };
  }

  static DateTime? _parseDateTime(dynamic value) {
    if (value == null) return null;
    if (value is DateTime) return value;
    if (value is Timestamp) return value.toDate();
    if (value is String) return DateTime.tryParse(value);
    if (value is num) return DateTime.fromMillisecondsSinceEpoch(value.toInt());
    return null;
  }
}
