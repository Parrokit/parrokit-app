// lib/mvp/player/clip_player_screen.dart
import 'dart:io' show File;
import 'package:audio_service/audio_service.dart';
import 'package:flutter/material.dart';
import 'package:parrokit/config/pa_config.dart';
import 'package:parrokit/provider/dashboard_ui_provider.dart';
import 'package:path_provider/path_provider.dart';
import 'package:provider/provider.dart';
import 'package:video_player/video_player.dart';
import 'package:parrokit/provider/media_provider.dart';
import 'package:parrokit/data/local/pa_database.dart'; // Clip, Segment
import 'index.dart';
import 'package:parrokit/utils/audio_bg.dart';

/// --- Tone / Scope -----------------------------------------------------------

enum PlayerTone { light, dark }

enum PlayScope { segment, full }

/// --- Screen -----------------------------------------------------------------

class ClipPlayerScreen extends StatefulWidget {
  const ClipPlayerScreen({
    super.key,
    required this.clipId,
    this.initialIndex = 0,
    this.loopSegment = true,
    this.showSubtitles = true,
    this.tone = PlayerTone.light,
  });

  final int clipId;
  final int initialIndex;
  final bool loopSegment;
  final bool showSubtitles;
  final PlayerTone tone;

  @override
  State<ClipPlayerScreen> createState() => _ClipPlayerScreenState();
}

class _ClipPlayerScreenState extends State<ClipPlayerScreen> with WidgetsBindingObserver{
  PlayScope _scope = PlayScope.segment;
  late VideoPlayerController _controller;

  bool _initialized = false;
  bool _loading = true;

  late int _segIndex;
  bool _loopSeg = true;
  bool _showSubs = true;
  double _rate = 1.0;
  bool _isHandingOff = false;
  bool _isTakingBack = false;
  // ✅ Drift rows 그대로 사용
  Clip? _clip;
  List<Segment> _segments = const [];
  String _appBarTitle = '재생';

  Segment get _seg => _segments[_segIndex];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);

    _segIndex = widget.initialIndex;
    _scope = PaConfig.segmentLoop ? PlayScope.full : PlayScope.segment;
    _loopSeg = PaConfig.repeatAll;
    _showSubs = PaConfig.showSubtitles;
    _rate = PaConfig.defaultPlaybackRate;

    WidgetsBinding.instance.addPostFrameCallback((_) => _loadFromDb());

    Future.microtask(() {
      context.read<DashboardUiProvider>().logRecent(widget.clipId);
    });
  }

// 로딩부: clipId로만 로드
  Future<void> _loadFromDb() async {
    final media = context.read<MediaProvider>();
    final payload = await media.fetchClipById(widget.clipId);
    if (!mounted) return;

    if (payload == null) {
      setState(() {
        _loading = false;
        _clip = null;
        _segments = const [];
      });
      return;
    }

    _clip = payload.clip;
    _segments = payload.segments;

    await _initVideo();
    if (!mounted) return;
    setState(() {
      _loading = false;
      _initialized = true;
      _appBarTitle = _clip?.title?.isNotEmpty == true ? _clip!.title! : '재생';
    });
  }

  Future<void> _onUserSeek(Duration d) async {
    if (!_initialized || _segments.isEmpty) return;

    final total = _controller.value.duration;
    Duration clamp(Duration x, Duration lo, Duration hi) =>
        x < lo ? lo : (x > hi ? hi : x);

    Duration target;
    if (_scope == PlayScope.segment) {
      final newIdx = _indexForPosition(d);
      if (newIdx != null && newIdx != _segIndex) {
        setState(() => _segIndex = newIdx);
      }
      final st = Duration(milliseconds: _seg.startMs);
      final en = Duration(milliseconds: _seg.endMs);
      target = clamp(d, st, en);
    } else {
      target = clamp(d, Duration.zero, total);
    }

    await _controller.seekTo(target);
    if (mounted) setState(() {});
    final h = await ensureAudioHandler();
    await h.seek(target);
  }

  Future<void> _initVideo() async {
    if (_clip == null) return;
    final src = _clip!.filePath;

    final isNetwork = src.startsWith('http://') || src.startsWith('https://');

    String resolvedPath = src;
    if (!isNetwork && !src.startsWith('/')) {
      final docs = await getApplicationDocumentsDirectory();
      resolvedPath = '${docs.path}/$src';
    }

    _controller = isNetwork
        ? VideoPlayerController.networkUrl(Uri.parse(src))
        : VideoPlayerController.file(File(resolvedPath));

    await _controller.initialize();
    await _controller.setLooping(false);
    await _controller.setPlaybackSpeed(_rate);

    if (_segments.isNotEmpty) {
      _segIndex = _segIndex.clamp(0, _segments.length - 1);
      await _controller.seekTo(Duration(milliseconds: _seg.startMs));
    }
    _controller.addListener(_onTick);
  }

  int? _indexForPosition(Duration pos) {
    for (int i = 0; i < _segments.length; i++) {
      final s = _segments[i];
      final start = Duration(milliseconds: s.startMs);
      final end = Duration(milliseconds: s.endMs);
      if (pos >= start && pos < end) return i;
    }
    return null;
  }

  void _onTick() {
    if (!_controller.value.isInitialized || _segments.isEmpty) return;
    final pos = _controller.value.position;

    final start = Duration(milliseconds: _seg.startMs);
    final end = Duration(milliseconds: _seg.endMs);

    if (_scope == PlayScope.segment) {
      if (pos >= end) {
        if (_loopSeg) {
          _controller.seekTo(start);
          _controller.play();
        } else {
          _controller.pause();
          _controller.seekTo(end);
        }
      }
      if (pos < start && _controller.value.isPlaying) {
        _controller.seekTo(start);
      }
    } else {
      // 전체 재생 모드: 자막 인덱스만 따라감. 되감기/루프는 컨트롤러 looping 에 맡김.
      final idx = _indexForPosition(pos);
      if (idx != null && idx != _segIndex) {
        _segIndex = idx;
      }
      // 👇 삭제: 전체재생에서 세그먼트 되감기 금지
      // if (_loopSeg && pos >= end) { ... }
    }

    if (mounted) setState(() {});
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) async {
    if (!_initialized || _clip == null || _segments.isEmpty) return;

    if (state == AppLifecycleState.paused || state == AppLifecycleState.inactive) {
      // ⬇️ 백그라운드 전환: 비디오 → 오디오
      await _handoffToBackgroundAudio();
    } else if (state == AppLifecycleState.resumed) {
      // ⬇️ 포그라운드 복귀: 오디오 → 비디오
      await _takeBackFromBackgroundAudio();
    }
  }
  Future<void> _handoffToBackgroundAudio() async {
    if (_isHandingOff) return;
    _isHandingOff = true;
    try {
      if (!_controller.value.isInitialized) return;

      // 1) 비디오 먼저 정지(팝 소리 예방하고 싶으면 볼륨 0 → pause)
      // await _controller.setVolume(0.0); // 선택
      await _controller.pause();

      // 2) 소스/포지션 준비
      final src = await _resolvedSourcePath();
      if (src.isEmpty || !src.startsWith('/')) return;
      final pos = _controller.value.position;

      final clipBegin = _scope == PlayScope.segment
          ? Duration(milliseconds: _seg.startMs)
          : null;
      final clipEnd = _scope == PlayScope.segment
          ? Duration(milliseconds: _seg.endMs)
          : null;

      // 3) 백그라운드 오디오 설정 및 재생
      final h = await ensureAudioHandler();
      await (h as dynamic).loadSourceLocal(
        absolutePath: src,
        speed: _rate,
        clipBegin: clipBegin,
        clipEnd: clipEnd,
        loop: _loopSeg,
      );
      await h.seek(pos);
      await h.play();
    } finally {
      _isHandingOff = false;
    }
  }

  Future<void> _takeBackFromBackgroundAudio() async {
    if (_isTakingBack) return;
    _isTakingBack = true;
    try {
      final h = await ensureAudioHandler();

      // 1) 백그라운드 오디오 먼저 정지
      final isPlaying = (h as dynamic).playing as bool? ?? false;
      final bgPos = (h as dynamic).position as Duration? ?? Duration.zero;
      if (isPlaying) {
        await h.pause();
      }

      // 2) 비디오에 위치 반영
      final pos = bgPos;
      if (_scope == PlayScope.segment) {
        final st = Duration(milliseconds: _seg.startMs);
        final en = Duration(milliseconds: _seg.endMs);
        final clamped = pos < st ? st : (pos >= en ? st : pos);
        await _controller.seekTo(clamped);
      } else {
        await _controller.seekTo(pos);
      }

      // 3) 속도/볼륨/재생 재개
      await _controller.setPlaybackSpeed(_rate);
      if (mounted && _controller.value.isInitialized) {
        // await _controller.setVolume(1.0); // 선택(위에서 0으로 내렸다면)
        await _controller.play();
      }
    } finally {
      _isTakingBack = false;
    }
  }

  Future<String> _resolvedSourcePath() async {
    final src = _clip!.filePath;
    final isNetwork = src.startsWith('http://') || src.startsWith('https://');
    if (isNetwork) return src;
    if (src.startsWith('/')) return src;
    final docs = await getApplicationDocumentsDirectory();
    return '${docs.path}/$src';
  }
  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    if (_initialized) {
      _controller.removeListener(_onTick);
      _controller.dispose();
    }
    super.dispose();
  }

  Future<void> _playPause() async {
    if (!_initialized || _segments.isEmpty) return;
    if (_controller.value.isPlaying) {
      await _controller.pause();
    } else {
      if (_scope == PlayScope.segment) {
        final pos = _controller.value.position;
        final st = Duration(milliseconds: _seg.startMs);
        final en = Duration(milliseconds: _seg.endMs);
        if (pos < st || pos >= en) {
          await _controller.seekTo(st);
        }
      }
      await _controller.play();
    }
    if (mounted) setState(() {});
  }

  Future<void> _prevSeg() async =>
      _jumpToSegment((_segIndex - 1).clamp(0, _segments.length - 1));

  Future<void> _nextSeg() async =>
      _jumpToSegment((_segIndex + 1).clamp(0, _segments.length - 1));

  Future<void> _jumpToSegment(int index, {bool autoplay = false}) async {
    if (_segments.isEmpty) return;
    if (index == _segIndex) {
      await _controller.seekTo(Duration(milliseconds: _seg.startMs));
    } else {
      _segIndex = index;
      await _controller
          .seekTo(Duration(milliseconds: _segments[_segIndex].startMs));
    }
    if (autoplay || _controller.value.isPlaying) {
      await _controller.play();
    } else {
      await _controller.pause();
    }
    if (mounted) setState(() {});
  }

  Future<void> _toggleLoop() async {
    setState(() => _loopSeg = !_loopSeg);

    await _controller.setLooping(_scope == PlayScope.full && _loopSeg);

    // 🔊 백그라운드 오디오에도 동기화
    await (audioHandler as dynamic).setLoop(_loopSeg);
    if (_scope == PlayScope.segment) {
      await (audioHandler as dynamic).setClip(
        start: Duration(milliseconds: _seg.startMs), // ← begin 아님
        end: Duration(milliseconds: _seg.endMs),
      );
    } else {
      await (audioHandler as dynamic).setClip(); // 전체로 복원
    }
  }

  Future<void> _toggleSubs() async => setState(() => _showSubs = !_showSubs);

  Future<void> _setRate(double r) async {
    _rate = r;
    await _controller.setPlaybackSpeed(r);

    // 🔑 오디오 핸들러에도 속도 적용
    if (audioHandler != null) {
      await (audioHandler as dynamic).setSpeed(r);
    }

    if (mounted) setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context);
    final cs = t.colorScheme;
    final isLight = widget.tone == PlayerTone.light;

    final bg = isLight ? cs.surface : Colors.black;
    final fg = isLight ? cs.onSurface : Colors.white;

    if (_loading) {
      return Scaffold(
        backgroundColor: bg,
        appBar: AppBar(
          backgroundColor: bg,
          surfaceTintColor: Colors.transparent,
          elevation: 0,
          foregroundColor: fg,
          title: const Text('재생'),
        ),
        body: Center(
            child: CircularProgressIndicator(
                color: isLight ? cs.primary : Colors.white)),
      );
    }
    if (_clip == null || _segments.isEmpty) {
      return Scaffold(
        backgroundColor: bg,
        appBar: AppBar(
          backgroundColor: bg,
          surfaceTintColor: Colors.transparent,
          elevation: 0,
          foregroundColor: fg,
          title: const Text('재생'),
        ),
        body: const Center(child: Text('클립을 찾을 수 없습니다.')),
      );
    }

    return Scaffold(
      backgroundColor: bg,
      appBar: AppBar(
        backgroundColor: bg,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        foregroundColor: fg,
        title: Text(_appBarTitle),
      ),
      body: _initialized
          ? Column(
              children: [
                // --- Video + Subs ---
                AspectRatio(
                  aspectRatio: _controller.value.aspectRatio == 0
                      ? 16 / 9
                      : _controller.value.aspectRatio,
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      // ⬇️ 탭하면 재생 중일 때만 pause
                      Positioned.fill(
                        child: GestureDetector(
                          behavior: HitTestBehavior.opaque, // 빈 곳도 탭 인식
                          onTap: () {
                            if (_controller.value.isPlaying) {
                              _playPause(); // -> pause
                            }
                          },
                          child: VideoPlayer(_controller),
                        ),
                      ),

                      if (_showSubs)
                        PlainSubtitleOverlay(
                          ja: _seg.original,
                          pron: _seg.pron,
                          ko: _seg.trans,
                        ),

                      if (!_controller.value.isPlaying)
                        Center(
                          child: CircleIconButton(
                            icon: Icons.play_arrow_rounded,
                            onTap: _playPause,
                            isLight: isLight,
                            size: 64,
                          ),
                        ),
                    ],
                  ),
                ),

                // --- Timeline ---
                SegmentTimeline(
                  controller: _controller,
                  start: Duration(milliseconds: _seg.startMs),
                  end: Duration(milliseconds: _seg.endMs),
                  onSeek: _onUserSeek,
                ),

                const SizedBox(height: 8),

                // --- Controls ---
                Padding(
                  padding: const EdgeInsets.fromLTRB(12, 8, 12, 4),
                  child: Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    crossAxisAlignment: WrapCrossAlignment.center,
                    alignment: WrapAlignment.center,
                    children: [
                      Row(mainAxisSize: MainAxisSize.min, children: [
                        CircleIconButton(
                          icon: Icons.skip_previous_rounded,
                          onTap: _prevSeg,
                          tooltip: '이전 구간',
                          isLight: isLight,
                        ),
                        const SizedBox(width: 8),
                        CircleIconButton(
                          icon: _controller.value.isPlaying
                              ? Icons.pause_rounded
                              : Icons.play_arrow_rounded,
                          onTap: _playPause,
                          tooltip: _controller.value.isPlaying ? '일시정지' : '재생',
                          emphasized: true,
                          isLight: isLight,
                          bg: Colors.transparent,
                        ),
                        const SizedBox(width: 8),
                        CircleIconButton(
                          icon: Icons.skip_next_rounded,
                          onTap: _nextSeg,
                          tooltip: '다음 구간',
                          isLight: isLight,
                        ),
                      ]),
                      Row(mainAxisSize: MainAxisSize.min, children: [
                        TogglePill(
                          icon: Icons.all_inclusive_rounded,
                          label: _scope == PlayScope.segment ? '구간' : '전체재생',
                          active: _scope == PlayScope.full,
                          onTap: () async {
                            // full → segment 전환 시, 현재 위치가 세그먼트 밖이면 세그 시작으로 정렬
                            if (_scope == PlayScope.full) {
                              final pos = _controller.value.position;
                              final st = Duration(milliseconds: _seg.startMs);
                              final en = Duration(milliseconds: _seg.endMs);
                              if (!(pos >= st && pos < en)) {
                                await _controller.seekTo(st);
                              }
                              // 세그먼트 모드로 가면 컨트롤러 루프는 끈다
                              await _controller.setLooping(false);
                              setState(() => _scope = PlayScope.segment);
                            } else {
                              // 전체재생 모드로 전환: 컨트롤러 루프는 _loopSeg 설정을 따른다(전체 영상 반복)
                              await _controller.setLooping(_loopSeg);
                              setState(() => _scope = PlayScope.full);
                            }
                          },
                          isLight: isLight,
                        ),
                        const SizedBox(width: 8),
                        TogglePill(
                          icon: Icons.repeat_rounded,
                          label: '반복',
                          active: _loopSeg,
                          onTap: _toggleLoop,
                          isLight: isLight,
                        ),
                        const SizedBox(width: 8),
                        TogglePill(
                          icon: Icons.subtitles_rounded,
                          label: '자막',
                          active: _showSubs,
                          onTap: _toggleSubs,
                          isLight: isLight,
                        ),
                        const SizedBox(width: 8),
                        SpeedMenu(
                            value: _rate,
                            onSelected: _setRate,
                            isLight: isLight),
                      ]),
                    ],
                  ),
                ),

                const SizedBox(height: 8),

                // --- Segments List ---
                Expanded(
                  child: SegmentList(
                    segments: _segments,
                    currentIndex: _segIndex,
                    onTapItem: (i) => _jumpToSegment(i, autoplay: true),
                  ),
                ),
              ],
            )
          : Center(
              child: CircularProgressIndicator(
                  color: isLight ? cs.primary : Colors.white)),
    );
  }
}
