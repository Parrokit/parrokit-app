// lib/theme/components/pa_tabbar_theme.dart
import 'package:flutter/material.dart';

TabBarTheme paTabBarTheme(ColorScheme cs, {required bool isDark}) {
  return TabBarTheme(
    indicatorSize: TabBarIndicatorSize.label,

    // 선택/비선택 라벨 색상
    labelColor: cs.onSurface,
    unselectedLabelColor: cs.onSurface.withOpacity(isDark ? 0.74 : 0.62),

    // 선택/비선택 라벨 스타일
    labelStyle: const TextStyle(fontWeight: FontWeight.w900),
    unselectedLabelStyle: const TextStyle(fontWeight: FontWeight.w700),

    // 인디케이터 색상 (primary 고정)
    indicator: UnderlineTabIndicator(
      borderSide: BorderSide(color: cs.primary, width: 2),
    ),
  );
}