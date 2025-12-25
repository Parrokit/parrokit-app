import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:parrokit/core/provider/dashboard_ui_provider.dart';
import 'package:provider/provider.dart';
import 'package:parrokit/core/provider/media_provider.dart';
import 'logo_badge.dart';

class Header extends StatefulWidget {
  const Header({
    super.key,
    required this.textPrimary,
    required this.textSecondary,
  });

  final Color textPrimary;
  final Color textSecondary;

  @override
  State<Header> createState() => _HeaderState();
}

class _HeaderState extends State<Header> with SingleTickerProviderStateMixin {
  late final AnimationController _pulse; // 로딩 중 숨쉬기 애니
  late final Animation<double> _scale;
  late final Animation<double> _fade;

  int _prevFinal = 0; // 직전 최종 값(트윈 시작점 추정용)
  int _target = 0; // 목표 값 (mp.clipCount 동기화용)

  @override
  void initState() {
    super.initState();
    _pulse = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    );
    // 1.0 ↔ 1.04 정도의 미세한 스케일로 ‘숨쉬기’ 느낌
    _scale = Tween<double>(begin: 1.0, end: 1.04).animate(
      CurvedAnimation(parent: _pulse, curve: Curves.easeInOut),
    );
    // 0.72 ↔ 1.0 정도의 미세한 투명도 변화
    _fade = Tween<double>(begin: 0.72, end: 1.0).animate(
      CurvedAnimation(parent: _pulse, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _pulse.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final dup = context.watch<DashboardUiProvider>();
    final isLoading = dup.isCounting;

    _target = dup.clipCount;

    // 로딩 상태에 따라 숨쉬기 애니 on/off
    if (isLoading) {
      if (!_pulse.isAnimating) _pulse.repeat(reverse: true);
    } else {
      if (_pulse.isAnimating) _pulse.stop();
    }

    final gradientPaint = Paint()
      ..shader = const LinearGradient(
        colors: [Color(0xFF3B82F6), Color(0xFF06B6D4)],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      ).createShader(const Rect.fromLTWH(0, 0, 200, 40));

    // 숫자 스타일
    final numberStyle = TextStyle(
      fontSize: 20,
      fontWeight: FontWeight.bold,
      foreground: gradientPaint,
      height: 1.0,
    );

    // 로딩 끝난 순간에만 트윈 시작점 갱신
    final tweenBegin = _prevFinal;
    final tweenEnd = _target;
    if (!isLoading) _prevFinal = _target;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10.0),
      child: Row(
        children: [
          const LogoBadge(),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 숫자 + 문구 라인
                Row(
                  crossAxisAlignment: CrossAxisAlignment.baseline,
                  textBaseline: TextBaseline.alphabetic,
                  children: [
                    // 로딩 중엔 숨쉬기(Scale/Opacity), 끝나면 Tween으로 자연스럽게 증가
                    isLoading
                        ? ScaleTransition(
                            scale: _scale,
                            child: FadeTransition(
                              opacity: _fade,
                              // 로딩 중엔 마지막으로 알고 있는 값 유지 (혹은 '--' 쓰고 싶으면 바꾸세요)
                              child: Text(
                                '$_prevFinal',
                                style: numberStyle,
                              ),
                            ),
                          )
                        : TweenAnimationBuilder<double>(
                            key: ValueKey(tweenEnd),
                            tween: Tween<double>(
                              begin: tweenBegin.toDouble(),
                              end: tweenEnd.toDouble(),
                            ),
                            duration: const Duration(milliseconds: 500),
                            curve: Curves.easeInSine,
                            builder: (_, v, __) => Text(
                              '${v.round()}',
                              style: numberStyle,
                            ),
                          ),
                    const SizedBox(width: 4),
                    Text(
                      '개의 클립을 모았어요 🎬',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontSize: 18,
                            fontWeight: FontWeight.w800,
                            color: widget.textPrimary,
                          ),
                    ),
                  ],
                ),
                const SizedBox(height: 2),
                const Text('오늘도 한 장면씩 👋', style: TextStyle(fontSize: 12)),
              ],
            ),
          ),
          IconButton(
            onPressed: () => context.push('/clips/create'),
            icon: const Icon(Icons.add_box_rounded, size: 28),
            splashRadius: 24,
          ),
        ],
      ),
    );
  }
}
