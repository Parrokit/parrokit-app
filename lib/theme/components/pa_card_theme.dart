// lib/theme/components/pa_card_theme.dart
import 'package:flutter/material.dart';

CardTheme paCardTheme(ColorScheme cs, {required bool isDark}) {
  return CardTheme(
    color: cs.surface,
    surfaceTintColor: Colors.transparent,
    elevation: 0,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(16),
      side: BorderSide(
        color: cs.outlineVariant, // 라이트/다크 자동 대응
        width: 1,
      ),
    ),
    margin: EdgeInsets.zero,
  );
}