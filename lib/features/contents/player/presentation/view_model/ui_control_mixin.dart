// ============================================================================
// lib/features/player/presentation/mixins/ui_control_mixin.dart
// ============================================================================
//
// [역할]
// UI 관련 상태와 메소드 (풀스크린, 오버레이).
// ============================================================================

import 'dart:async';

import 'package:flutter/foundation.dart';

/// UI 컨트롤 믹스인.
///
/// 풀스크린 토글, 오버레이 표시/숨김.
mixin UiControlMixin on ChangeNotifier {
  // ─────────────────────────────────────────────────────────────────
  // State (mixin 자체에서 관리)
  // ─────────────────────────────────────────────────────────────────

  bool _isFullscreen = false;
  bool get isFullscreen => _isFullscreen;

  bool _overlayVisible = true;
  bool get overlayVisible => _overlayVisible;

  Timer? _overlayTimer;

  // ─────────────────────────────────────────────────────────────────
  // UI Controls
  // ─────────────────────────────────────────────────────────────────

  /// 풀스크린 토글.
  void toggleFullscreen() {
    _isFullscreen = !_isFullscreen;
    _overlayVisible = true;
    _startOverlayTimer();
    notifyListeners();
  }

  /// 오버레이 표시.
  void showOverlayTemporarily() {
    _overlayVisible = true;
    _startOverlayTimer();
    notifyListeners();
  }

  void _startOverlayTimer() {
    _overlayTimer?.cancel();
    _overlayTimer = Timer(const Duration(seconds: 5), () {
      _overlayVisible = false;
      notifyListeners();
    });
  }

  /// 타이머 정리 (dispose에서 호출).
  void disposeUiMixin() {
    _overlayTimer?.cancel();
  }
}
