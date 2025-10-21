// lib/theme/components/pa_chip_theme.dart
import 'package:flutter/material.dart';

ChipThemeData paChipTheme(ColorScheme cs, {required bool isDark}) {
  return ChipThemeData(
    backgroundColor: cs.surface,
    side: BorderSide(color: cs.outlineVariant, width: 1),

    // 라벨 스타일: 기본 onSurface, 조금 옅은 톤
    labelStyle: TextStyle(
      fontSize: 12,
      fontWeight: FontWeight.w700,
      color: cs.onSurface.withOpacity(isDark ? 0.74 : 0.62),
    ),

    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),

    // 선택 시 은은한 primary 채움
    selectedColor: cs.primary.withOpacity(isDark ? 0.20 : 0.12),
    secondarySelectedColor: cs.primary.withOpacity(isDark ? 0.20 : 0.12),
    checkmarkColor: cs.onPrimary,
  );
}