// lib/data/models/report.dart

class Report {
  final String id;
  final String reporterId;
  final String targetType;
  final String targetId;
  final String reportedUserId;
  final String reason;
  final DateTime? createdAt;

  const Report({
    required this.id,
    required this.reporterId,
    required this.targetType,
    required this.targetId,
    required this.reportedUserId,
    required this.reason,
    this.createdAt,
  });

  Report copyWith({
    String? id,
    String? reporterId,
    String? targetType,
    String? targetId,
    String? reportedUserId,
    String? reason,
    DateTime? createdAt,
  }) {
    return Report(
      id: id ?? this.id,
      reporterId: reporterId ?? this.reporterId,
      targetType: targetType ?? this.targetType,
      targetId: targetId ?? this.targetId,
      reportedUserId: reportedUserId ?? this.reportedUserId,
      reason: reason ?? this.reason,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  factory Report.fromJson(Map<String, dynamic> json) {
    return Report(
      id: json['id'] as String? ?? '',
      reporterId: json['reporterId'] as String? ?? '',
      targetType: json['targetType'] as String? ?? 'post',
      targetId: json['targetId'] as String? ?? '',
      reportedUserId: json['reportedUserId'] as String? ?? '',
      reason: json['reason'] as String? ?? '',
      createdAt: _parseDateTime(json['createdAt']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'reporterId': reporterId,
      'targetType': targetType,
      'targetId': targetId,
      'reportedUserId': reportedUserId,
      'reason': reason,
      'createdAt': createdAt?.toIso8601String(),
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
