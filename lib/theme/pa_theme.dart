// lib/theme/pa_theme.dart
import 'package:flutter/material.dart';
import 'package:parrokit/theme/components/pa_navigation_bar_theme.dart';
import 'pa_colors.dart';
import 'components/pa_appbar_theme.dart';
import 'components/pa_buttons_theme.dart';
import 'components/pa_card_theme.dart';
import 'components/pa_chip_theme.dart';
import 'components/pa_dropdown_theme.dart';
import 'components/pa_icon_theme.dart';
import 'components/pa_input_theme.dart';
import 'components/pa_tabbar_theme.dart';
import 'components/pa_texts_theme.dart';
import 'components/pa_segmented_button_theme.dart';

class PaTheme {
  static ThemeData light = _buildTheme(Brightness.light);
  static ThemeData dark = _buildTheme(Brightness.dark);

  static ThemeData _buildTheme(Brightness brightness) {
    final isDark = brightness == Brightness.dark;
    final cs = ColorScheme.fromSeed(
      seedColor: PaColors.primary,
      brightness: brightness,
      primary: PaColors.primary,
      onPrimary: Colors.white,
      secondary: PaColors.primarySoft,
      surface: isDark ? PaColors.surfaceDark : PaColors.surface,
      onSurface: isDark ? PaColors.textPrimaryDark : PaColors.textPrimary,
      surfaceTint: Colors.transparent,
    );

    return ThemeData(
      useMaterial3: true,
      brightness: brightness,
      fontFamily: "IBMPlexSansKR",
      colorScheme: cs,
      scaffoldBackgroundColor: cs.surface,

      appBarTheme: paAppBarTheme(cs, isDark: isDark),
      tabBarTheme: paTabBarTheme(cs, isDark: isDark),
      textTheme: paTextTheme(cs, isDark: isDark),
      textSelectionTheme: paTextSelectionTheme(cs, isDark: isDark),
      iconTheme: paIconTheme(cs, isDark: isDark),
      cardTheme: paCardTheme(cs, isDark: isDark),

      elevatedButtonTheme: paElevatedButtonTheme(cs, isDark: isDark),
      outlinedButtonTheme: paOutlinedButtonTheme(cs, isDark: isDark),
      textButtonTheme:     paTextButtonTheme(cs, isDark: isDark),
      toggleButtonsTheme:  paToggleButtonsTheme(cs, isDark: isDark),

      inputDecorationTheme: paInputDecorationTheme(cs, isDark: isDark),
      chipTheme: paChipTheme(cs, isDark: isDark),
      dropdownMenuTheme: paDropdownMenuTheme(cs, isDark: isDark),

      bottomNavigationBarTheme: paBottomNavigationBar(cs, isDark: isDark),
      navigationBarTheme: paNavigationBar(cs, isDark: isDark),

      segmentedButtonTheme: paSegmentedButtonTheme(cs, isDark: isDark),
      dividerColor: isDark ? PaColors.dividerDark : PaColors.divider,
    );
  }
}
