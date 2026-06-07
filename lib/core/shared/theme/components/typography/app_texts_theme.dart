// lib/theme/components/app_texts_theme.dart
import 'package:flutter/material.dart';

TextTheme appTextTheme(ColorScheme cs, {required bool isDark}) {
  final cPrimary = cs.onSurface;
  final cSecondary = cs.onSurface.withValues(alpha: 0.74);
  final cTertiary = cs.onSurface.withValues(alpha: 0.56);

  return TextTheme(
    headlineSmall:
        TextStyle(fontSize: 20, fontWeight: FontWeight.w900, color: cPrimary),
    titleMedium:
        TextStyle(fontSize: 16, fontWeight: FontWeight.w800, color: cPrimary),
    bodyLarge:
        TextStyle(fontSize: 15, fontWeight: FontWeight.w700, color: cPrimary),
    bodyMedium:
        TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: cSecondary),
    bodySmall:
        TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: cTertiary),
    labelLarge: TextStyle(
        fontSize: 14, fontWeight: FontWeight.w800, color: cs.onPrimary),
  );
}

TextSelectionThemeData appTextSelectionTheme(ColorScheme cs,
    {required bool isDark}) {
  return TextSelectionThemeData(
    cursorColor: cs.primary,
    selectionColor: cs.primary.withValues(alpha: 0.16),
    selectionHandleColor: cs.primary,
  );
}
