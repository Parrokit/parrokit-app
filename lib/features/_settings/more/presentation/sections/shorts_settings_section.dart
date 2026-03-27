// ============================================================================
// lib/features/more/presentation/sections/shorts_settings_section.dart
// ============================================================================
//
// [역할]
// 쇼츠 설정 섹션 위젯.
// ============================================================================

import 'package:flutter/material.dart';

import 'package:parrokit/core/config/app_config.dart';
import '../widgets/card_container.dart';
import '../widgets/hairline_divider.dart';
import '../widgets/section_title.dart';
import '../widgets/switch_tile.dart';

/// 쇼츠 설정 섹션.
class ShortsSettingsSection extends StatefulWidget {
  const ShortsSettingsSection({super.key});

  @override
  State<ShortsSettingsSection> createState() => _ShortsSettingsSectionState();
}

class _ShortsSettingsSectionState extends State<ShortsSettingsSection> {
  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SectionTitle('쇼츠'),
        const SizedBox(height: 10),
        CardContainer(
          child: Column(
            children: [
              SwitchTile(
                icon: Icons.play_circle_outline,
                title: '자동 넘기기',
                value: AppConfig.autoNext,
                onChanged: (v) async {
                  setState(() => AppConfig.autoNext = v);
                  await AppConfig.saveToPrefs();
                },
              ),
              const HairlineDivider(),
              SwitchTile(
                icon: Icons.subtitles_outlined,
                title: '자막 표시',
                value: AppConfig.shortsShowSubtitles,
                onChanged: (v) async {
                  setState(() => AppConfig.shortsShowSubtitles = v);
                  await AppConfig.saveToPrefs();
                },
              ),
            ],
          ),
        ),
      ],
    );
  }
}
