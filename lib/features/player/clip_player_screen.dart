// lib/mvp/player/clip_player_screen.dart
import 'dart:io' show File;
import 'dart:typed_data';
import 'dart:async';
import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:parrokit/core/config/pa_config.dart';
import 'package:parrokit/core/provider/clip_activity_provider.dart';
import 'package:path_provider/path_provider.dart';
import 'package:provider/provider.dart';
import 'package:video_player/video_player.dart';
import 'package:parrokit/core/provider/media_provider.dart';
import 'package:parrokit/data/local/pa_database.dart'; // Clip, Segment
import 'index.dart';
import 'package:parrokit/core/utils/audio_bg.dart';

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

class _ClipPlayerScreenState extends State<ClipPlayerScreen>
    with WidgetsBindingObserver {
  PlayScope _scope = PlayScope.segment;
  late VideoPlayerController _controller;

  bool _initialized = false;
  bool _loading = true;

  late int _segIndex;
  bool _loopSeg = true;
  bool _showSubs = true;
  double _rate = 1.0;
  bool _isBackground = false; // true면 백그라운드(오디오 전용) 모드
  bool _bgPlaying = false; // 백그라운드 오디오 재생 상태
  // 🔳 풀스크린 모드 + 오버레이(확장/닫기 버튼) 표시 여부
  bool _isFullscreen = false;
  bool _overlayVisible = true;
  Timer? _overlayTimer;

  // ✅ Drift rows 그대로 사용
  Clip? _clip;
  List<Segment> _segments = const [];
  String _appBarTitle = '재생';

  Segment get _seg => _segments[_segIndex];

  bool get _isPlaying =>
      _controller.value.isInitialized && _controller.value.isPlaying;

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
      context.read<ClipActivityProvider>().logRecent(widget.clipId);
      // 처음 진입 시 오버레이를 잠깐 보여주고 자동으로 숨김
      _showOverlayTemporarily();
    });
  }

  void _startOverlayTimer() {
    _overlayTimer?.cancel();
    _overlayTimer = Timer(const Duration(seconds: 5), () {
      if (!mounted) return;
      setState(() {
        _overlayVisible = false;
      });
    });
  }

  void _showOverlayTemporarily() {
    setState(() {
      _overlayVisible = true;
    });
    _startOverlayTimer();
  }

  void _toggleFullscreen() {
    setState(() {
      _isFullscreen = !_isFullscreen;
      _overlayVisible = true;
    });
    _startOverlayTimer();
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
    final h = await BgAudio.instance.ensureAudioHandler();
    await h.seek(target);
  }

  Future<void> _initVideo() async {
    if (_clip == null) return;
    final src = _clip!.filePath;

    String resolvedPath = src;
    if (!src.startsWith('/')) {
      final docs = await getApplicationDocumentsDirectory();
      resolvedPath = '${docs.path}/$src';
    }

    _controller = VideoPlayerController.file(File(resolvedPath));

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

    // 오디오 전용 모드에서는 audio_service가 자체적으로 백그라운드 재생을 담당하므로
    // 별도의 핸들링을 하지 않는다.
    if (_isBackground) return;

    if (state == AppLifecycleState.paused ||
        state == AppLifecycleState.inactive) {
      // 앱이 나갈 때는 비디오만 일시정지
      if (_controller.value.isInitialized && _controller.value.isPlaying) {
        await _controller.pause();
      }
    }
  }

  Future<void> _enterAudioOnlyMode() async {
    if (_isBackground) return;
    if (!_controller.value.isInitialized || _clip == null) return;

    // ✅ 먼저 UI부터 바꿔준다 (토글 누르자마자 반응하도록)
    _isBackground = true;
    _bgPlaying = false;
    if (mounted) setState(() {});

    try {
      // 1) 비디오가 재생 중이었는지 여부와 현재 위치를 기억
      await _controller.pause();
      final pos = _controller.value.position;

      // 2) 소스/클립 범위 준비
      final src = await _resolvedSourcePath();
      if (src.isEmpty) return;

      final clipBegin = _scope == PlayScope.segment
          ? Duration(milliseconds: _seg.startMs)
          : null;
      final clipEnd = _scope == PlayScope.segment
          ? Duration(milliseconds: _seg.endMs)
          : null;

      // 3) 썸네일 Uri 준비
      final media = context.read<MediaProvider>();
      final artUri = await _resolvedThumbUri(media);

      // 4) audio_handler로 로드 + 재생
      final h = await BgAudio.instance.ensureAudioHandler();
      await (h as dynamic).loadSourceLocal(
        absolutePath: src,
        speed: _rate,
        clipBegin: clipBegin,
        clipEnd: clipEnd,
        loop: _loopSeg,
        title: _clip?.title?.isNotEmpty == true ? _clip!.title! : '클립',
        artUri: artUri,
      );
      await h.seek(pos);
      await h.pause();

      // 🔄 백그라운드 재생이 시작된 뒤, 재생 버튼 아이콘이 바로 반영되도록 UI 갱신
      if (mounted) setState(() {});
    } catch (_) {
      // 실패했으면 모드를 원복해 준다
      if (mounted) {
        _isBackground = false;
        _bgPlaying = false;
        setState(() {});
      }
    }
  }

  Future<void> _exitAudioOnlyMode() async {
    if (!_isBackground) return;

    // ✅ 먼저 UI에서 오디오 전용 모드를 끈다
    _isBackground = false;
    if (mounted) setState(() {});

    try {
      final h = await BgAudio.instance.ensureAudioHandler();
      Duration bgPos;
      try {
        bgPos = (h as dynamic).position as Duration? ?? Duration.zero;
      } catch (_) {
        bgPos = Duration.zero;
      }

      await h.stop();
      _bgPlaying = false;

      if (_controller.value.isInitialized) {
        var target = bgPos;
        if (_scope == PlayScope.segment) {
          final st = Duration(milliseconds: _seg.startMs);
          final en = Duration(milliseconds: _seg.endMs);
          if (target < st || target >= en) {
            target = st;
          }
        }
        await _controller.seekTo(target);
        await _controller.setPlaybackSpeed(_rate);
      }
    } catch (_) {
      // 만약 실패했다면, 다시 오디오 모드로 되돌린다
      if (mounted) {
        _isBackground = true;
        _bgPlaying = true;
        setState(() {});
      }
    }
  }

  Future<void> _toggleAudioOnlyMode() async {
    if (_isBackground) {
      await _exitAudioOnlyMode();
    } else {
      await _enterAudioOnlyMode();
    }
  }

  // 🎴 클립 썸네일(Uint8List) → 임시 파일 → Uri 변환
  Future<Uri?> _resolvedThumbUri(MediaProvider media) async {
    // MediaProvider.clipItems에서 현재 clipId에 해당하는 썸네일 찾기
    Uint8List? thumbBytes;
    try {
      final item =
          media.clipItems.firstWhere((it) => it.clip.id == widget.clipId);
      thumbBytes = item.thumbnail;
    } catch (_) {
      thumbBytes = null;
    }

    if (thumbBytes == null || thumbBytes.isEmpty) return null;

    // 임시 디렉토리에 jpg로 저장 후, 파일 Uri 반환
    final tmpDir = await getTemporaryDirectory();
    final path = '${tmpDir.path}/clip_${widget.clipId}.jpg';
    final file = File(path);
    await file.writeAsBytes(thumbBytes, flush: true);

    return Uri.file(file.path);
  }

  Future<String> _resolvedSourcePath() async {
    final src = _clip!.filePath;
    if (src.startsWith('/')) return src;
    final docs = await getApplicationDocumentsDirectory();
    return '${docs.path}/$src';
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);

    // 이 화면을 떠날 때(창 나갈 때), 백그라운드 오디오 모드였다면 오디오도 정리
    if (_isBackground) {
      // dispose는 async를 쓸 수 없으므로 fire-and-forget 방식으로 중단 처리
      BgAudio.instance.ensureAudioHandler().then((h) async {
        try {
          await h.stop();
        } catch (_) {
          // 여기서 에러는 무시 (이미 정리된 경우 등)
        }
      });
      _bgPlaying = false;
      _isBackground = false;
    }

    if (_initialized) {
      _controller.removeListener(_onTick);
      _controller.dispose();
    }
    _overlayTimer?.cancel();
    super.dispose();
  }

// 🎬 포그라운드(영상) 재생/일시정지
  Future<void> _playPauseVideo() async {
    if (!_initialized || _segments.isEmpty) return;
    if (_isBackground) return; // 백그라운드 모드면 여기서 끝

    debugPrint(
      '[PLAY-VIDEO] tap: isBackground=$_isBackground, '
      'video=${_controller.value.isInitialized && _controller.value.isPlaying}',
    );

    try {
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
    } finally {}
  }

  // 🎧 백그라운드(오디오 전용) 재생/일시정지 토글
  Future<void> _playPauseBg() async {
    if (!_initialized || _segments.isEmpty) return;
    if (!_isBackground) return; // 포그라운드 모드면 여기서 끝

    debugPrint(
      '[PLAY-BG] tap: isBackground=$_isBackground, bg=$_bgPlaying',
    );
    final h = await BgAudio.instance.ensureAudioHandler();

    try {
      if (_bgPlaying) {
        if (mounted)
          setState(() {
            _bgPlaying = false;
          });
        await h.pause();

        debugPrint('pause - $_bgPlaying');
      } else {
        setState(() {
          _bgPlaying = true;
        });
        await h.play();

        debugPrint('play - $_bgPlaying');
      }
    } catch (e) {
      debugPrint('BG TOGGLE ERROR: $e');
    } finally {}
  }

  Future<void> _prevSeg() async {
    if (_isBackground) return;
    await _jumpToSegment((_segIndex - 1).clamp(0, _segments.length - 1));
  }

  Future<void> _nextSeg() async {
    if (_isBackground) return;
    await _jumpToSegment((_segIndex + 1).clamp(0, _segments.length - 1));
  }

  Future<void> _jumpToSegment(int index, {bool autoplay = false}) async {
    if (_isBackground) return;
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
    if (_isBackground) return;
    setState(() => _loopSeg = !_loopSeg);
    await _controller.setLooping(_scope == PlayScope.full && _loopSeg);
  }

  Future<void> _toggleSubs() async {
    if (_isBackground) return;
    setState(() => _showSubs = !_showSubs);
  }

  Future<void> _setRate(double r) async {
    if (_isBackground) return;
    _rate = r;
    await _controller.setPlaybackSpeed(r);

    if (mounted) setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context);
    final cs = t.colorScheme;
    final isLight = widget.tone == PlayerTone.light;

    final bg = isLight ? cs.surface : Colors.black;
    final fg = isLight ? cs.onSurface : Colors.white;

    final isLandscape =
        MediaQuery.of(context).orientation == Orientation.landscape;

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
      backgroundColor: _isFullscreen ? Colors.black : bg,
      appBar: _isFullscreen
          ? null
          : AppBar(
              backgroundColor: bg,
              surfaceTintColor: Colors.transparent,
              elevation: 0,
              foregroundColor: fg,
              title: Text(_appBarTitle),
            ),
      body: _isFullscreen
          ? GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTap: () {
                _showOverlayTemporarily();
                if (_isBackground) {
                  _playPauseBg();
                } else {
                  _playPauseVideo();
                }
              },
              child: Builder(
                builder: (context) {
                  final isPortrait =
                      MediaQuery.of(context).orientation ==
                          Orientation.portrait;
                  return RotatedBox(
                    quarterTurns: isPortrait ? 1 : 0,

                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        // 비디오를 화면 전체에 꽉 채우되, 비율은 유지하면서 잘라내기(BoxFit.cover)
                        Positioned.fill(
                          child: _isBackground
                              ? Container(color: Colors.black)
                              : Builder(
                                  builder: (context) {


                                    return FittedBox(
                                      fit: BoxFit.cover,
                                      child: SizedBox(
                                        width: _controller.value.size.width,
                                        height: _controller.value.size.height,
                                        child: isPortrait
                                            ? VideoPlayer(_controller)
                                            : VideoPlayer(_controller),
                                      ),
                                    );
                                  },
                                ),
                        ),
                        if (_showSubs)
                          PlainSubtitleOverlay(
                            ja: _seg.original,
                            pron: _seg.pron,
                            ko: _seg.trans,
                          ),
                        Positioned(
                          right: 12,
                          bottom: 12,
                          child: AnimatedOpacity(
                            opacity: _overlayVisible ? 1.0 : 0.0,
                            duration: const Duration(milliseconds: 250),
                            child: IgnorePointer(
                              ignoring: !_overlayVisible,
                              child: IconButton(
                                icon: Icon(
                                  _isFullscreen
                                      ? Icons.fullscreen_exit
                                      : Icons.fullscreen,
                                ),
                                color: Colors.white,
                                onPressed: _toggleFullscreen,
                              ),
                            ),
                          ),
                        ),
                        if (_isFullscreen)
                          Positioned(
                            right: 12,
                            top: 12,
                            child: AnimatedOpacity(
                              opacity: _overlayVisible ? 1.0 : 0.0,
                              duration: const Duration(milliseconds: 250),
                              child: IgnorePointer(
                                ignoring: !_overlayVisible,
                                child: Builder(
                                  builder: (context) {
                                    final isPortrait =
                                        MediaQuery.of(context).orientation ==
                                            Orientation.portrait;
                                    return Transform.rotate(
                                      angle: isPortrait ? math.pi / 2 : 0.0,
                                      child: IconButton(
                                        icon: const Icon(Icons.close),
                                        color: Colors.white,
                                        onPressed: _toggleFullscreen,
                                      ),
                                    );
                                  },
                                ),
                              ),
                            ),
                          ),
                      ],
                    ),
                  );
                }
              ),
            )
          : isLandscape
              ? Row(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // 왼쪽: 영상 + 타임라인 + 컨트롤
                    Expanded(
                      child: Column(
                        children: [
                          // --- Video --- (화면 높이의 일부만 쓰도록 Flexible)
                          Flexible(
                            flex: 3,
                            child: Center(
                              child: AspectRatio(
                                aspectRatio: _controller.value.aspectRatio == 0
                                    ? 16 / 9
                                    : _controller.value.aspectRatio,
                                child: Stack(
                                  alignment: Alignment.center,
                                  children: [
                                    Positioned.fill(
                                      child: GestureDetector(
                                        behavior: HitTestBehavior.opaque,
                                        onTap: () {
                                          _showOverlayTemporarily();
                                          if (_isBackground) {
                                            _playPauseBg();
                                          } else {
                                            _playPauseVideo();
                                          }
                                        },
                                        child: _isBackground
                                            ? Container(
                                                color: Colors.black,
                                              )
                                            : VideoPlayer(_controller),
                                      ),
                                    ),
                                    if (_showSubs)
                                      PlainSubtitleOverlay(
                                        ja: _seg.original,
                                        pron: _seg.pron,
                                        ko: _seg.trans,
                                      ),
                                    // 🔳 풀스크린 토글 / 닫기 버튼 오버레이
                                    Positioned(
                                      right: 12,
                                      bottom: 12,
                                      child: AnimatedOpacity(
                                        opacity: _overlayVisible ? 1.0 : 0.0,
                                        duration:
                                            const Duration(milliseconds: 250),
                                        child: IgnorePointer(
                                          ignoring: !_overlayVisible,
                                          child: IconButton(
                                            icon: Icon(
                                              _isFullscreen
                                                  ? Icons.fullscreen_exit
                                                  : Icons.fullscreen,
                                            ),
                                            color: Colors.white,
                                            onPressed: _toggleFullscreen,
                                          ),
                                        ),
                                      ),
                                    ),
                                    if (_isFullscreen)
                                      Positioned(
                                        right: 12,
                                        top: 12,
                                        child: AnimatedOpacity(
                                          opacity: _overlayVisible ? 1.0 : 0.0,
                                          duration:
                                              const Duration(milliseconds: 250),
                                          child: IgnorePointer(
                                            ignoring: !_overlayVisible,
                                            child: IconButton(
                                              icon: const Icon(Icons.close),
                                              color: Colors.white,
                                              onPressed: _toggleFullscreen,
                                            ),
                                          ),
                                        ),
                                      ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(height: 8),
                          // --- Timeline ---
                          IgnorePointer(
                            ignoring: _isBackground,
                            child: SegmentTimeline(
                              controller: _controller,
                              start: Duration(milliseconds: _seg.startMs),
                              end: Duration(milliseconds: _seg.endMs),
                              onSeek: _onUserSeek,
                            ),
                          ),
                          const SizedBox(height: 8),
                          // --- Controls ---
                          Padding(
                            padding: const EdgeInsets.fromLTRB(12, 8, 12, 24),
                            child: Wrap(
                              spacing: 8,
                              runSpacing: 8,
                              crossAxisAlignment: WrapCrossAlignment.center,
                              alignment: WrapAlignment.center,
                              children: [
                                Row(mainAxisSize: MainAxisSize.min, children: [
                                  IgnorePointer(
                                    ignoring: _isBackground,
                                    child: Opacity(
                                      opacity: _isBackground ? 0.4 : 1.0,
                                      child: CircleIconButton(
                                        icon: Icons.skip_previous_rounded,
                                        onTap: _prevSeg,
                                        tooltip: '이전 구간',
                                        isLight: isLight,
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  if (_isBackground)
                                    CircleIconButton(
                                      icon: _bgPlaying
                                          ? Icons.pause_rounded
                                          : Icons.play_arrow_rounded,
                                      onTap: _playPauseBg,
                                      tooltip: _bgPlaying ? '일시정지' : '재생',
                                      emphasized: true,
                                      isLight: isLight,
                                      bg: Colors.transparent,
                                    ),
                                  if (!_isBackground)
                                    CircleIconButton(
                                      icon: _isPlaying
                                          ? Icons.pause_rounded
                                          : Icons.play_arrow_rounded,
                                      onTap: _playPauseVideo,
                                      tooltip: _isPlaying ? '일시정지' : '재생',
                                      emphasized: true,
                                      isLight: isLight,
                                      bg: Colors.transparent,
                                    ),
                                  const SizedBox(width: 8),
                                  IgnorePointer(
                                    ignoring: _isBackground,
                                    child: Opacity(
                                      opacity: _isBackground ? 0.4 : 1.0,
                                      child: CircleIconButton(
                                        icon: Icons.skip_next_rounded,
                                        onTap: _nextSeg,
                                        tooltip: '다음 구간',
                                        isLight: isLight,
                                      ),
                                    ),
                                  ),
                                ]),
                                SingleChildScrollView(
                                  scrollDirection: Axis.horizontal,
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      IgnorePointer(
                                        ignoring: _isBackground,
                                        child: Opacity(
                                          opacity: _isBackground ? 0.4 : 1.0,
                                          child: TogglePill(
                                            icon: Icons.all_inclusive_rounded,
                                            label: _scope == PlayScope.segment
                                                ? '구간'
                                                : '전체재생',
                                            active: _scope == PlayScope.full,
                                            onTap: () async {
                                              // full → segment 전환 시, 현재 위치가 세그먼트 밖이면 세그 시작으로 정렬
                                              if (_scope == PlayScope.full) {
                                                final pos =
                                                    _controller.value.position;
                                                final st = Duration(
                                                    milliseconds: _seg.startMs);
                                                final en = Duration(
                                                    milliseconds: _seg.endMs);
                                                if (!(pos >= st && pos < en)) {
                                                  await _controller.seekTo(st);
                                                }
                                                // 세그먼트 모드로 가면 컨트롤러 루프는 끈다
                                                await _controller
                                                    .setLooping(false);
                                                setState(() =>
                                                    _scope = PlayScope.segment);
                                              } else {
                                                // 전체재생 모드로 전환: 컨트롤러 루프는 _loopSeg 설정을 따른다(전체 영상 반복)
                                                await _controller
                                                    .setLooping(_loopSeg);
                                                setState(() =>
                                                    _scope = PlayScope.full);
                                              }
                                            },
                                            isLight: isLight,
                                          ),
                                        ),
                                      ),
                                      const SizedBox(width: 8),
                                      IgnorePointer(
                                        ignoring: _isBackground,
                                        child: Opacity(
                                          opacity: _isBackground ? 0.4 : 1.0,
                                          child: TogglePill(
                                            icon: Icons.repeat_rounded,
                                            label: '반복',
                                            active: _loopSeg,
                                            onTap: _toggleLoop,
                                            isLight: isLight,
                                          ),
                                        ),
                                      ),
                                      const SizedBox(width: 8),
                                      IgnorePointer(
                                        ignoring: _isBackground,
                                        child: Opacity(
                                          opacity: _isBackground ? 0.4 : 1.0,
                                          child: TogglePill(
                                            icon: Icons.subtitles_rounded,
                                            label: '자막',
                                            active: _showSubs,
                                            onTap: _toggleSubs,
                                            isLight: isLight,
                                          ),
                                        ),
                                      ),
                                      const SizedBox(width: 8),
                                      TogglePill(
                                        icon: Icons.headphones_rounded,
                                        label: '백그라운드',
                                        active: _isBackground,
                                        onTap: _toggleAudioOnlyMode,
                                        isLight: isLight,
                                      ),
                                      const SizedBox(width: 8),
                                      IgnorePointer(
                                        ignoring: _isBackground,
                                        child: Opacity(
                                          opacity: _isBackground ? 0.4 : 1.0,
                                          child: SpeedMenu(
                                            value: _rate,
                                            onSelected: _setRate,
                                            isLight: isLight,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    // 오른쪽: 세그먼트 리스트(자막 역할)
                    Container(
                      width: 400,
                      decoration: BoxDecoration(
                        color: bg,
                        border: Border(
                          left: BorderSide(
                            color: cs.outline.withOpacity(0.2),
                          ),
                        ),
                      ),
                      child: IgnorePointer(
                        ignoring: _isBackground,
                        child: Opacity(
                          opacity: _isBackground ? 0.4 : 1.0,
                          child: SegmentList(
                            segments: _segments,
                            currentIndex: _segIndex,
                            onTapItem: (i) => _jumpToSegment(i, autoplay: true),
                          ),
                        ),
                      ),
                    ),
                  ],
                )
              : Column(
                  children: [
                    // --- Video + Subs ---
                    AspectRatio(
                      aspectRatio: _controller.value.aspectRatio == 0
                          ? 16 / 9
                          : _controller.value.aspectRatio,
                      child: Stack(
                        alignment: Alignment.center,
                        children: [
                          Positioned.fill(
                            child: GestureDetector(
                              behavior: HitTestBehavior.opaque,
                              onTap: () {
                                _showOverlayTemporarily();
                                if (_isBackground) {
                                  _playPauseBg();
                                } else {
                                  _playPauseVideo();
                                }
                              },
                              child: _isBackground
                                  ? Container(
                                      color: Colors.black,
                                    )
                                  : VideoPlayer(_controller),
                            ),
                          ),
                          if (_showSubs)
                            PlainSubtitleOverlay(
                              ja: _seg.original,
                              pron: _seg.pron,
                              ko: _seg.trans,
                            ),
                          // 🔳 풀스크린 토글 / 닫기 버튼 오버레이 (세로 모드에서도 동일)
                          Positioned(
                            right: 12,
                            bottom: 12,
                            child: AnimatedOpacity(
                              opacity: _overlayVisible ? 1.0 : 0.0,
                              duration: const Duration(milliseconds: 250),
                              child: IgnorePointer(
                                ignoring: !_overlayVisible,
                                child: IconButton(
                                  icon: Icon(
                                    _isFullscreen
                                        ? Icons.fullscreen_exit
                                        : Icons.fullscreen,
                                  ),
                                  color: Colors.white,
                                  onPressed: _toggleFullscreen,
                                ),
                              ),
                            ),
                          ),
                          if (_isFullscreen)
                            Positioned(
                              right: 12,
                              top: 12,
                              child: AnimatedOpacity(
                                opacity: _overlayVisible ? 1.0 : 0.0,
                                duration: const Duration(milliseconds: 250),
                                child: IgnorePointer(
                                  ignoring: !_overlayVisible,
                                  child: IconButton(
                                    icon: const Icon(Icons.close),
                                    color: Colors.white,
                                    onPressed: _toggleFullscreen,
                                  ),
                                ),
                              ),
                            ),
                        ],
                      ),
                    ),
                    // --- Timeline ---
                    IgnorePointer(
                      ignoring: _isBackground,
                      child: SegmentTimeline(
                        controller: _controller,
                        start: Duration(milliseconds: _seg.startMs),
                        end: Duration(milliseconds: _seg.endMs),
                        onSeek: _onUserSeek,
                      ),
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
                            IgnorePointer(
                              ignoring: _isBackground,
                              child: Opacity(
                                opacity: _isBackground ? 0.4 : 1.0,
                                child: CircleIconButton(
                                  icon: Icons.skip_previous_rounded,
                                  onTap: _prevSeg,
                                  tooltip: '이전 구간',
                                  isLight: isLight,
                                ),
                              ),
                            ),
                            const SizedBox(width: 8),
                            if (_isBackground)
                              CircleIconButton(
                                icon: _bgPlaying
                                    ? Icons.pause_rounded
                                    : Icons.play_arrow_rounded,
                                onTap: _playPauseBg,
                                tooltip: _bgPlaying ? '일시정지' : '재생',
                                emphasized: true,
                                isLight: isLight,
                                bg: Colors.transparent,
                              ),
                            if (!_isBackground)
                              CircleIconButton(
                                icon: _isPlaying
                                    ? Icons.pause_rounded
                                    : Icons.play_arrow_rounded,
                                onTap: _playPauseVideo,
                                tooltip: _isPlaying ? '일시정지' : '재생',
                                emphasized: true,
                                isLight: isLight,
                                bg: Colors.transparent,
                              ),
                            const SizedBox(width: 8),
                            IgnorePointer(
                              ignoring: _isBackground,
                              child: Opacity(
                                opacity: _isBackground ? 0.4 : 1.0,
                                child: CircleIconButton(
                                  icon: Icons.skip_next_rounded,
                                  onTap: _nextSeg,
                                  tooltip: '다음 구간',
                                  isLight: isLight,
                                ),
                              ),
                            ),
                          ]),
                          SingleChildScrollView(
                            scrollDirection: Axis.horizontal,
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                IgnorePointer(
                                  ignoring: _isBackground,
                                  child: Opacity(
                                    opacity: _isBackground ? 0.4 : 1.0,
                                    child: TogglePill(
                                      icon: Icons.all_inclusive_rounded,
                                      label: _scope == PlayScope.segment
                                          ? '구간'
                                          : '전체재생',
                                      active: _scope == PlayScope.full,
                                      onTap: () async {
                                        // full → segment 전환 시, 현재 위치가 세그먼트 밖이면 세그 시작으로 정렬
                                        if (_scope == PlayScope.full) {
                                          final pos =
                                              _controller.value.position;
                                          final st = Duration(
                                              milliseconds: _seg.startMs);
                                          final en = Duration(
                                              milliseconds: _seg.endMs);
                                          if (!(pos >= st && pos < en)) {
                                            await _controller.seekTo(st);
                                          }
                                          // 세그먼트 모드로 가면 컨트롤러 루프는 끈다
                                          await _controller.setLooping(false);
                                          setState(
                                              () => _scope = PlayScope.segment);
                                        } else {
                                          // 전체재생 모드로 전환: 컨트롤러 루프는 _loopSeg 설정을 따른다(전체 영상 반복)
                                          await _controller
                                              .setLooping(_loopSeg);
                                          setState(
                                              () => _scope = PlayScope.full);
                                        }
                                      },
                                      isLight: isLight,
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 8),
                                IgnorePointer(
                                  ignoring: _isBackground,
                                  child: Opacity(
                                    opacity: _isBackground ? 0.4 : 1.0,
                                    child: TogglePill(
                                      icon: Icons.repeat_rounded,
                                      label: '반복',
                                      active: _loopSeg,
                                      onTap: _toggleLoop,
                                      isLight: isLight,
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 8),
                                IgnorePointer(
                                  ignoring: _isBackground,
                                  child: Opacity(
                                    opacity: _isBackground ? 0.4 : 1.0,
                                    child: TogglePill(
                                      icon: Icons.subtitles_rounded,
                                      label: '자막',
                                      active: _showSubs,
                                      onTap: _toggleSubs,
                                      isLight: isLight,
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 8),
                                TogglePill(
                                  icon: Icons.headphones_rounded,
                                  label: '백그라운드',
                                  active: _isBackground,
                                  onTap: _toggleAudioOnlyMode,
                                  isLight: isLight,
                                ),
                                const SizedBox(width: 8),
                                IgnorePointer(
                                  ignoring: _isBackground,
                                  child: Opacity(
                                    opacity: _isBackground ? 0.4 : 1.0,
                                    child: SpeedMenu(
                                      value: _rate,
                                      onSelected: _setRate,
                                      isLight: isLight,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 8),
                    // --- Segments List ---
                    Expanded(
                      child: IgnorePointer(
                        ignoring: _isBackground,
                        child: Opacity(
                          opacity: _isBackground ? 0.4 : 1.0,
                          child: SegmentList(
                            segments: _segments,
                            currentIndex: _segIndex,
                            onTapItem: (i) => _jumpToSegment(i, autoplay: true),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
    );
  }
}
