import 'dart:async';
import 'package:flutter/material.dart';

OverlayEntry? _toastEntry;
Timer? _toastRemoveTimer;

/// iOS 스타일 토스트 (Fade In/Out)
/// 기존 showToast(context, "msg") 호출 그대로 사용 가능
void showToast(BuildContext context, String msg) {
  final overlay = Overlay.of(context);
  if (overlay == null) return;

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
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
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