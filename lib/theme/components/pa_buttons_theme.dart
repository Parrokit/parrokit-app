// lib/theme/components/pa_buttons_theme.dart
import 'package:flutter/material.dart';

ButtonStyle _baseButton(ColorScheme cs, {required bool isDark}) {
  return ButtonStyle(
    shape: WidgetStatePropertyAll(
      RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
    ),
    padding: const WidgetStatePropertyAll(
      EdgeInsets.symmetric(horizontal: 14, vertical: 12),
    ),
    elevation: const WidgetStatePropertyAll(0),

    // disable/hover/pressed 등 공통 overlay
    overlayColor: WidgetStateProperty.resolveWith((states) {
      if (states.contains(WidgetState.disabled)) return null;
      if (states.contains(WidgetState.pressed)) {
        return cs.onSurface.withOpacity(isDark ? 0.10 : 0.06);
      }
      if (states.contains(WidgetState.hovered)) {
        return cs.onSurface.withOpacity(isDark ? 0.08 : 0.04);
      }
      return null;
    }),

    // 텍스트 스타일(컴포넌트마다 덮어쓸 수 있음)
    textStyle: const WidgetStatePropertyAll(
      TextStyle(fontWeight: FontWeight.w800, fontSize: 14),
    ),
    visualDensity: const VisualDensity(horizontal: -1, vertical: -1),
    animationDuration: const Duration(milliseconds: 140),
  );
}

ElevatedButtonThemeData paElevatedButtonTheme(ColorScheme cs, {required bool isDark}) {
  return ElevatedButtonThemeData(
    style: _baseButton(cs, isDark: isDark).copyWith(
      backgroundColor: WidgetStateProperty.resolveWith((states) {
        if (states.contains(WidgetState.disabled)) {
          return cs.onSurface.withOpacity(0.12); // M3 disabled 컨테이너
        }
        return cs.primary;
      }),
      foregroundColor: WidgetStateProperty.resolveWith((states) {
        if (states.contains(WidgetState.disabled)) {
          return cs.onSurface.withOpacity(0.38); // M3 disabled content
        }
        return cs.onPrimary;
      }),
    ),
  );
}

OutlinedButtonThemeData paOutlinedButtonTheme(ColorScheme cs, {required bool isDark}) {
  return OutlinedButtonThemeData(
    style: _baseButton(cs, isDark: isDark).copyWith(
      side: WidgetStateProperty.resolveWith((states) {
        final disabled = states.contains(WidgetState.disabled);
        return BorderSide(
          color: disabled ? cs.onSurface.withOpacity(0.12) : cs.outlineVariant,
          width: 1,
        );
      }),
      backgroundColor: WidgetStatePropertyAll(cs.surface),
      foregroundColor: WidgetStateProperty.resolveWith((states) {
        if (states.contains(WidgetState.disabled)) {
          return cs.onSurface.withOpacity(0.38);
        }
        return cs.onSurface;
      }),
    ),
  );
}

TextButtonThemeData paTextButtonTheme(ColorScheme cs, {required bool isDark}) {
  return TextButtonThemeData(
    style: _baseButton(cs, isDark: isDark).copyWith(
      padding: const WidgetStatePropertyAll(
        EdgeInsets.symmetric(horizontal: 8, vertical: 8),
      ),
      shape: WidgetStatePropertyAll(
        RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
      foregroundColor: WidgetStateProperty.resolveWith((states) {
        if (states.contains(WidgetState.disabled)) {
          return cs.onSurface.withOpacity(0.38);
        }
        return cs.primary;
      }),
      // 텍스트 버튼은 배경 없음
      backgroundColor: const WidgetStatePropertyAll(Colors.transparent),
    ),
  );
}

ToggleButtonsThemeData paToggleButtonsTheme(ColorScheme cs, {required bool isDark}) {
  return ToggleButtonsThemeData(
    borderRadius: BorderRadius.circular(12),
    // 경계선
    borderColor: cs.outlineVariant,
    selectedBorderColor: cs.primary,
    // 글자/아이콘 색
    color: cs.onSurface.withOpacity(0.74), // 기본
    selectedColor: cs.onPrimary,           // 선택 글자/아이콘(컨테이너 대비)
    // 채움
    fillColor: cs.primary,
  );
}