// ============================================================================
// lib/features/player/presentation/mixins/playback_control_mixin.dart
// ============================================================================
//
// [역할]
// 재생 제어 관련 상태와 메소드.
// ============================================================================

import 'package:flutter/foundation.dart';
import 'package:video_player/video_player.dart';

import 'package:parrokit/core/utils/audio_bg.dart';
import 'package:parrokit/data/local/app_database.dart';
import 'package:parrokit/features/content/player/domain/player_state.dart';

/// 재생 제어 믹스인.
///
/// 재생/일시정지, 세그먼트 탐색, 시크, 설정 관련 기능 제공.
mixin PlaybackControlMixin on ChangeNotifier {
  // ─────────────────────────────────────────────────────────────────
  // Abstract getters (메인 클래스에서 구현)
  // ─────────────────────────────────────────────────────────────────

  VideoPlayerController? get controller;
  List<Segment> get segments;
  Segment get currentSegment;
  bool get isInitialized;
  bool get isBackground;
  PlayScope get scope;
  bool get loopSegment;
  double get playbackRate;
  int get segIndex;

  // Setters (abstract - 메인 클래스에서 override)
  set mutableSegIndex(int value);
  set mutableScope(PlayScope value);
  set mutableLoopSegment(bool value);
  set mutableShowSubtitles(bool value);
  set mutablePlaybackRate(double value);
  set mutableBgPlaying(bool value);
  bool get bgPlaying;
  bool get showSubtitles;

  // ─────────────────────────────────────────────────────────────────
  // Playback Control
  // ─────────────────────────────────────────────────────────────────

  /// 재생/일시정지 토글.
  Future<void> playPause() async {
    if (isBackground) {
      await _playPauseBg();
    } else {
      await _playPauseVideo();
    }
  }

  Future<void> _playPauseVideo() async {
    if (!isInitialized || segments.isEmpty || controller == null) return;
    if (isBackground) return;

    if (controller!.value.isPlaying) {
      await controller!.pause();
    } else {
      if (scope == PlayScope.segment) {
        final pos = controller!.value.position;
        final st = Duration(milliseconds: currentSegment.startMs);
        final en = Duration(milliseconds: currentSegment.endMs);
        if (pos < st || pos >= en) {
          await controller!.seekTo(st);
        }
      }
      await controller!.play();
    }
    notifyListeners();
  }

  Future<void> _playPauseBg() async {
    if (!isInitialized || segments.isEmpty) return;
    if (!isBackground) return;

    final h = await BgAudio.instance.ensureAudioHandler();

    if (bgPlaying) {
      mutableBgPlaying = false;
      notifyListeners();
      await h.pause();
    } else {
      mutableBgPlaying = true;
      notifyListeners();
      await h.play();
    }
  }

  // ─────────────────────────────────────────────────────────────────
  // Segment Navigation
  // ─────────────────────────────────────────────────────────────────

  /// 이전 세그먼트로 이동.
  Future<void> prevSegment() async {
    if (isBackground) return;
    await jumpToSegment((segIndex - 1).clamp(0, segments.length - 1));
  }

  /// 다음 세그먼트로 이동.
  Future<void> nextSegment() async {
    if (isBackground) return;
    await jumpToSegment((segIndex + 1).clamp(0, segments.length - 1));
  }

  /// 특정 세그먼트로 이동.
  Future<void> jumpToSegment(int index, {bool autoplay = false}) async {
    if (isBackground || segments.isEmpty || controller == null) return;

    if (index == segIndex) {
      await controller!.seekTo(Duration(milliseconds: currentSegment.startMs));
    } else {
      mutableSegIndex = index;
      await controller!.seekTo(Duration(milliseconds: segments[index].startMs));
    }

    if (autoplay || controller!.value.isPlaying) {
      await controller!.play();
    } else {
      await controller!.pause();
    }
    notifyListeners();
  }

  /// 사용자 시크.
  Future<void> seekTo(Duration target) async {
    if (!isInitialized || segments.isEmpty || controller == null) return;

    final total = controller!.value.duration;
    Duration clamp(Duration x, Duration lo, Duration hi) =>
        x < lo ? lo : (x > hi ? hi : x);

    Duration finalTarget;
    if (scope == PlayScope.segment) {
      final newIdx = indexForPosition(target);
      if (newIdx != null && newIdx != segIndex) {
        mutableSegIndex = newIdx;
      }
      final st = Duration(milliseconds: currentSegment.startMs);
      final en = Duration(milliseconds: currentSegment.endMs);
      finalTarget = clamp(target, st, en);
    } else {
      finalTarget = clamp(target, Duration.zero, total);
    }

    await controller!.seekTo(finalTarget);
    notifyListeners();

    final h = await BgAudio.instance.ensureAudioHandler();
    await h.seek(finalTarget);
  }

  /// 위치로 세그먼트 인덱스 찾기.
  int? indexForPosition(Duration pos) {
    for (int i = 0; i < segments.length; i++) {
      final s = segments[i];
      final start = Duration(milliseconds: s.startMs);
      final end = Duration(milliseconds: s.endMs);
      if (pos >= start && pos < end) return i;
    }
    return null;
  }

  // ─────────────────────────────────────────────────────────────────
  // Settings
  // ─────────────────────────────────────────────────────────────────

  /// 구간/전체 재생 모드 토글.
  Future<void> toggleScope() async {
    if (isBackground || controller == null) return;

    if (scope == PlayScope.full) {
      final pos = controller!.value.position;
      final st = Duration(milliseconds: currentSegment.startMs);
      final en = Duration(milliseconds: currentSegment.endMs);
      if (!(pos >= st && pos < en)) {
        await controller!.seekTo(st);
      }
      await controller!.setLooping(false);
      mutableScope = PlayScope.segment;
    } else {
      await controller!.setLooping(loopSegment);
      mutableScope = PlayScope.full;
    }
    notifyListeners();
  }

  /// 루프 토글.
  Future<void> toggleLoop() async {
    if (isBackground || controller == null) return;
    mutableLoopSegment = !loopSegment;
    await controller!.setLooping(scope == PlayScope.full && loopSegment);
    notifyListeners();
  }

  /// 자막 토글.
  void toggleSubtitles() {
    if (isBackground) return;
    mutableShowSubtitles = !showSubtitles;
    notifyListeners();
  }

  /// 재생 속도 설정.
  Future<void> setPlaybackRate(double rate) async {
    if (isBackground || controller == null) return;
    mutablePlaybackRate = rate;
    await controller!.setPlaybackSpeed(rate);
    notifyListeners();
  }
}
