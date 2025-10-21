// lib/mvp/onboarding/onboarding_screen.dart
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:parrokit/config/onboarding_prefs.dart';
import '../../pa_router.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final _ctl = PageController();
  int _index = 0;

  late final List<String> _images = List.generate(
    13,
        (i) => 'assets/onboardings/pa_onboarding_${i + 1}.png',
  );

  @override
  void didChangeDependencies() {
    // 자산 미리 로드 → 깜빡임 완화
    for (final p in _images) {
      precacheImage(AssetImage(p), context);
    }
    super.didChangeDependencies();
  }

  @override
  Widget build(BuildContext context) {
    final isLast = _index == _images.length - 1;
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        top: true,
        bottom: true,
        child: Stack(
          children: [
            // 페이지(스와이프 비활성 + 즉시 이동)
            PageView(
              controller: _ctl,
              physics: const NeverScrollableScrollPhysics(),
              onPageChanged: (i) => setState(() => _index = i),
              children: _images.map((img) {
                return LayoutBuilder(
                  builder: (context, constraints) {
                    // 하단 컨트롤 카드 높이(대략)만큼 여유
                    const bottomControlsHeight = 96.0; // 필요하면 80~120 사이로 조절
                    final availH = constraints.maxHeight - bottomControlsHeight;

                    return Align(
                      alignment: const Alignment(0, -0.7), // 👈 위로 당김(음수로 더 위)
                      child: ConstrainedBox(
                        constraints: BoxConstraints(
                          // 조금 더 크게
                          maxWidth: constraints.maxWidth * 0.94,
                          maxHeight: availH * 0.92, // 기존 0.78 → 여유 늘림
                        ),
                        child: Image.asset(
                          img,
                          fit: BoxFit.contain,
                          gaplessPlayback: true,
                          semanticLabel: '온보딩 이미지 ${_index + 1}',
                        ),
                      ),
                    );
                  },
                );
              }).toList(),
            ),

            // 상단 스크림(가독성)
            Positioned.fill(
              child: IgnorePointer(
                child: Column(
                  children: [
                    Container(
                      height: 120,
                      decoration: const BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [Colors.black87, Colors.transparent],
                        ),
                      ),
                    ),
                    const Spacer(),
                    Container(
                      height: 160,
                      decoration: const BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.bottomCenter,
                          end: Alignment.topCenter,
                          colors: [Colors.black87, Colors.transparent],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // 하단 컨트롤(글래스 카드)
            Positioned(
              left: 12,
              right: 12,
              bottom: 16,
              child: ClipRRect(
                borderRadius: BorderRadius.circular(16),
                child: BackdropFilter(
                  filter: ImageFilter.blur(sigmaX: 8, sigmaY: 8),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.06),
                      border: Border.all(color: Colors.white.withOpacity(0.12)),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        // 인디케이터 + 진행률
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: List.generate(_images.length, (i) {
                            final active = i == _index;
                            return AnimatedContainer(
                              duration: const Duration(milliseconds: 180),
                              margin: const EdgeInsets.symmetric(horizontal: 3, vertical: 6),
                              height: 6,
                              width: active ? 18 : 6,
                              decoration: BoxDecoration(
                                color: active ? Colors.white : Colors.white30,
                                borderRadius: BorderRadius.circular(10),
                              ),
                            );
                          }),
                        ),
                        Text(
                          '${_index + 1} / ${_images.length}',
                          style: theme.textTheme.labelMedium?.copyWith(
                            color: Colors.white70,
                            letterSpacing: 0.4,
                          ),
                        ),
                        const SizedBox(height: 4),
                        // 좌: 건너뛰기 / 우: 다음·시작하기
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            TextButton(
                              style: TextButton.styleFrom(
                                foregroundColor: Colors.white,
                                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                              ),
                              onPressed: () async {
                                HapticFeedback.lightImpact();
                                await OnboardingPrefs.setOnboarded(true);
                                if (context.mounted) {
                                  context.go(PaRoutes.dashboardPath);
                                }
                              },
                              child: const Text(
                                '건너뛰기',
                                style: TextStyle(decoration: TextDecoration.underline),
                              ),
                            ),
                            TextButton(
                              style: TextButton.styleFrom(
                                foregroundColor: Colors.white,
                                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                              ),
                              onPressed: () async {
                                HapticFeedback.lightImpact();
                                if (isLast) {
                                  // ✅ 마지막 페이지 → flag 저장 후 이동
                                  await OnboardingPrefs.setOnboarded(true);
                                  if (context.mounted) {
                                    context.go(PaRoutes.dashboardPath);
                                  }
                                } else {
                                  _ctl.jumpToPage(_index + 1);
                                }
                              },
                              child: Text(isLast ? '시작하기' : '다음'),
                            ),
                          ],
                        ),
                      ],
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