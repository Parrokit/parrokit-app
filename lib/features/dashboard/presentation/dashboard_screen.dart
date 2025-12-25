// ============================================================================
// lib/features/dashboard/presentation/dashboard_screen.dart
// ============================================================================
//
// [역할]
// 대시보드 메인 화면. 앱 홈 화면으로 사용.
// 히어로 카드, 퀵 액션, 이어보기, 모음집, 랜덤 자막 섹션으로 구성.
//
// [레이어]
// Presentation Layer - View
// ClipActivityProvider를 통해 데이터를 구독하고 표시.
//
// [구성 요소]
// - HeaderSection: 상단 로고 + 클립 수 표시
// - HeroSection: 오늘의 학습 카드
// - QuickActionsSection: 빠른 액션 버튼들
// - ContinueWatchingSection: 이어보기 리스트
// - CollectionsSection: 모음집 그리드
// - RandomSubtitleSection: 랜덤 자막 리스트
// ============================================================================

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:parrokit/core/router/pa_router.dart';
import 'package:provider/provider.dart';
import 'package:parrokit/core/provider/clip_activity_provider.dart';

import 'sections/header_section.dart';
import 'sections/hero_section.dart';
import 'sections/quick_actions_section.dart';
import 'sections/continue_watching_section.dart';
import 'sections/collections_section.dart';
import 'sections/random_subtitle_section.dart';

/// 대시보드 메인 화면 (앱 홈).
///
/// [ClipActivityProvider]를 구독하여 데이터 표시.
/// Pull-to-refresh로 데이터 갱신.
class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  // ─────────────────────────────────────────────────────────────────
  // Lifecycle
  // ─────────────────────────────────────────────────────────────────

  @override
  void initState() {
    super.initState();
    // 화면 초기 진입 시 데이터 로드
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final ui = context.read<ClipActivityProvider>();
      ui.refreshRandomSegments();
      ui.refreshRandomHeroClip();
    });
  }

  // ─────────────────────────────────────────────────────────────────
  // Actions
  // ─────────────────────────────────────────────────────────────────

  /// Pull-to-refresh 핸들러
  Future<void> _onRefresh() async {
    // ✅ async gap 전에 Provider 캡처
    final ui = context.read<ClipActivityProvider>();

    await Future.wait([
      ui.refreshRandomSegments(),
      ui.refreshRandomHeroClip(),
    ]);
  }

  // ─────────────────────────────────────────────────────────────────
  // Build
  // ─────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    // 테마 색상
    final bg = isDark ? const Color(0xFF0D0F12) : const Color(0xFFF7F8FA);

    // Provider 구독
    final ui = context.watch<ClipActivityProvider>();

    return Scaffold(
      backgroundColor: bg,
      body: RefreshIndicator(
        onRefresh: _onRefresh,
        child: CustomScrollView(
          slivers: [
            // ─────────────────────────────────────────────────────────
            // 헤더 섹션 (로고 + 클립 수)
            // ─────────────────────────────────────────────────────────
            SliverToBoxAdapter(
              child: SafeArea(
                bottom: false,
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(20, 8, 20, 0),
                  child: const HeaderSection(),
                ),
              ),
            ),

            // ─────────────────────────────────────────────────────────
            // 히어로 카드 섹션
            // ─────────────────────────────────────────────────────────
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 8, 20, 0),
                child: HeroSection(
                  heroClip: ui.heroClip,
                  loading: ui.loadingHero,
                  onTap: () => _navigateToHeroClip(ui.heroClip),
                ),
              ),
            ),

            // ─────────────────────────────────────────────────────────
            // 퀵 액션 섹션
            // ─────────────────────────────────────────────────────────
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
                child: QuickActionsSection(
                  onTapAdd: () => context.push('/clips/create'),
                  onTapLibrary: () => context.go('/library'),
                  onTapSearch: () => context.replaceNamed(
                    PaRoutes.library,
                    queryParameters: {'tab': '1'},
                  ),
                  onTapSettings: () => context.replaceNamed(PaRoutes.more),
                ),
              ),
            ),

            // ─────────────────────────────────────────────────────────
            // 이어보기 섹션
            // ─────────────────────────────────────────────────────────
            SliverToBoxAdapter(
              child: ContinueWatchingSection(
                items: ui.recent6,
                onTapItem: (clipId) => context.pushNamed(
                  PaRoutes.clipsPlay,
                  queryParameters: {'clipId': clipId.toString()},
                ),
                onTapMore: () => context.push(PaRoutes.recentsPath),
                onTapLibrary: () => context.go('/library'),
              ),
            ),

            // ─────────────────────────────────────────────────────────
            // 모음집 섹션
            // ─────────────────────────────────────────────────────────
            SliverToBoxAdapter(
              child: CollectionsSection(collections: ui.collections),
            ),

            // ─────────────────────────────────────────────────────────
            // 랜덤 자막 섹션
            // ─────────────────────────────────────────────────────────
            RandomSubtitleSection(
              segments: ui.randomSegments,
              loading: ui.loadingRandom,
            ),

            // 하단 여백
            const SliverToBoxAdapter(child: SizedBox(height: 24)),
          ],
        ),
      ),
    );
  }

  /// 히어로 클립 탭 시 네비게이션
  void _navigateToHeroClip((int, dynamic, String?, String?)? hero) {
    if (hero != null) {
      final (clipId, _thumbnail, _clipTitle, _titleName) = hero;
      context.pushNamed(
        PaRoutes.clipsPlay,
        queryParameters: {'clipId': clipId.toString()},
      );
    } else {
      context.go(PaRoutes.libraryPath);
    }
  }
}
