// lib/data/models/vote_option.dart

class VoteOption {
  final String id;
  final String text;
  final int count;

  const VoteOption({
    required this.id,
    required this.text,
    this.count = 0,
  });

  VoteOption copyWith({
    String? id,
    String? text,
    int? count,
  }) {
    return VoteOption(
      id: id ?? this.id,
      text: text ?? this.text,
      count: count ?? this.count,
    );
  }

  factory VoteOption.fromJson(Map<String, dynamic> json) {
    return VoteOption(
      id: json['id'] as String? ?? '',
      text: json['text'] as String? ?? '',
      count: (json['count'] as num?)?.toInt() ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'text': text,
      'count': count,
    };
  }
}
