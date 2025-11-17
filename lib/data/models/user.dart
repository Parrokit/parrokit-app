// lib/data/models/user.dart

// lib/data/models/user.dart

/// 대표적인 앱 사용자 모델.
/// - id          : 유저를 구분하는 고유 ID (예: Firebase UID, 로컬 UUID 등)
/// - displayName : 화면에 표시할 이름
/// - email       : 로그인 이메일 (없을 수도 있음)
/// - coins       : 유저가 보유한 코인 수 (기본값 0)
/// - createdAt   : 계정이 처음 생성된 시각 (없으면 null)
/// - updatedAt   : 마지막으로 정보가 갱신된 시각 (없으면 null)
class PaUser {
  final String id;
  final String? displayName;
  final String? email;
  final int coins;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  const PaUser({
    required this.id,
    this.displayName,
    this.email,
    this.coins = 20,
    this.createdAt,
    this.updatedAt,
  });

  /// 코인 증감이 적용된 새 인스턴스를 반환합니다.
  PaUser addCoins(int delta) {
    return copyWith(coins: coins + delta);
  }

  /// 일부 필드만 변경해서 새 인스턴스를 만들기 위한 헬퍼입니다.
  PaUser copyWith({
    String? id,
    String? displayName,
    String? email,
    int? coins,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return PaUser(
      id: id ?? this.id,
      displayName: displayName ?? this.displayName,
      email: email ?? this.email,
      coins: coins ?? this.coins,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  /// JSON → PaUser
  /// Firestore, REST API 등에서 내려오는 JSON을 그대로 매핑할 때 사용합니다.
  factory PaUser.fromJson(Map<String, dynamic> json) {
    return PaUser(
      id: json['id'] as String,
      displayName: json['displayName'] as String?,
      email: json['email'] as String?,
      coins: (json['coins'] as num?)?.toInt() ?? 0,
      createdAt: _parseDateTime(json['createdAt']),
      updatedAt: _parseDateTime(json['updatedAt']),
    );
  }

  /// PaUser → JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'displayName': displayName,
      'email': email,
      'coins': coins,
      'createdAt': createdAt?.toIso8601String(),
      'updatedAt': updatedAt?.toIso8601String(),
    };
  }

  /// createdAt/updatedAt 등에 들어올 수 있는 값을 DateTime으로 변환하는 유틸.
  /// - DateTime
  /// - String (ISO8601)
  /// - Timestamp(ms) 형태 num
  static DateTime? _parseDateTime(dynamic value) {
    if (value == null) return null;
    if (value is DateTime) return value;
    if (value is String) {
      return DateTime.tryParse(value);
    }
    if (value is num) {
      // ms 기준 타임스탬프라고 가정
      return DateTime.fromMillisecondsSinceEpoch(value.toInt());
    }
    return null;
  }

  @override
  String toString() {
    return 'PaUser(id: $id, displayName: $displayName, email: $email, coins: $coins)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is PaUser &&
        other.id == id &&
        other.displayName == displayName &&
        other.email == email &&
        other.coins == coins &&
        other.createdAt == createdAt &&
        other.updatedAt == updatedAt;
  }

  @override
  int get hashCode {
    return Object.hash(
      id,
      displayName,
      email,
      coins,
      createdAt,
      updatedAt,
    );
  }
}