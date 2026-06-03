import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';

/// 비디오 플레이어 전용 컨트롤 바.
/// [-3초] [처음으로] [재생/일시정지] [+3초] 버튼으로 구성된다.
class VideoControlsBar extends StatefulWidget {
  const VideoControlsBar({
    super.key,
    required this.controller,
    required this.onPlayInline,
    required this.onToggleInline,
    required this.onStopInline,
  });

  final VideoPlayerController? controller;
  final VoidCallback onPlayInline;
  final VoidCallback onToggleInline;
  final VoidCallback onStopInline;

  @override
  State<VideoControlsBar> createState() => _VideoControlsBarState();
}

class _VideoControlsBarState extends State<VideoControlsBar> {
  @override
  void initState() {
    super.initState();
    widget.controller?.addListener(_onControllerUpdate);
  }

  @override
  void didUpdateWidget(VideoControlsBar oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.controller != widget.controller) {
      oldWidget.controller?.removeListener(_onControllerUpdate);
      widget.controller?.addListener(_onControllerUpdate);
    }
  }

  @override
  void dispose() {
    widget.controller?.removeListener(_onControllerUpdate);
    super.dispose();
  }

  void _onControllerUpdate() {
    if (mounted) setState(() {});
  }

  bool get _isInitialized =>
      widget.controller != null && widget.controller!.value.isInitialized;

  void _seekRelative(Duration delta) {
    final c = widget.controller;
    if (c == null || !c.value.isInitialized) return;
    final next = c.value.position + delta;
    final clamped = next.isNegative
        ? Duration.zero
        : next > c.value.duration
            ? c.value.duration
            : next;
    c.seekTo(clamped);
  }

  void _seekToStart() {
    final c = widget.controller;
    if (c == null || !c.value.isInitialized) return;
    c.seekTo(Duration.zero);
  }

  IconData get _playIcon {
    final c = widget.controller;
    if (c == null || !c.value.isInitialized) return Icons.play_arrow_rounded;
    if (c.value.isPlaying) return Icons.pause_rounded;
    if (c.value.position >= c.value.duration) return Icons.replay_rounded;
    return Icons.play_arrow_rounded;
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final bgColor = isDark
        ? cs.surfaceContainerHigh
        : cs.surfaceContainerLow;

    return Container(
      color: bgColor,
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // -3초
          _ControlButton(
            icon: Icons.replay_5_rounded,
            label: '3초 전',
            onTap: _isInitialized
                ? () => _seekRelative(const Duration(seconds: -3))
                : null,
            cs: cs,
            size: 26,
          ),
          const SizedBox(width: 16),
          // 처음으로
          _ControlButton(
            icon: Icons.skip_previous_rounded,
            label: '처음으로',
            onTap: _isInitialized ? _seekToStart : null,
            cs: cs,
            size: 26,
          ),
          const SizedBox(width: 16),
          // 재생 / 일시정지 (강조)
          _PlayButton(
            icon: _playIcon,
            onTap: () {
              if (!_isInitialized) {
                widget.onPlayInline();
              } else {
                widget.onToggleInline();
              }
            },
            cs: cs,
          ),
          const SizedBox(width: 16),
          // +3초
          _ControlButton(
            icon: Icons.forward_5_rounded,
            label: '3초 후',
            onTap: _isInitialized
                ? () => _seekRelative(const Duration(seconds: 3))
                : null,
            cs: cs,
            size: 26,
          ),
        ],
      ),
    );
  }
}

class _PlayButton extends StatelessWidget {
  const _PlayButton({
    required this.icon,
    required this.onTap,
    required this.cs,
  });

  final IconData icon;
  final VoidCallback? onTap;
  final ColorScheme cs;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 52,
        height: 52,
        decoration: BoxDecoration(
          color: cs.primary,
          shape: BoxShape.circle,
        ),
        child: Icon(icon, color: cs.onPrimary, size: 28),
      ),
    );
  }
}

class _ControlButton extends StatelessWidget {
  const _ControlButton({
    required this.icon,
    required this.label,
    required this.onTap,
    required this.cs,
    this.size = 24,
  });

  final IconData icon;
  final String label;
  final VoidCallback? onTap;
  final ColorScheme cs;
  final double size;

  @override
  Widget build(BuildContext context) {
    final enabled = onTap != null;
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        GestureDetector(
          onTap: onTap,
          child: Icon(
            icon,
            size: size,
            color: enabled
                ? cs.onSurfaceVariant
                : cs.onSurface.withValues(alpha: 0.3),
          ),
        ),
        const SizedBox(height: 2),
        Text(
          label,
          style: TextStyle(
            fontSize: 9,
            color: enabled
                ? cs.onSurfaceVariant
                : cs.onSurface.withValues(alpha: 0.3),
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }
}
