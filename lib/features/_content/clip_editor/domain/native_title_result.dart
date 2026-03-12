// ============================================================================
// lib/features/_content/clip_editor/domain/native_title_result.dart
// ============================================================================
//
// [역할]
// 원어 작품명 조회 결과 모델.
//
// [레이어]
// Domain Layer > Models
// ============================================================================

/// 원어 작품명 조회 결과.
class NativeTitleResult {
  /// 원어 제목 (예: SPY×FAMILY, 君の名は。)
  final String nativeTitle;

  NativeTitleResult({required this.nativeTitle});

  factory NativeTitleResult.fromJson(Map<String, dynamic> json) {
    return NativeTitleResult(
      nativeTitle: json['nativeTitle'] as String? ?? '',
    );
  }
}
