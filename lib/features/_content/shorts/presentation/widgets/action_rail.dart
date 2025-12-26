// ============================================================================
// lib/features/_content/shorts/presentation/widgets/action_rail.dart
// ============================================================================
//
// [역할]
// 쇼츠 화면 우측에 배치되는 액션 버튼들의 모음(Rail).
//
// [기능]
// - 자동 넘김(Auto Next) 토글
// - 자막(Subtitle) 표시 토글
// - 외부 플레이어(Player) 열기
//
// [레이어]
// Presentation Layer > Widgets
//
// ============================================================================

import 'package:flutter/material.dart';
import 'action_icon.dart';

/// [역할]
/// 쇼츠 화면 우측 사이드바(액션 레일).
///
/// 여러 개의 [ActionIcon]을 세로로 배치하여 주요 기능을 제공합니다.
class ActionRail extends StatelessWidget {
  final bool autoNextEnabled;
  final void Function(bool enabled) onAutoNextChanged;
  final VoidCallback onOpenExternalPlayer;

  final bool showSubtitle;
  final void Function(bool enabled) onSubtitleChanged;

  const ActionRail({
    super.key,
    required this.autoNextEnabled,
    required this.onAutoNextChanged,
    required this.onOpenExternalPlayer,
    required this.showSubtitle,
    required this.onSubtitleChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // ✅ AutoNext toggle
        ActionIcon(
          icon: Icons.playlist_play,
          label: "Auto",
          active: autoNextEnabled,
          onTap: () => onAutoNextChanged(!autoNextEnabled),
        ),

        const SizedBox(height: 16),
        // ✅ Subtitle toggle
        ActionIcon(
          icon: showSubtitle ? Icons.closed_caption : Icons.closed_caption_off,
          label: "CC",
          active: showSubtitle,
          onTap: () => onSubtitleChanged(!showSubtitle),
        ),
        const SizedBox(height: 16),

        // ✅ External player
        ActionIcon(
          icon: Icons.open_in_new,
          label: "Player",
          onTap: onOpenExternalPlayer,
        ),
      ],
    );
  }
}
