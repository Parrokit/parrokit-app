import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';

/// 오디오 파형 그래프 위젯.
///
/// [waveformData]가 null이면 로딩 상태를 표시한다.
/// [waveformData]가 비어있으면 데이터 없음으로 취급하여 숨긴다.
/// 줌 레벨([zoomFactor])에 따라 보여지는 파형 구간(window)이 달라지며,
/// 비디오 재생 시 자동 스크롤을 지원한다.
class AudioWaveformBar extends StatefulWidget {
  const AudioWaveformBar({
    super.key,
    required this.videoController,
    this.waveformData,
    this.isLoading = false,
    this.zoomFactor = 1.0,
    this.barCount = 100,
    this.height = 48,
  });

  /// 재생 위치 동기화에 사용하는 비디오 컨트롤러.
  final VideoPlayerController? videoController;

  /// 실제 오디오 파형 데이터 (고해상도, 0.0 ~ 1.0 정규화 완료)
  final List<double>? waveformData;

  final bool isLoading;
  
  /// 줌 배율 (1.0 = 전체 표시, 값이 클수록 확대됨, 최소 표시 10초)
  final double zoomFactor;
  
  final int barCount;
  final double height;

  @override
  State<AudioWaveformBar> createState() => _AudioWaveformBarState();
}

class _AudioWaveformBarState extends State<AudioWaveformBar> {
  late List<double> _bars;
  int _windowStartMs = 0;

  List<double>? _cachedFullBars;
  double _cachedZoomFactor = -1;

  @override
  void initState() {
    super.initState();
    _bars = _computeBars();
    widget.videoController?.addListener(_onVideoUpdate);
  }

  @override
  void didUpdateWidget(AudioWaveformBar oldWidget) {
    super.didUpdateWidget(oldWidget);
    
    if (oldWidget.zoomFactor != widget.zoomFactor) {
      _updateWindowForZoom();
    }
    
    if (oldWidget.videoController != widget.videoController) {
      oldWidget.videoController?.removeListener(_onVideoUpdate);
      widget.videoController?.addListener(_onVideoUpdate);
    }
    
    if (oldWidget.waveformData != widget.waveformData) {
      _cachedFullBars = null; // reset cache
      _bars = _computeBars();
    } else if (oldWidget.zoomFactor != widget.zoomFactor) {
      _bars = _computeBars();
    }
  }

  @override
  void dispose() {
    widget.videoController?.removeListener(_onVideoUpdate);
    super.dispose();
  }

  void _onVideoUpdate() {
    final c = widget.videoController;
    if (c != null && c.value.isInitialized && mounted) {
      final posMs = c.value.position.inMilliseconds;
      final durMs = c.value.duration.inMilliseconds;
      final minDur = math.min(3000.0, durMs.toDouble());
      final windowDurMs = (durMs / widget.zoomFactor).clamp(minDur, durMs.toDouble()).toInt();
      
      final oldStart = _windowStartMs;
      
      // 실시간 부드러운 스크롤 (Center-locked):
      // 재생 위치를 항상 화면 중앙에 두도록 윈도우를 지속적으로 이동
      _windowStartMs = posMs - (windowDurMs ~/ 2);
      
      // 창 위치가 변했거나 재생 중이면 UI 업데이트
      if (oldStart != _windowStartMs || c.value.isPlaying) {
        _bars = _computeBars();
        setState(() {});
      }
    }
  }

  void _updateWindowForZoom() {
    final c = widget.videoController;
    if (c == null || !c.value.isInitialized) return;
    final posMs = c.value.position.inMilliseconds;
    final durMs = c.value.duration.inMilliseconds;
    final minDur = math.min(3000.0, durMs.toDouble());
    final windowDurMs = (durMs / widget.zoomFactor).clamp(minDur, durMs.toDouble()).toInt();
    
    // 현재 재생 위치를 화면 중앙에 맞추도록 윈도우 이동
    _windowStartMs = posMs - (windowDurMs ~/ 2);
  }

  void _updateCacheIfNeeded() {
    if (_cachedFullBars != null && _cachedZoomFactor == widget.zoomFactor) {
      return;
    }

    final raw = widget.waveformData;
    if (raw == null || raw.isEmpty) {
      _cachedFullBars = [];
      _cachedZoomFactor = widget.zoomFactor;
      return;
    }

    final c = widget.videoController;
    if (c == null || !c.value.isInitialized) {
      _cachedFullBars = _downsampleFull(raw, widget.barCount);
      _cachedZoomFactor = widget.zoomFactor;
      return;
    }

    final durMs = c.value.duration.inMilliseconds;
    if (durMs <= 0) {
      _cachedFullBars = [];
      _cachedZoomFactor = widget.zoomFactor;
      return;
    }

    final minDur = math.min(3000.0, durMs.toDouble());
    final windowDurMs = (durMs / widget.zoomFactor).clamp(minDur, durMs.toDouble()).toInt();
    final actualWindowDurMs = math.min(windowDurMs, durMs);

    final totalBars = ((durMs / actualWindowDurMs) * widget.barCount).ceil();
    _cachedFullBars = _downsampleFull(raw, totalBars);
    _cachedZoomFactor = widget.zoomFactor;
  }

  List<double> _downsampleFull(List<double> raw, int count) {
    if (count <= 0) return [];
    if (raw.isEmpty) return List.filled(count, 0.0);
    
    final result = <double>[];
    final step = raw.length / count;
    for (int i = 0; i < count; i++) {
      final s = (i * step).floor();
      final e = ((i + 1) * step).ceil();
      final actualE = math.min(e, raw.length);
      
      double peak = 0;
      for (int j = s; j < actualE; j++) {
        if (j >= 0 && j < raw.length) {
          if (raw[j] > peak) peak = raw[j];
        }
      }
      result.add(peak.clamp(0.04, 1.0));
    }
    
    // 전체 범위에서 이미 정규화되어 있으므로, 구간별 재정규화 생략
    return result;
  }

  List<double> _computeBars() {
    _updateCacheIfNeeded();
    return _cachedFullBars ?? [];
  }

  String _formatDuration(int ms) {
    final d = Duration(milliseconds: ms);
    final mm = d.inMinutes.toString().padLeft(2, '0');
    final ss = (d.inSeconds % 60).toString().padLeft(2, '0');
    final deci = ((d.inMilliseconds % 1000) ~/ 100).toString();
    return '$mm:$ss.$deci';
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

    final c = widget.videoController;
    int actualWindowDurMs = 0;
    double exactIndex = 0.0;
    int startIndex = 0;
    double fraction = 0.0;

    if (c != null && c.value.isInitialized) {
      final durMs = c.value.duration.inMilliseconds;
      final minDur = math.min(3000.0, durMs.toDouble());
      final windowDurMs =
          (durMs / widget.zoomFactor).clamp(minDur, durMs.toDouble()).toInt();
      actualWindowDurMs = math.min(windowDurMs, durMs);

      if (durMs > 0 && _bars.isNotEmpty) {
        final startRatio = _windowStartMs / durMs;
        exactIndex = startRatio * _bars.length;
        startIndex = exactIndex.floor();
        fraction = exactIndex - startIndex;
      }
    }
    final int endMs = _windowStartMs + actualWindowDurMs;

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        SizedBox(
          height: widget.height,
          child: GestureDetector(
            onHorizontalDragUpdate: (details) =>
                _handleDrag(context, details),
            behavior: HitTestBehavior.opaque,
            child: ClipRect(
              child: LayoutBuilder(
                builder: (context, constraints) {
                  final totalWidth = constraints.maxWidth;
                  final itemWidth = totalWidth / widget.barCount;
                  final barWidth = itemWidth * 0.35;
                  final gap = itemWidth * 0.65;

                  return OverflowBox(
                    maxWidth: double.infinity,
                    alignment: Alignment.centerLeft,
                    child: Transform.translate(
                      offset: Offset(-fraction * itemWidth, 0),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: List.generate(widget.barCount + 2, (i) {
                          final idx = startIndex + i;
                          final barHeightRatio = (idx >= 0 && idx < _bars.length)
                              ? _bars[idx]
                              : 0.04;
                          final barH = (barHeightRatio * widget.height * 0.85)
                              .clamp(3.0, widget.height);
  
                          final playheadIdx = (exactIndex + widget.barCount / 2).floor();
                          final isPlayed = idx < playheadIdx;
                          final isCurrent = idx == playheadIdx;
  
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
                            child: Container(
                              width: barWidth,
                              height: barH,
                              decoration: BoxDecoration(
                                color: barColor,
                                borderRadius: BorderRadius.circular(barWidth / 2),
                              ),
                            ),
                          );
                        }),
                      ),
                    ),
                  );
                },
              ),
            ),
          ),
        ),
        if (actualWindowDurMs > 0) ...[
          const SizedBox(height: 2),
          Stack(
            alignment: Alignment.center,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    _formatDuration(math.max(0, _windowStartMs)),
                    style: TextStyle(
                      fontSize: 10,
                      color: cs.onSurface.withValues(alpha: 0.4),
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  Text(
                    _formatDuration(math.min(c?.value.duration.inMilliseconds ?? endMs, endMs)),
                    style: TextStyle(
                      fontSize: 10,
                      color: cs.onSurface.withValues(alpha: 0.4),
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
              Text(
                _formatDuration(c?.value.position.inMilliseconds ?? 0),
                style: TextStyle(
                  fontSize: 11,
                  color: cs.primary,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ],
      ],
    );
  }

  void _handleDrag(BuildContext context, DragUpdateDetails details) {
    final c = widget.videoController;
    if (c == null || !c.value.isInitialized) return;
    final box = context.findRenderObject() as RenderBox?;
    if (box == null) return;
    
    final durMs = c.value.duration.inMilliseconds;
    final minDur = math.min(3000.0, durMs.toDouble());
    final windowDurMs = (durMs / widget.zoomFactor).clamp(minDur, durMs.toDouble()).toInt();
    final actualWindowDurMs = math.min(windowDurMs, durMs);
    
    final msPerPixel = actualWindowDurMs / box.size.width;
    // 왼쪽으로 드래그(음수 delta)하면 시간이 미래로 가야 하므로 -를 붙임
    final deltaMs = -details.delta.dx * msPerPixel;
    
    final currentMs = c.value.position.inMilliseconds;
    final targetMs = (currentMs + deltaMs).clamp(0, durMs.toDouble()).toInt();
    
    c.seekTo(Duration(milliseconds: targetMs));
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
                      color: widget.cs.onSurface.withValues(alpha: alpha),
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
