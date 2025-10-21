import 'dart:io' show File;
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';

import 'package:parrokit/data/local/pa_database.dart'; // Segment 타입 사용
import 'package:parrokit/mvp/shorts/widgets/video_layer_placeholder.dart';

enum FitMode { cover, contain }

class ShortsPage extends StatefulWidget {
  const ShortsPage({
    super.key,
    required this.filePath, // 절대 경로(Provider에서 보정해 전달)
    required this.durationMs, // 길이 (ms)
    required this.segments, // 자막 리스트 (Segments 테이블)
    required this.onEnded, // 끝났을 때 콜백 (자동넘김 등)
    required this.autoNextEnabled,
    required this.isActive, // 현재 화면에 보이는 페이지 여부
    required this.pauseSignal,
    required this.showSubtilte,
    this.fitMode = FitMode.contain,
  });

  final bool autoNextEnabled;
  final String filePath;
  final int durationMs;
  final List<Segment> segments;
  final bool isActive;
  final VoidCallback onEnded;
  final FitMode fitMode;
  final ValueListenable<bool> pauseSignal;
  final bool showSubtilte;

  @override
  State<ShortsPage> createState() => _ShortsPageState();
}

class _ShortsPageState extends State<ShortsPage>
    with AutomaticKeepAliveClientMixin {
  VideoPlayerController? _controller;
  bool _init = false;
  String? _error;
  bool _active = true;

  /// 동시에 여러 초기화가 겹칠 때를 막는 토큰 (세대 구분)
  int _loadGen = 0;
  bool _isDragging = false;
  double? _dragProgress; // 0.0 ~ 1.0 (드래그 중 임시 표시)
  bool _wasPlayingBeforeDrag = false;

  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();
    _active = widget.isActive;
    widget.pauseSignal.addListener(_onPauseSignalChanged);

    if (_active) {
      _initVideo();
    }
  }

  void _onPauseSignalChanged() {
    final paused = widget.pauseSignal.value;
    if (paused) {
      // 외부로 나갈 때: 즉시 해제
      setActive(false);
    } else {
      // 복귀했을 때: 내가 활성 페이지면 다시 초기화/재생
      if (widget.isActive && (_controller == null || !_init)) {
        setActive(true); // 내부에서 _initVideo 호출
      }
    }
  }

  /// 현재 보이는지/아닌지에 따라 재생/해제 정책
  Future<void> setActive(bool v) async {
    if (_active == v) return;
    _active = v;

    if (!_active) {
      // 보이지 않으면 완전 해제 (한 번에 하나만 살아 있도록)
      final c = _controller;
      _controller = null;
      _init = false;
      _loadGen++; // 이후 콜백 무효화
      await c?.pause();
      await c?.dispose();
      if (mounted) setState(() {});
      return;
    } else {
      // 다시 보이면 재초기화
      await _initVideo();
    }
  }

  @override
  void didUpdateWidget(covariant ShortsPage oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.isActive != widget.isActive) {
      setActive(widget.isActive);
    }
    if (oldWidget.pauseSignal != widget.pauseSignal) {
      oldWidget.pauseSignal.removeListener(_onPauseSignalChanged);
      widget.pauseSignal.addListener(_onPauseSignalChanged);
    }
    // autoNext 토글 시 루프 설정 즉시 반영
    if (oldWidget.autoNextEnabled != widget.autoNextEnabled && _controller != null) {
      _controller!.setLooping(!widget.autoNextEnabled);
    }
  }

  Future<void> _initVideo() async {
    final myGen = ++_loadGen;
    try {
      final c = VideoPlayerController.file(File(widget.filePath));
      await c.initialize();

      if (myGen != _loadGen) {
        await c.dispose();
        return;
      }

      await c.setLooping(!widget.autoNextEnabled);
      if (_active) await c.play();

      c.addListener(() {
        if (!mounted) return;
        final v = c.value;

        // ✅ 드래그 중에는 onEnded 방지
        if (_active && widget.autoNextEnabled && !_isDragging) {
          final pos = v.position.inMilliseconds;
          final dur = v.duration.inMilliseconds;
          if (dur > 0 && pos >= dur - 300) {
            widget.onEnded();
          }
        }
        setState(() {});
      });

      if (!mounted || myGen != _loadGen) {
        await c.dispose();
        return;
      }

      setState(() {
        _controller = c;
        _init = true;
        _error = null;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() => _error = '영상을 준비하지 못했어요.');
    }
  }

  @override
  void dispose() {
    widget.pauseSignal.removeListener(_onPauseSignalChanged);
    _loadGen++;
    _controller?.dispose();
    super.dispose();
  }

  void _togglePlay() {
    final c = _controller;
    if (c == null) return;
    c.value.isPlaying ? c.pause() : c.play();
    setState(() {});
  }

  Future<void> _seekToFraction(double f) async {
    final c = _controller;
    if (c == null) return;
    final dur = c.value.duration.inMilliseconds > 0
        ? c.value.duration
        : Duration(milliseconds: widget.durationMs);
    final targetMs = (dur.inMilliseconds * f).clamp(0, dur.inMilliseconds);
    await c.seekTo(Duration(milliseconds: targetMs.round()));
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);

    final c = _controller;
    final pos = c?.value.position ?? Duration.zero;
    final dur = c?.value.duration ?? Duration(milliseconds: widget.durationMs);

    // ✅ 드래그 중이면 드래그 값 우선
    final double liveProgress = dur.inMilliseconds == 0
        ? 0.0
        : (pos.inMilliseconds / dur.inMilliseconds).clamp(0.0, 1.0);
    final double uiProgress = _isDragging && _dragProgress != null
        ? _dragProgress!.clamp(0.0, 1.0)
        : liveProgress;

    Widget videoLayer() {
      if (_error != null) {
        return Center(
          child: Text(_error!, style: const TextStyle(color: Colors.white)),
        );
      }
      if (!_init || c == null) return const VideoLayerPlaceholder();

      final aspect = c.value.aspectRatio == 0 ? 16 / 9 : c.value.aspectRatio;

      if (widget.fitMode == FitMode.cover) {
        return FittedBox(
          fit: BoxFit.cover,
          child: SizedBox(
            width: c.value.size.width,
            height: c.value.size.height,
            child: VideoPlayer(c),
          ),
        );
      } else {
        // contain: 레터박스 처리
        return Container(
          color: Colors.black,
          alignment: Alignment.center,
          child: AspectRatio(
            aspectRatio: aspect,
            child: VideoPlayer(c),
          ),
        );
      }
    }

    final progress = dur.inMilliseconds == 0
        ? 0.0
        : (pos.inMilliseconds / dur.inMilliseconds).clamp(0.0, 1.0);

    final currentSeg =
        c != null ? segmentForPosition(widget.segments, pos) : null;

    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: _togglePlay,
      child: Stack(
        fit: StackFit.expand,
        children: [
          // --- Video ---
          videoLayer(),

          // --- Subtitles (jp / pron / trans) ---
          if (currentSeg != null)
            Positioned(
              left: 16,
              right: 16,
              bottom: 90,
              child: IgnorePointer(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    // 일본어 원문
                    if (widget.showSubtilte && currentSeg != null)
                      Text(
                        currentSeg.original,
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.w800,
                          height: 1.25,
                          shadows: [
                            Shadow(
                              blurRadius: 3,
                              color: Colors.black54,
                              offset: Offset(0, 1),
                            ),
                          ],
                        ),
                      ),
                    // 발음(옵션)
                    if (widget.showSubtilte && currentSeg != null)
                      if (currentSeg.pron != null &&
                          currentSeg.pron!.isNotEmpty)
                        Padding(
                          padding: const EdgeInsets.only(top: 6),
                          child: Text(
                            currentSeg.pron!,
                            textAlign: TextAlign.center,
                            style: const TextStyle(
                              color: Colors.white70,
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              height: 1.25,
                              shadows: [
                                Shadow(
                                  blurRadius: 3,
                                  color: Colors.black54,
                                  offset: Offset(0, 1),
                                ),
                              ],
                            ),
                          ),
                        ),
                    // 번역(옵션)
                    if (widget.showSubtilte && currentSeg != null)
                      if (currentSeg.trans != null &&
                          currentSeg.trans!.isNotEmpty)
                        Padding(
                          padding: const EdgeInsets.only(top: 6),
                          child: Text(
                            currentSeg.trans!,
                            textAlign: TextAlign.center,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 15,
                              fontWeight: FontWeight.w600,
                              height: 1.25,
                              shadows: [
                                Shadow(
                                  blurRadius: 3,
                                  color: Colors.black54,
                                  offset: Offset(0, 1),
                                ),
                              ],
                            ),
                          ),
                        ),
                  ],
                ),
              ),
            ),

          // --- Center Play 버튼 ---
          if (c != null && !c.value.isPlaying)
            Center(
              child: InkWell(
                customBorder: const CircleBorder(),
                onTap: _togglePlay,
                child: Container(
                  width: 64,
                  height: 64,
                  decoration: const BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.white,
                  ),
                  child: const Icon(
                    Icons.play_arrow_rounded,
                    size: 36,
                    color: Colors.black,
                  ),
                ),
              ),
            ),

          // --- Progress Indicator ---
          // (Stack 안) Progress 영역
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: GestureDetector(
              behavior: HitTestBehavior.opaque, // ✅ 이 영역을 넓은 히트박스로 사용
              onTap: () {}, // 부모 onTap(재생/일시정지) 차단
              child: Padding(
                padding: const EdgeInsets.fromLTRB(8, 8, 8, 8), // 바닥과 간섭 줄이기
                child: SizedBox(
                  height: 48, // ✅ 히트 영역을 넓힘(추천: 40~56)
                  child: Center( // 보기는 얇게
                    child: SliderTheme(
                      data: SliderTheme.of(context).copyWith(
                        trackHeight: 3,                           // 얇은 트랙
                        activeTrackColor: Colors.white,
                        inactiveTrackColor: Colors.white.withOpacity(0.3),
                        thumbShape: SliderComponentShape.noThumb, // ✅ 점 제거
                        overlayShape: SliderComponentShape.noOverlay,
                      ),
                      child: Slider(
                        value: uiProgress.isNaN ? 0.0 : uiProgress,
                        onChangeStart: (_) {
                          final c = _controller;
                          if (c == null) return;
                          _wasPlayingBeforeDrag = c.value.isPlaying;
                          c.pause();
                          setState(() { _isDragging = true; });
                        },
                        onChanged: (v) {
                          setState(() { _dragProgress = v; });
                        },
                        onChangeEnd: (v) async {
                          await _seekToFraction(v);
                          setState(() {
                            _isDragging = false;
                            _dragProgress = null;
                          });
                          final c = _controller;
                          if (c != null && _wasPlayingBeforeDrag && _active) {
                            c.play();
                          }
                        },
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// 현재 재생 위치에 해당하는 Segment 반환
Segment? segmentForPosition(List<Segment> segs, Duration pos) {
  for (final s in segs) {
    final start = Duration(milliseconds: s.startMs);
    final end = Duration(milliseconds: s.endMs);
    if (pos >= start && pos < end) return s;
  }
  return null;
}
