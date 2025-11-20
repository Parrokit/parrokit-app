// lib/theme/components/pa_buttons_theme.dart
import 'package:flutter/material.dart';

ButtonStyle _baseButton(ColorScheme cs, {required bool isDark}) {
  return ButtonStyle(
    shape: WidgetStatePropertyAll(
      RoundedRectangleBorder(borderRadius: BorderRadius.circular(40)),
    ),
    elevation: const WidgetStatePropertyAll(0),
  );
}

ElevatedButtonThemeData paElevatedButtonTheme(ColorScheme cs, {required bool isDark}) {
  return ElevatedButtonThemeData(
    style: _baseButton(cs, isDark: isDark).copyWith(
      backgroundColor: WidgetStateProperty.resolveWith((states) {
        if (states.contains(WidgetState.disabled)) {
          return cs.onSurface.withOpacity(0.12); // disabled container
        }
        if (states.contains(WidgetState.pressed)) {
          return cs.primary.withOpacity(0.85);
        }
        if (states.contains(WidgetState.hovered)) {
          return cs.primary.withOpacity(0.92);
        }
        return cs.primary;
      }),
      foregroundColor: WidgetStateProperty.resolveWith((states) {
        if (states.contains(WidgetState.disabled)) {
          return cs.onSurface.withOpacity(0.38); // disabled content
        }
        return cs.onPrimary;
      }),
      overlayColor: WidgetStateProperty.resolveWith((states) {
        if (states.contains(WidgetState.pressed)) {
          return cs.onPrimary.withOpacity(0.16);
        }
        if (states.contains(WidgetState.hovered)) {
          return cs.onPrimary.withOpacity(0.10);
        }
        return null;
      }),
    ),
  );
}

OutlinedButtonThemeData paOutlinedButtonTheme(ColorScheme cs, {required bool isDark}) {
  return OutlinedButtonThemeData(
    style: _baseButton(cs, isDark: isDark).copyWith(
      foregroundColor: WidgetStateProperty.resolveWith((states) {
        if (states.contains(WidgetState.disabled)) {
          return cs.onSurface.withOpacity(0.38);
        }
        return cs.primary;
      }),
      side: WidgetStateProperty.resolveWith((states) {
        if (states.contains(WidgetState.disabled)) {
          return BorderSide(color: cs.outlineVariant.withOpacity(0.3));
        }
        if (states.contains(WidgetState.pressed) || states.contains(WidgetState.hovered)) {
          return BorderSide(color: cs.primary.withOpacity(0.75));
        }
        return BorderSide(color: cs.outlineVariant.withOpacity(0.6));
      }),
      overlayColor: WidgetStateProperty.resolveWith((states) {
        if (states.contains(WidgetState.pressed)) {
          return cs.primary.withOpacity(0.08);
        }
        if (states.contains(WidgetState.hovered)) {
          return cs.primary.withOpacity(0.04);
        }
        return null;
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
          return cs.surface.withOpacity(0.38);
        }
        if (states.contains(WidgetState.pressed)) {
          return cs.primary.withOpacity(0.90);
        }
        return cs.primary;
      }),
      backgroundColor: const WidgetStatePropertyAll(Colors.transparent),
      overlayColor: WidgetStateProperty.resolveWith((states) {
        if (states.contains(WidgetState.pressed)) {
          return cs.primary.withOpacity(0.10);
        }
        if (states.contains(WidgetState.hovered)) {
          return cs.primary.withOpacity(0.05);
        }
        return null;
      }),
    ),
  );
}

ToggleButtonsThemeData paToggleButtonsTheme(ColorScheme cs, {required bool isDark}) {
  return ToggleButtonsThemeData(
    borderRadius: BorderRadius.circular(999),
    borderWidth: 1,
    borderColor: cs.outlineVariant.withOpacity(0.6),
    selectedBorderColor: cs.primary,
    color: cs.onSurface.withOpacity(0.74), // 기본 텍스트/아이콘
    selectedColor: cs.primary,            // 선택 시 파란색 텍스트/아이콘
    fillColor: cs.primary.withOpacity(0.08), // 아주 옅은 파란 배경
  );
}

FilledButtonThemeData paFilledButtonTheme(ColorScheme cs, {required bool isDark}) {
  return FilledButtonThemeData(
    style: _baseButton(cs, isDark: isDark).copyWith(

      backgroundColor: WidgetStateProperty.resolveWith((states) {
        if (states.contains(WidgetState.disabled)) {
          return cs.primary.withOpacity(0.06); // 약한 disabled 배경
        }
        if (states.contains(WidgetState.pressed)) {
          return cs.primary.withOpacity(0.14);
        }
        if (states.contains(WidgetState.hovered)) {
          return cs.primary.withOpacity(0.10);
        }
        return cs.primary;
      }),
      foregroundColor: WidgetStateProperty.resolveWith((states) {
        if (states.contains(WidgetState.disabled)) {
          return cs.onSurface.withOpacity(0.38);
        }
        return cs.onPrimary;
      }),
      overlayColor: WidgetStateProperty.resolveWith((states) {
        if (states.contains(WidgetState.pressed)) {
          return cs.primary.withOpacity(0.10);
        }
        if (states.contains(WidgetState.hovered)) {
          return cs.primary.withOpacity(0.06);
        }
        return null;
      }),
    ),
  );
}