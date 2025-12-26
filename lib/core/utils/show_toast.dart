import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:parrokit/core/app.dart';

OverlayEntry? _toastEntry;
Timer? _toastRemoveTimer;

/// iOS 스타일 토스트 (Fade In/Out)
/// 기존 showToast(context, "msg") 호출 그대로 사용 가능
///
/// Overlay가 없는 경우 SnackBar로 fallback 합니다.
void showToast(BuildContext context, String msg, {String? devMsg = ''}) {
  // mounted 체크 - context가 유효한지 확인
  if (!context.mounted) {
    // context가 없으면 global scaffoldMessengerKey 사용 시도
    _showWithScaffoldMessenger(msg, devMsg);
    return;
  }

  // Overlay 찾기 - maybeOf 사용하여 null 안전하게 처리
  final overlay = Overlay.maybeOf(context);
  if (overlay == null) {
    // Overlay가 없으면 SnackBar로 fallback
    _showWithScaffoldMessenger(msg, devMsg);
    return;
  }

  _showWithOverlay(overlay, context, msg, devMsg);
}

/// Context 없이 전역으로 토스트 표시
void showToastGlobal(String msg, {String? devMsg = ''}) {
  _showWithScaffoldMessenger(msg, devMsg);
}

/// ScaffoldMessenger를 통한 SnackBar 표시
void _showWithScaffoldMessenger(String msg, String? devMsg) {
  final messenger = scaffoldMessengerKey.currentState;
  if (messenger == null) {
    debugPrint('🍞 Toast (no messenger): $msg');
    return;
  }

  messenger.hideCurrentSnackBar();
  messenger.showSnackBar(
    SnackBar(
      content: Text(msg),
      behavior: SnackBarBehavior.floating,
      duration: const Duration(milliseconds: 2500),
      margin: const EdgeInsets.fromLTRB(32, 0, 32, 80),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
    ),
  );

  debugPrint('🍞 Toast (snackbar): $msg');
  if (devMsg != null && devMsg.isNotEmpty) {
    debugPrint('🍞 Toast (dev): $devMsg');
  }
}

/// Overlay를 통한 커스텀 토스트 표시
void _showWithOverlay(
    OverlayState overlay, BuildContext context, String msg, String? devMsg) {
  // 기존 토스트가 떠있으면 제거
  _toastRemoveTimer?.cancel();
  _toastEntry?.remove();
  _toastEntry = null;

  // 타이밍 (원하면 아래 값만 조정)
  const fadeIn = Duration(milliseconds: 200);
  const visible = Duration(milliseconds: 2000);
  const fadeOut = Duration(milliseconds: 400);
  final total = fadeIn + visible + fadeOut;

  _toastEntry = OverlayEntry(
    builder: (ctx) => _ToastCard(
      msg: msg,
      fadeIn: fadeIn,
      fadeOut: fadeOut,
      // 키보드 올라오면 살짝 위로
      bottom: 80 + MediaQuery.of(ctx).viewInsets.bottom,
    ),
  );

  overlay.insert(_toastEntry!);
  debugPrint('🍞 Toast: $msg');
  if (devMsg != null && devMsg.isNotEmpty) {
    debugPrint('🍞 Toast (dev): $devMsg');
  }
  // 총 지속시간 뒤 안전 제거
  _toastRemoveTimer = Timer(total, () {
    _toastEntry?.remove();
    _toastEntry = null;
    _toastRemoveTimer = null;
  });
}

class _ToastCard extends StatefulWidget {
  final String msg;
  final double bottom;
  final Duration fadeIn;
  final Duration fadeOut;

  const _ToastCard({
    required this.msg,
    required this.bottom,
    required this.fadeIn,
    required this.fadeOut,
  });

  @override
  State<_ToastCard> createState() => _ToastCardState();
}

class _ToastCardState extends State<_ToastCard> {
  double _opacity = 0.0;

  @override
  void initState() {
    super.initState();

    // Fade In
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      setState(() => _opacity = 1.0);
    });

    // Fade Out 예약 (fadeIn 끝난 뒤 + visible 구간)
    Future.delayed(widget.fadeIn + const Duration(milliseconds: 2000), () {
      if (!mounted) return;
      setState(() => _opacity = 0.0);
    });
  }

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: SafeArea(
        child: Stack(
          children: [
            Positioned(
              left: 32,
              right: 32,
              bottom: widget.bottom,
              child: AnimatedOpacity(
                opacity: _opacity,
                duration: _opacity == 1.0 ? widget.fadeIn : widget.fadeOut,
                curve: Curves.easeOutCubic,
                child: Material(
                  color: Colors.transparent,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 12),
                    decoration: BoxDecoration(
                      color: Colors.black.withOpacity(0.85),
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: const [
                        BoxShadow(
                          blurRadius: 8,
                          offset: Offset(0, 4),
                          color: Color(0x33000000),
                        ),
                      ],
                    ),
                    child: Text(
                      widget.msg,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        height: 1.2,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
