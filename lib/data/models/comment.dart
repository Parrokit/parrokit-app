// lib/data/models/comment.dart

class Comment {
  final String id;
  final String authorId;
  final String authorNickname;
  final String? authorAvatarUrl;
  final String content;
  final String? parentId;
  final String? replyToNickname;
  final int likeCount;
  final String status;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  const Comment({
    required this.id,
    required this.authorId,
    required this.authorNickname,
    this.authorAvatarUrl,
    required this.content,
    this.parentId,
    this.replyToNickname,
    this.likeCount = 0,
    this.status = 'active',
    this.createdAt,
    this.updatedAt,
  });

  Comment copyWith({
    String? id,
    String? authorId,
    String? authorNickname,
    String? authorAvatarUrl,
    bool clearAuthorAvatarUrl = false,
    String? content,
    String? parentId,
    bool clearParentId = false,
    String? replyToNickname,
    bool clearReplyToNickname = false,
    int? likeCount,
    String? status,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Comment(
      id: id ?? this.id,
      authorId: authorId ?? this.authorId,
      authorNickname: authorNickname ?? this.authorNickname,
      authorAvatarUrl: clearAuthorAvatarUrl ? null : (authorAvatarUrl ?? this.authorAvatarUrl),
      content: content ?? this.content,
      parentId: clearParentId ? null : (parentId ?? this.parentId),
      replyToNickname: clearReplyToNickname ? null : (replyToNickname ?? this.replyToNickname),
      likeCount: likeCount ?? this.likeCount,
      status: status ?? this.status,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  factory Comment.fromJson(Map<String, dynamic> json) {
    return Comment(
      id: json['id'] as String? ?? '',
      authorId: json['authorId'] as String? ?? '',
      authorNickname: json['authorNickname'] as String? ?? '',
      authorAvatarUrl: json['authorAvatarUrl'] as String?,
      content: json['content'] as String? ?? '',
      parentId: json['parentId'] as String?,
      replyToNickname: json['replyToNickname'] as String?,
      likeCount: (json['likeCount'] as num?)?.toInt() ?? 0,
      status: json['status'] as String? ?? 'active',
      createdAt: _parseDateTime(json['createdAt']),
      updatedAt: _parseDateTime(json['updatedAt']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'authorId': authorId,
      'authorNickname': authorNickname,
      'authorAvatarUrl': authorAvatarUrl,
      'content': content,
      'parentId': parentId,
      'replyToNickname': replyToNickname,
      'likeCount': likeCount,
      'status': status,
      'createdAt': createdAt?.toIso8601String(),
      'updatedAt': updatedAt?.toIso8601String(),
    };
  }

  static DateTime? _parseDateTime(dynamic value) {
    if (value == null) return null;
    if (value is DateTime) return value;
    if (value is String) return DateTime.tryParse(value);
    if (value is num) return DateTime.fromMillisecondsSinceEpoch(value.toInt());
    return null;
  }
}
