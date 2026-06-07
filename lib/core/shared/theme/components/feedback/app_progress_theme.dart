// lib/core/theme/components/app_progress_theme.dart
//
// Progress Indicator 테마 - 로딩 인디케이터 스타일 통합

import 'package:flutter/material.dart';

/// Circular Progress Indicator 테마
ProgressIndicatorThemeData appProgressIndicatorTheme(ColorScheme cs,
    {required bool isDark}) {
  return ProgressIndicatorThemeData(
    color: cs.primary,
    linearTrackColor: cs.primary.withValues(alpha: 0.12),
    circularTrackColor: cs.primary.withValues(alpha: 0.12),
    refreshBackgroundColor: cs.surface,
    linearMinHeight: 4,
  );
}
