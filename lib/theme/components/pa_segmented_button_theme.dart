// lib/theme/components/pa_segmented_button_theme.dart
import 'package:flutter/material.dart';

SegmentedButtonThemeData paSegmentedButtonTheme(ColorScheme cs, {required bool isDark}) {
  return SegmentedButtonThemeData(
    style: ButtonStyle(
      shape: WidgetStatePropertyAll(
        RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
      padding: const WidgetStatePropertyAll(
        EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      ),

      // 선: 선택 시 primary, 기본은 outlineVariant(헤어라인 느낌)
      side: WidgetStateProperty.resolveWith((states) {
        final selected = states.contains(WidgetState.selected);
        return BorderSide(
          color: selected ? cs.primary : cs.outlineVariant,
          width: selected ? 1.2 : 0.8,
        );
      }),

      // 배경: 선택 시 은은한 채움, 비선택은 surface
      backgroundColor: WidgetStateProperty.resolveWith((states) {
        final selected = states.contains(WidgetState.selected);
        final selOpacity = isDark ? 0.16 : 0.12; // 다크에서 약간 더 진하게
        return selected ? cs.primary.withOpacity(selOpacity) : cs.surface;
      }),

      // 글자/아이콘: 선택 시 primary, 평소엔 onSurface
      foregroundColor: WidgetStateProperty.resolveWith((states) {
        final selected = states.contains(WidgetState.selected);
        return selected ? cs.primary : cs.onSurface;
      }),

      textStyle: const WidgetStatePropertyAll(
        TextStyle(fontWeight: FontWeight.w700),
      ),

      // hover/pressed 효과: onSurface 기반 투명도
      overlayColor: WidgetStateProperty.resolveWith((states) {
        if (states.contains(WidgetState.pressed)) {
          return cs.onSurface.withOpacity(isDark ? 0.10 : 0.06);
        }
        if (states.contains(WidgetState.hovered)) {
          return cs.onSurface.withOpacity(isDark ? 0.08 : 0.04);
        }
        return null;
      }),

      visualDensity: const VisualDensity(horizontal: -1, vertical: -1),
      animationDuration: const Duration(milliseconds: 140),
    ),
  );
}