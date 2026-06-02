// lib/core/theme/components/app_switch_theme.dart
//
// Switch 테마 - 토글 스위치 스타일 통합

import 'package:flutter/material.dart';

/// Switch 테마
SwitchThemeData appSwitchTheme(ColorScheme cs, {required bool isDark}) {
  return SwitchThemeData(
    thumbColor: WidgetStateProperty.resolveWith((states) {
      if (states.contains(WidgetState.disabled)) {
        return cs.onSurface.withValues(alpha: 0.38);
      }
      if (states.contains(WidgetState.selected)) {
        return cs.onPrimary;
      }
      return cs.outline;
    }),
    trackColor: WidgetStateProperty.resolveWith((states) {
      if (states.contains(WidgetState.disabled)) {
        return cs.onSurface.withValues(alpha: 0.12);
      }
      if (states.contains(WidgetState.selected)) {
        return cs.primary;
      }
      return cs.surfaceContainerHighest;
    }),
    trackOutlineColor: WidgetStateProperty.resolveWith((states) {
      if (states.contains(WidgetState.selected)) {
        return Colors.transparent;
      }
      return cs.outline.withValues(alpha: 0.5);
    }),
    trackOutlineWidth: const WidgetStatePropertyAll(1),
    splashRadius: 20,
    materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
  );
}
