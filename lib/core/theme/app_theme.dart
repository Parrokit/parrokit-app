// lib/theme/app_theme.dart
import 'package:flutter/material.dart';
import 'app_colors.dart';

// Navigation
import 'components/navigation/app_appbar_theme.dart';
import 'components/navigation/app_tabbar_theme.dart';
import 'components/navigation/app_navigation_bar_theme.dart';

// Typography & Icons
import 'components/typography/app_texts_theme.dart';
import 'components/typography/app_icon_theme.dart';

// Buttons
import 'components/buttons/app_buttons_theme.dart';
import 'components/buttons/app_fab_theme.dart';

// Inputs
import 'components/inputs/app_input_theme.dart';
import 'components/inputs/app_switch_theme.dart';
import 'components/inputs/app_checkbox_theme.dart';
import 'components/inputs/app_slider_theme.dart';

// Surfaces & Containers
import 'components/surfaces/app_card_theme.dart';
import 'components/surfaces/app_chip_theme.dart';
import 'components/surfaces/app_dropdown_theme.dart';
import 'components/surfaces/app_popup_menu_theme.dart';
import 'components/surfaces/app_list_tile_theme.dart';
import 'components/surfaces/app_segmented_button_theme.dart';

// Feedback
import 'components/feedback/app_dialog_theme.dart';
import 'components/feedback/app_bottom_sheet_theme.dart';
import 'components/feedback/app_snackbar_theme.dart';
import 'components/feedback/app_progress_theme.dart';

class AppTheme {
  static ThemeData light = _buildTheme(Brightness.light);
  static ThemeData dark = _buildTheme(Brightness.dark);

  static ThemeData _buildTheme(Brightness brightness) {
    final isDark = brightness == Brightness.dark;
    final cs = ColorScheme.fromSeed(
      seedColor: AppColors.primary,
      brightness: brightness,
      primary: AppColors.primary,
      onPrimary: Colors.white,
      secondary: AppColors.primarySoft,
      surface: isDark ? AppColors.surfaceDark : AppColors.surface,
      onSurface: isDark ? AppColors.textPrimaryDark : AppColors.textPrimary,
      surfaceTint: Colors.transparent,
    );

    return ThemeData(
      useMaterial3: true,
      brightness: brightness,
      fontFamily: "IBMPlexSansKR",
      colorScheme: cs,
      scaffoldBackgroundColor: cs.surface,

      // ─────────────────────────────────────────────────────────────────
      // Navigation
      // ─────────────────────────────────────────────────────────────────
      appBarTheme: appAppBarTheme(cs, isDark: isDark),
      tabBarTheme: appTabBarTheme(cs, isDark: isDark),
      bottomNavigationBarTheme: appBottomNavigationBar(cs, isDark: isDark),
      navigationBarTheme: appNavigationBar(cs, isDark: isDark),

      // ─────────────────────────────────────────────────────────────────
      // Typography & Icons
      // ─────────────────────────────────────────────────────────────────
      textTheme: appTextTheme(cs, isDark: isDark),
      textSelectionTheme: appTextSelectionTheme(cs, isDark: isDark),
      iconTheme: appIconTheme(cs, isDark: isDark),

      // ─────────────────────────────────────────────────────────────────
      // Buttons
      // ─────────────────────────────────────────────────────────────────
      elevatedButtonTheme: appElevatedButtonTheme(cs, isDark: isDark),
      outlinedButtonTheme: appOutlinedButtonTheme(cs, isDark: isDark),
      textButtonTheme: appTextButtonTheme(cs, isDark: isDark),
      toggleButtonsTheme: appToggleButtonsTheme(cs, isDark: isDark),
      filledButtonTheme: appFilledButtonTheme(cs, isDark: isDark),
      floatingActionButtonTheme: appFabTheme(cs, isDark: isDark),

      // ─────────────────────────────────────────────────────────────────
      // Inputs
      // ─────────────────────────────────────────────────────────────────
      inputDecorationTheme: appInputDecorationTheme(cs, isDark: isDark),
      switchTheme: appSwitchTheme(cs, isDark: isDark),
      checkboxTheme: appCheckboxTheme(cs, isDark: isDark),
      sliderTheme: appSliderTheme(cs, isDark: isDark),

      // ─────────────────────────────────────────────────────────────────
      // Surfaces & Containers
      // ─────────────────────────────────────────────────────────────────
      cardTheme: appCardTheme(cs, isDark: isDark),
      chipTheme: appChipTheme(cs, isDark: isDark),
      dropdownMenuTheme: appDropdownMenuTheme(cs, isDark: isDark),
      popupMenuTheme: appPopupMenuTheme(cs, isDark: isDark),
      listTileTheme: appListTileTheme(cs, isDark: isDark),
      segmentedButtonTheme: appSegmentedButtonTheme(cs, isDark: isDark),

      // ─────────────────────────────────────────────────────────────────
      // Feedback
      // ─────────────────────────────────────────────────────────────────
      dialogTheme: appDialogTheme(cs, isDark: isDark),
      bottomSheetTheme: appBottomSheetTheme(cs, isDark: isDark),
      snackBarTheme: appSnackBarTheme(cs, isDark: isDark),
      progressIndicatorTheme: appProgressIndicatorTheme(cs, isDark: isDark),

      // ─────────────────────────────────────────────────────────────────
      // Misc
      // ─────────────────────────────────────────────────────────────────
      dividerColor: isDark ? AppColors.dividerDark : AppColors.divider,
    );
  }
}
