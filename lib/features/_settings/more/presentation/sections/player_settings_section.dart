// ============================================================================
// lib/features/more/presentation/sections/player_settings_section.dart
// ============================================================================
//
// [역할]
// 플레이어 설정 섹션 위젯.
// ============================================================================

import 'package:flutter/material.dart';

import 'package:parrokit/core/config/app_config.dart';
import '../widgets/card_container.dart';
import '../widgets/tiles/dropdown_tile.dart';
import '../widgets/hairline_divider.dart';
import '../widgets/section_title.dart';
import '../widgets/tiles/switch_tile.dart';

/// 플레이어 설정 섹션.
class PlayerSettingsSection extends StatefulWidget {
  const PlayerSettingsSection({super.key});

  @override
  State<PlayerSettingsSection> createState() => _PlayerSettingsSectionState();
}

class _PlayerSettingsSectionState extends State<PlayerSettingsSection> {
  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SectionTitle('플레이어'),
        const SizedBox(height: 10),
        CardContainer(
          child: Column(
            children: [
              SwitchTile(
                icon: Icons.repeat,
                title: '구간 재생',
                value: AppConfig.segmentLoop,
                onChanged: (v) async {
                  setState(() => AppConfig.segmentLoop = v);
                  await AppConfig.saveToPrefs();
                },
              ),
              const HairlineDivider(),
              SwitchTile(
                icon: Icons.loop,
                title: '반복 재생',
                value: AppConfig.repeatAll,
                onChanged: (v) async {
                  setState(() => AppConfig.repeatAll = v);
                  await AppConfig.saveToPrefs();
                },
              ),
              const HairlineDivider(),
              SwitchTile(
                icon: Icons.subtitles_outlined,
                title: '자막 표시',
                value: AppConfig.showSubtitles,
                onChanged: (v) async {
                  setState(() => AppConfig.showSubtitles = v);
                  await AppConfig.saveToPrefs();
                },
              ),
              const HairlineDivider(),
              DropdownTile<double>(
                icon: Icons.speed_outlined,
                title: '기본 재생 속도',
                value: AppConfig.defaultPlaybackRate,
                display: (v) => '${v.toStringAsFixed(2)}x',
                items: const [0.75, 1.0, 1.25, 1.5, 2.0],
                onChanged: (v) async {
                  setState(() => AppConfig.defaultPlaybackRate = v);
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
