// lib/core/theme/app_spacing.dart
//
// 앱 전역 간격 시스템 - 일관된 여백과 간격 적용

/// 앱 전역 간격 상수
///
/// 4dp 기반 그리드 시스템 적용
abstract final class AppSpacing {
  // ─────────────────────────────────────────────────────────────────
  // Base Grid (4dp)
  // ─────────────────────────────────────────────────────────────────

  /// 극소 (4dp)
  static const double xs = 4;

  /// 소 (8dp)
  static const double sm = 8;

  /// 중 (12dp)
  static const double md = 12;

  /// 대 (16dp)
  static const double lg = 16;

  /// 특대 (20dp)
  static const double xl = 20;

  /// 극대 (24dp)
  static const double xxl = 24;

  /// 초대 (32dp)
  static const double xxxl = 32;

  // ─────────────────────────────────────────────────────────────────
  // Semantic Aliases
  // ─────────────────────────────────────────────────────────────────

  /// 페이지 수평 패딩 (20dp)
  static const double pagePadding = xl;

  /// 카드 내부 패딩 (14dp)
  static const double cardPadding = 14;

  /// 섹션 간격 (24dp)
  static const double sectionGap = xxl;

  /// 아이템 간격 (12dp)
  static const double itemGap = md;

  /// 인라인 간격 (8dp)
  static const double inlineGap = sm;

  /// 텍스트 줄 간격 (4dp)
  static const double lineGap = xs;
}
