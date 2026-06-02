// lib/core/theme/components/app_list_tile_theme.dart
//
// ListTile 테마 - 목록 항목 스타일 통합

import 'package:flutter/material.dart';

/// ListTile 테마
ListTileThemeData appListTileTheme(ColorScheme cs, {required bool isDark}) {
  return ListTileThemeData(
    tileColor: Colors.transparent,
    selectedTileColor: cs.primary.withValues(alpha: 0.08),
    iconColor: cs.onSurface.withValues(alpha: 0.74),
    textColor: cs.onSurface,
    selectedColor: cs.primary,
    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
    minVerticalPadding: 8,
    horizontalTitleGap: 12,
    minLeadingWidth: 24,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(12),
    ),
    enableFeedback: true,
    dense: false,
    visualDensity: VisualDensity.compact,
    titleTextStyle: TextStyle(
      fontSize: 16,
      fontWeight: FontWeight.w600,
      color: cs.onSurface,
    ),
    subtitleTextStyle: TextStyle(
      fontSize: 13,
      fontWeight: FontWeight.w500,
      color: cs.onSurface.withValues(alpha: 0.6),
    ),
    leadingAndTrailingTextStyle: TextStyle(
      fontSize: 14,
      fontWeight: FontWeight.w600,
      color: cs.onSurface.withValues(alpha: 0.74),
    ),
  );
}
