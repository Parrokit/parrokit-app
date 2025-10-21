import 'package:flutter/material.dart';
import 'package:parrokit/config/pa_config.dart';
import 'action_icon.dart'; // ✅ 방금 주신 ActionIcon 불러옴



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
