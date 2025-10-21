// lib/theme/components/pa_icon_theme.dart
import 'package:flutter/material.dart';

IconThemeData paIconTheme(ColorScheme cs, {required bool isDark}) {
  return IconThemeData(
    size: 20,
    color: cs.onSurface,
  );
}