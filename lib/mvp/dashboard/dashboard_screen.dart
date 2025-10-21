import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:parrokit/pa_router.dart';
import 'index.dart';

// ⬇️ 추가
import 'package:provider/provider.dart';
import 'package:parrokit/provider/dashboard_ui_provider.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  @override
  void initState() {
    super.initState();
    // 화면 초기 진입 시 랜덤 자막 로드
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final ui = context.read<DashboardUiProvider>();
      ui.refreshRandomSegments();
      ui.refreshRandomHeroClip();
    });
  }
  Future<void> _onRefresh() async {
    // setState() 쓰지 말고, Provider 메서드만 호출 -> notifyListeners()로 갱신됨
    final ui = context.read<DashboardUiProvider>();
    await Future.wait([
      ui.refreshRandomSegments(),
      ui.refreshRandomHeroClip(),
      // 필요 시 다른 갱신도 여기 추가
    ]);
  }
  
  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bg = isDark ? const Color(0xFF0D0F12) : const Color(0xFFF7F8FA);
    final cardBg = isDark ? const Color(0xFF15181C) : Colors.white;
    final subtle =
        isDark ? Colors.white.withOpacity(.08) : Colors.black.withOpacity(.06);
    final textPrimary = isDark ? Colors.white : const Color(0xFF111418);
    final textSecondary =
        isDark ? Colors.white.withOpacity(.7) : const Color(0xFF556070);
    final accent = cs.primary;

    final ui = context.watch<DashboardUiProvider>();
    final recents = ui.recent6;
    final collections = ui.collections;
    final hero = ui.heroClip;

    return Scaffold(
      backgroundColor: bg,
      body: RefreshIndicator(
        onRefresh: _onRefresh,
        child: CustomScrollView(
          slivers: [
            SliverToBoxAdapter(
              child: SafeArea(
                bottom: false,
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(20, 8, 20, 0),
                  child: Header(
                      textPrimary: textPrimary, textSecondary: textSecondary),
                ),
              ),
            ),
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 8, 20, 0),
                child:
                HeroCard(
                  cardBg: cardBg,
                  subtle: subtle,
                  textPrimary: textPrimary,
                  textSecondary: textSecondary,
                  accent: accent,
                  title: hero?.$4,
                  clipTitle: hero?.$3,
                  loading: ui.loadingHero,
                  onGo: () {
                    if (hero != null) {
                      final (clipId, _, __, ___) = hero;
                      context.pushNamed(
                        PaRoutes.clipsPlay,
                        queryParameters: {'clipId': clipId.toString()},
                      );
                    } else {
                      context.go(PaRoutes.libraryPath);
                    }
                  },
                ),
              ),
            ),
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
                child: QuickActions(
                  cardBg: cardBg,
                  subtle: subtle,
                  textPrimary: textPrimary,
                  textSecondary: textSecondary,
                  onTapRecord: () => context.go('/clips'),
                  onTapImport: () => context.push('/clips/create'),
                  onTapLibrary: () => context.go('/library'),
                ),
              ),
            ),
            SliverToBoxAdapter(
              child: Section(
                title: '이어보기',
                subtitle: '최근에 보던 클립',
                textPrimary: textPrimary,
                textSecondary: textSecondary,
                padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
                trailing: TextButton(
                  onPressed: () => context.push(PaRoutes.recentsPath),
                  child: const Text('모두 보기'),
                ),
              ),
            ),
        
            // ⬇️ recent 전달
            SliverToBoxAdapter(
              child: ContinueWatchingRow(
                items: recents,
                // List<(int, Uint8List?, String?, String?)>
                cardBg: cardBg,
                subtle: subtle,
                textPrimary: textPrimary,
                textSecondary: textSecondary,
                onTapItem: (clipId) => context.pushNamed(
                  PaRoutes.clipsPlay,
                  queryParameters: {'clipId': clipId.toString()},
                ),
                onTapMore: () => context.go('/library'),
              ),
            ),
        
            SliverToBoxAdapter(
              child: Section(
                title: '모음집',
                subtitle: '작품별 정리',
                textPrimary: textPrimary,
                textSecondary: textSecondary,
                padding: const EdgeInsets.fromLTRB(20, 24, 20, 8),
              ),
            ),
            SliverPadding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              sliver: CollectionsGrid(
                cardBg: cardBg,
                subtle: subtle,
                textPrimary: textPrimary,
                textSecondary: textSecondary,
                collections: collections,
              ),
            ),
        
            SliverToBoxAdapter(
              child: Section(
                title: '랜덤으로 자막 보기',
                subtitle: ui.loadingRandom
                    ? '불러오는 중...'
                    : '${ui.randomSegments.length}개를 무작위로 골라왔어요',
                textPrimary: textPrimary,
                textSecondary: textSecondary,
                padding: const EdgeInsets.fromLTRB(20, 24, 20, 8),
              ),
            ),
        
            RandomSubtitleList(
              segments: ui.randomSegments,
              loading: ui.loadingRandom,
              skeletonCount: ui.randomSegments.length,
            ),
            const SliverToBoxAdapter(child: SizedBox(height: 24)),
          ],
        ),
      ),
    );
  }
}
