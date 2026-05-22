// lib/data/models/answer.dart

class Answer {
  final String id;
  final String authorId;
  final String authorNickname;
  final String? authorAvatarUrl;
  final String content;
  final bool isAdopted;
  final int upvoteCount;
  final int commentCount;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  const Answer({
    required this.id,
    required this.authorId,
    required this.authorNickname,
    this.authorAvatarUrl,
    required this.content,
    this.isAdopted = false,
    this.upvoteCount = 0,
    this.commentCount = 0,
    this.createdAt,
    this.updatedAt,
  });

  Answer copyWith({
    String? id,
    String? authorId,
    String? authorNickname,
    String? authorAvatarUrl,
    bool clearAuthorAvatarUrl = false,
    String? content,
    bool? isAdopted,
    int? upvoteCount,
    int? commentCount,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Answer(
      id: id ?? this.id,
      authorId: authorId ?? this.authorId,
      authorNickname: authorNickname ?? this.authorNickname,
      authorAvatarUrl: clearAuthorAvatarUrl ? null : (authorAvatarUrl ?? this.authorAvatarUrl),
      content: content ?? this.content,
      isAdopted: isAdopted ?? this.isAdopted,
      upvoteCount: upvoteCount ?? this.upvoteCount,
      commentCount: commentCount ?? this.commentCount,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  factory Answer.fromJson(Map<String, dynamic> json) {
    return Answer(
      id: json['id'] as String? ?? '',
      authorId: json['authorId'] as String? ?? '',
      authorNickname: json['authorNickname'] as String? ?? '',
      authorAvatarUrl: json['authorAvatarUrl'] as String?,
      content: json['content'] as String? ?? '',
      isAdopted: json['isAdopted'] as bool? ?? false,
      upvoteCount: (json['upvoteCount'] as num?)?.toInt() ?? 0,
      commentCount: (json['commentCount'] as num?)?.toInt() ?? 0,
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
      'isAdopted': isAdopted,
      'upvoteCount': upvoteCount,
      'commentCount': commentCount,
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
