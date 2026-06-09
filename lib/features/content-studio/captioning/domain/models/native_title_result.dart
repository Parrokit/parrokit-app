// ============================================================================
// lib/features/content-studio/captioning/domain/models/native_title_result.dart
// ============================================================================
//
// [역할]
// 원어 작품명 조회 결과 모델.
//
// [레이어]
// Domain Layer > Models
// ============================================================================

class NativeTitleResult {
  final String nativeTitle;

  NativeTitleResult({required this.nativeTitle});

  factory NativeTitleResult.fromJson(Map<String, dynamic> json) {
    return NativeTitleResult(
      nativeTitle: json['nativeTitle'] as String? ?? '',
    );
  }
}
