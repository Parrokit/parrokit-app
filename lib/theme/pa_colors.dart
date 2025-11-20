// lib/theme/pa_colors.dart
import 'package:flutter/material.dart';

class PaColors {
  // === Base (Light) ===
  /// Flutter 3.18 이후로 들어간 머티리얼 디자인 3(Material 3)에서
  /// Background color는 Surface color로 대체 (onBackground는 onSurface로 대체)
  static const Color surface    = Color(0xFFFFFFFF);
  static const Color divider    = Color(0x1A000000);

  // Text (Light)
  static const Color textPrimary   = Color(0xFF111418);
  static const Color textSecondary = Color(0xFF5B636E);
  static const Color textTertiary  = Color(0xFF8C95A1);

  // Accent (Toss-like Blue)
  static const Color primary     = Color(0xFF0064FF);
  static const Color primarySoft = Color(0xFFDFE9FF);

  // Feedback
  static const Color success = Color(0xFF16A34A);
  static const Color warning = Color(0xFFF59E0B);
  static const Color danger  = Color(0xFFDC2626);

  // === Base (Dark) ===
  static const Color surfaceDark    = Color(0xFF0D0F12);
  static const Color dividerDark    = Color(0x33FFFFFF);

  // Text
  static const Color textPrimaryDark   = Color(0xFFECEFF3);
  static const Color textSecondaryDark = Color(0xFFB0B8C1);
  static const Color textTertiaryDark  = Color(0xFF7A828C);

  // Accent
  static const Color primaryDark     = Color(0xFF3C8DFF);
  static const Color primarySoftDark = Color(0xFFDFE9FF);

  // Feedback
  static const Color successDark = Color(0xFF22C55E);
  static const Color warningDark = Color(0xFFFBBF24);
  static const Color dangerDark  = Color(0xFFEF4444);
}