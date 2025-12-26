// lib/core/theme/app_shadows.dart
//
// 앱 전역 그림자 시스템 - 일관된 elevation 적용

import 'package:flutter/material.dart';

/// 앱 전역 그림자 상수
///
/// Material 3 elevation 시스템 기반
abstract final class AppShadows {
  // ─────────────────────────────────────────────────────────────────
  // Light Mode Shadows
  // ─────────────────────────────────────────────────────────────────

  /// 없음
  static const List<BoxShadow> none = [];

  /// 미세 그림자 - 카드, 타일
  static List<BoxShadow> subtle(bool isDark) => [
        BoxShadow(
          color: isDark
              ? Colors.black.withValues(alpha: 0.3)
              : Colors.black.withValues(alpha: 0.04),
          blurRadius: 4,
          offset: const Offset(0, 1),
        ),
      ];

  /// 작은 그림자 - 팝업, 드롭다운
  static List<BoxShadow> sm(bool isDark) => [
        BoxShadow(
          color: isDark
              ? Colors.black.withValues(alpha: 0.4)
              : Colors.black.withValues(alpha: 0.08),
          blurRadius: 8,
          offset: const Offset(0, 2),
        ),
      ];

  /// 중간 그림자 - 모달, 다이얼로그
  static List<BoxShadow> md(bool isDark) => [
        BoxShadow(
          color: isDark
              ? Colors.black.withValues(alpha: 0.5)
              : Colors.black.withValues(alpha: 0.12),
          blurRadius: 16,
          offset: const Offset(0, 4),
        ),
      ];

  /// 큰 그림자 - 바텀시트
  static List<BoxShadow> lg(bool isDark) => [
        BoxShadow(
          color: isDark
              ? Colors.black.withValues(alpha: 0.6)
              : Colors.black.withValues(alpha: 0.16),
          blurRadius: 24,
          offset: const Offset(0, 8),
        ),
      ];

  /// 특대 그림자 - 풀스크린 오버레이
  static List<BoxShadow> xl(bool isDark) => [
        BoxShadow(
          color: isDark
              ? Colors.black.withValues(alpha: 0.7)
              : Colors.black.withValues(alpha: 0.20),
          blurRadius: 32,
          offset: const Offset(0, 12),
        ),
      ];

  // ─────────────────────────────────────────────────────────────────
  // Semantic Aliases
  // ─────────────────────────────────────────────────────────────────

  /// 카드 그림자
  static List<BoxShadow> card(bool isDark) => subtle(isDark);

  /// 팝업메뉴 그림자
  static List<BoxShadow> popup(bool isDark) => sm(isDark);

  /// 다이얼로그 그림자
  static List<BoxShadow> dialog(bool isDark) => md(isDark);

  /// 바텀시트 그림자
  static List<BoxShadow> bottomSheet(bool isDark) => lg(isDark);
}
