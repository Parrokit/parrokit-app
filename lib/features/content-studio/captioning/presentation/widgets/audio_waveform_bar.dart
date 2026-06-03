import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';

/// 오디오 파형 그래프 위젯.
///
/// [waveformData]가 null이면 로딩 상태를 표시한다.
/// [waveformData]가 비어있으면 폴백 더미 파형을 사용한다.
/// 재생 진행도에 따라 왼쪽 구간은 primary 색상, 나머지는 흐리게 표시한다.
/// 탭·드래그로 비디오를 탐색(seek)할 수 있다.
class AudioWaveformBar extends StatefulWidget {
  const AudioWaveformBar({
    super.key,
    required this.videoController,
    this.waveformData,
    this.isLoading = false,
    this.barCount = 60,
    this.height = 48,
  });

  /// 재생 위치 동기화에 사용하는 비디오 컨트롤러.
  final VideoPlayerController? videoController;

  /// 실제 오디오 파형 데이터 (0.0 ~ 1.0).
  /// null이면 로딩 상태, 빈 리스트면 더미 파형으로 폴백.
  final List<double>? waveformData;

  final bool isLoading;
  final int barCount;
  final double height;

  @override
  State<AudioWaveformBar> createState() => _AudioWaveformBarState();
}

class _AudioWaveformBarState extends State<AudioWaveformBar> {
  late List<double> _bars;

  @override
  void initState() {
    super.initState();
    _bars = _computeBars();
    widget.videoController?.addListener(_onVideoUpdate);
  }

  @override
  void didUpdateWidget(AudioWaveformBar oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.videoController != widget.videoController) {
      oldWidget.videoController?.removeListener(_onVideoUpdate);
      widget.videoController?.addListener(_onVideoUpdate);
    }
    if (oldWidget.waveformData != widget.waveformData) {
      _bars = _computeBars();
    }
  }

  @override
  void dispose() {
    widget.videoController?.removeListener(_onVideoUpdate);
    super.dispose();
  }

  void _onVideoUpdate() {
    if (mounted) setState(() {});
  }

  /// waveformData를 barCount 개수로 다운샘플링.
  /// 데이터가 없으면 빈 리스트를 반환 (더미 파형 없음).
  List<double> _computeBars() {
    final raw = widget.waveformData;
    if (raw == null || raw.isEmpty) return [];

    // 다운샘플링: 균등 구간 최댓값
    final count = widget.barCount;
    final result = <double>[];
    final step = raw.length / count;
    for (int i = 0; i < count; i++) {
      final start = (i * step).floor();
      final end = ((i + 1) * step).ceil().clamp(0, raw.length);
      double peak = 0;
      for (int j = start; j < end; j++) {
        final v = raw[j].abs();
        if (v > peak) peak = v;
      }
      result.add(peak.clamp(0.04, 1.0));
    }
    // 0~1 정규화
    final maxVal = result.reduce(math.max);
    if (maxVal > 0) {
      for (int i = 0; i < result.length; i++) {
        result[i] = result[i] / maxVal;
      }
    }
    return result;
  }

  double get _progress {
    final c = widget.videoController;
    if (c == null || !c.value.isInitialized) return 0.0;
    final dur = c.value.duration.inMilliseconds;
    if (dur == 0) return 0.0;
    return (c.value.position.inMilliseconds / dur).clamp(0.0, 1.0);
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    // 데이터 없고 로딩 중도 아니면 공간 차지 없이 숨김
    if (!widget.isLoading && _bars.isEmpty) {
      return const SizedBox.shrink();
    }

    // 로딩 중 - 스켈레톤 표시
    if (widget.isLoading) {
      return _LoadingSkeleton(height: widget.height, cs: cs);
    }

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
            final barWidth = (totalWidth / _bars.length) * 0.55;
            final gap = (totalWidth / _bars.length) * 0.45;
            final progressIndex = (progress * _bars.length).floor();

            return Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: List.generate(_bars.length, (i) {
                final isPlayed = i < progressIndex;
                final isCurrent = i == progressIndex;
                final barH = (_bars[i] * widget.height * 0.85)
                    .clamp(3.0, widget.height);

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
                    height: barH,
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
    final c = widget.videoController;
    if (c == null || !c.value.isInitialized) return;
    final box = context.findRenderObject() as RenderBox?;
    if (box == null) return;
    final ratio = (localX / box.size.width).clamp(0.0, 1.0);
    c.seekTo(c.value.duration * ratio);
  }
}

/// 로딩 중 표시할 스켈레톤 파형.
class _LoadingSkeleton extends StatefulWidget {
  const _LoadingSkeleton({required this.height, required this.cs});
  final double height;
  final ColorScheme cs;

  @override
  State<_LoadingSkeleton> createState() => _LoadingSkeletonState();
}

class _LoadingSkeletonState extends State<_LoadingSkeleton>
    with SingleTickerProviderStateMixin {
  late final AnimationController _anim;

  @override
  void initState() {
    super.initState();
    _anim = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _anim.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final rng = math.Random(7);
    return SizedBox(
      height: widget.height,
      child: AnimatedBuilder(
        animation: _anim,
        builder: (context, _) {
          return Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: List.generate(40, (i) {
              final h = (rng.nextDouble() * 0.7 + 0.1) * widget.height;
              final alpha = 0.08 + _anim.value * 0.10;
              return Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 1.5),
                  child: Container(
                    height: h,
                    decoration: BoxDecoration(
                      color:
                          widget.cs.onSurface.withValues(alpha: alpha),
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
              );
            }),
          );
        },
      ),
    );
  }
}
