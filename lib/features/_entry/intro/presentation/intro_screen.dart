// ============================================================================
// lib/features/intro/presentation/intro_screen.dart
// ============================================================================
//
// [역할]
// 온보딩 메인 화면. 앱 첫 실행 시 사용법 가이드 표시.
// 13개 이미지를 페이지 형태로 보여주고, 완료 시 대시보드로 이동.
//
// [레이어]
// Presentation Layer - View
//
// [구성 요소]
// - IntroPageSection: 이미지 페이지 영역
// - IntroControlsSection: 하단 컨트롤 (인디케이터, 버튼)
// ============================================================================

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:parrokit/data/local/prefs/intro_prefs.dart';
import 'package:parrokit/core/router/app_router.dart';

import 'sections/intro_page_section.dart';
import 'sections/intro_controls_section.dart';
import 'widgets/gradient_scrim.dart';

/// 온보딩 화면.
///
/// 앱 첫 실행 시 사용법 가이드를 보여주는 화면.
/// 페이지 스와이프 대신 버튼으로 이동.
class IntroScreen extends StatefulWidget {
  const IntroScreen({super.key});

  @override
  State<IntroScreen> createState() => _IntroScreenState();
}

class _IntroScreenState extends State<IntroScreen> {
  // ─────────────────────────────────────────────────────────────────
  // State & Controllers
  // ─────────────────────────────────────────────────────────────────

  final _pageController = PageController();
  int _currentIndex = 0;

  /// 온보딩 이미지 경로 목록
  late final List<String> _images = List.generate(
    13,
    (i) => 'assets/intros/pa_intro_${i + 1}.png',
  );

  // ─────────────────────────────────────────────────────────────────
  // Lifecycle
  // ─────────────────────────────────────────────────────────────────

  @override
  void didChangeDependencies() {
    // 자산 미리 로드 → 깜빡임 완화
    for (final path in _images) {
      precacheImage(AssetImage(path), context);
    }
    super.didChangeDependencies();
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  // ─────────────────────────────────────────────────────────────────
  // Actions
  // ─────────────────────────────────────────────────────────────────

  /// 다음 페이지로 이동 또는 완료
  Future<void> _onNext() async {
    HapticFeedback.lightImpact();

    if (_isLastPage) {
      await _completeIntro();
    } else {
      _pageController.jumpToPage(_currentIndex + 1);
    }
  }

  /// 건너뛰기
  Future<void> _onSkip() async {
    HapticFeedback.lightImpact();
    await _completeIntro();
  }

  /// 온보딩 완료 처리
  Future<void> _completeIntro() async {
    await IntroPrefs.markAsSeen(true);
    if (mounted) {
      context.go(AppRoutes.dashboardPath);
    }
  }

  bool get _isLastPage => _currentIndex == _images.length - 1;

  // ─────────────────────────────────────────────────────────────────
  // Build
  // ─────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: Stack(
          children: [
            // 상하단 그라데이션 스크림 (배경)
            const GradientScrim(),

            // 페이지 영역 (이미지가 그라데이션 위에 표시)
            IntroPageSection(
              controller: _pageController,
              images: _images,
              onPageChanged: (i) => setState(() => _currentIndex = i),
            ),

            // 하단 컨트롤
            Positioned(
              left: 12,
              right: 12,
              bottom: 16,
              child: IntroControlsSection(
                currentIndex: _currentIndex,
                totalCount: _images.length,
                isLastPage: _isLastPage,
                onNext: _onNext,
                onSkip: _onSkip,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
