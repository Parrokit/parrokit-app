// ============================================================================
// lib/features/more/presentation/sections/app_settings_section.dart
// ============================================================================
//
// [역할]
// 앱 설정 섹션 위젯 (테마 등).
// ============================================================================

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:parrokit/core/provider/theme_provider.dart';
import '../widgets/card_container.dart';
import '../widgets/section_title.dart';
import '../widgets/tiles/theme_tile.dart';

/// 앱 설정 섹션.
class AppSettingsSection extends StatelessWidget {
  const AppSettingsSection({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SectionTitle('앱'),
        const SizedBox(height: 10),
        CardContainer(
          child: Column(
            children: [
              ThemeTile(
                value: context.watch<ThemeProvider>().themeMode,
                onChanged: (mode) {
                  context.read<ThemeProvider>().setTheme(mode);
                },
              ),
            ],
          ),
        ),
      ],
    );
  }
}
