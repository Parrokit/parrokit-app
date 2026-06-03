import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';

/// 음성 파형 그래프 위젯.
/// 재생 진행도에 따라 왼쪽 구간은 primary 색상, 나머지는 흐리게 표시한다.
class AudioWaveformBar extends StatefulWidget {
  const AudioWaveformBar({
    super.key,
    required this.controller,
    this.barCount = 60,
    this.height = 48,
  });

  final VideoPlayerController? controller;
  final int barCount;
  final double height;

  @override
  State<AudioWaveformBar> createState() => _AudioWaveformBarState();
}

class _AudioWaveformBarState extends State<AudioWaveformBar> {
  // 고정된 난수 파형 값 (실제 오디오 분석 없이 시각적 데모용)
  late final List<double> _bars;

  @override
  void initState() {
    super.initState();
    final rng = math.Random(42);
    _bars = List.generate(
      widget.barCount,
      (i) {
        // 양끝은 낮게, 가운데는 높게 — 자연스러운 파형 분포
        final center = math.sin(i / widget.barCount * math.pi);
        final noise = rng.nextDouble() * 0.5 + 0.1;
        return (center * 0.6 + noise * 0.4).clamp(0.08, 1.0);
      },
    );
    widget.controller?.addListener(_onControllerUpdate);
  }

  @override
  void didUpdateWidget(AudioWaveformBar oldWidget) {
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

  double get _progress {
    final c = widget.controller;
    if (c == null || !c.value.isInitialized) return 0.0;
    final dur = c.value.duration.inMilliseconds;
    if (dur == 0) return 0.0;
    return (c.value.position.inMilliseconds / dur).clamp(0.0, 1.0);
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final progress = _progress;

    return SizedBox(
      height: widget.height,
      child: GestureDetector(
        onTapDown: (details) => _seekTo(context, details.localPosition.dx),
        onHorizontalDragUpdate: (details) =>
            _seekTo(context, details.localPosition.dx),
        behavior: HitTestBehavior.opaque,
        child: LayoutBuilder(
          builder: (context, constraints) {
            final totalWidth = constraints.maxWidth;
            final barWidth = (totalWidth / widget.barCount) * 0.55;
            final gap = (totalWidth / widget.barCount) * 0.45;
            final progressIndex = (progress * widget.barCount).floor();

            return Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: List.generate(widget.barCount, (i) {
                final isPlayed = i < progressIndex;
                final isCurrent = i == progressIndex;
                final barH = _bars[i] * widget.height * 0.85;

                Color barColor;
                if (isPlayed) {
                  barColor = cs.primary;
                } else if (isCurrent) {
                  barColor = cs.primary.withValues(alpha: 0.7);
                } else {
                  barColor = isDark
                      ? cs.onSurface.withValues(alpha: 0.18)
                      : cs.onSurface.withValues(alpha: 0.13);
                }

                return Padding(
                  padding: EdgeInsets.only(right: gap),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 80),
                    width: barWidth,
                    height: barH.clamp(3.0, widget.height),
                    decoration: BoxDecoration(
                      color: barColor,
                      borderRadius: BorderRadius.circular(barWidth / 2),
                    ),
                  ),
                );
              }),
            );
          },
        ),
      ),
    );
  }

  void _seekTo(BuildContext context, double localX) {
    final c = widget.controller;
    if (c == null || !c.value.isInitialized) return;
    final box = context.findRenderObject() as RenderBox?;
    if (box == null) return;
    final ratio = (localX / box.size.width).clamp(0.0, 1.0);
    final dur = c.value.duration;
    c.seekTo(dur * ratio);
  }
}
