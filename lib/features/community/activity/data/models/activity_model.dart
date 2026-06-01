import '../../domain/entities/activity_item.dart';

class ActivityModel extends ActivityItem {
  const ActivityModel({
    required super.id,
    required super.title,
    required super.content,
    required super.createdAt,
    required super.boardType,
    required super.activityType,
    super.likeCount = 0,
    super.commentCount = 0,
    super.viewCount = 0,
  });

  factory ActivityModel.fromJson(Map<String, dynamic> json) {
    return ActivityModel(
      id: json['id'] as String,
      title: json['title'] as String,
      content: json['content'] as String,
      createdAt: DateTime.parse(json['createdAt'] as String),
      boardType: json['boardType'] as String,
      activityType: json['activityType'] as String,
      likeCount: json['likeCount'] as int? ?? 0,
      commentCount: json['commentCount'] as int? ?? 0,
      viewCount: json['viewCount'] as int? ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'content': content,
      'createdAt': createdAt.toIso8601String(),
      'boardType': boardType,
      'activityType': activityType,
      'likeCount': likeCount,
      'commentCount': commentCount,
      'viewCount': viewCount,
    };
  }
}
