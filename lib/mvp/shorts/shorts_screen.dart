import 'package:flutter/material.dart';
import 'package:parrokit/config/pa_config.dart';
import 'package:parrokit/pa_router.dart';
import 'package:parrokit/provider/ad_provider.dart';
import 'package:parrokit/provider/dashboard_ui_provider.dart';
import 'package:parrokit/provider/iap_provider.dart';
import 'package:parrokit/services/ad_service.dart';
import 'package:provider/provider.dart';
import 'package:parrokit/mvp/shorts/index.dart' as ShortsWidgets;

import '../../provider/shorts_provider.dart';
import 'package:go_router/go_router.dart';

class ShortsScreen extends StatefulWidget {
  const ShortsScreen({super.key});

  @override
  State<ShortsScreen> createState() => _ShortsScreenScreenState();
}

class _ShortsScreenScreenState extends State<ShortsScreen> {
  final PageController _pageController = PageController();
  final ValueNotifier<bool> _pauseSignal = ValueNotifier<bool>(false);
  int _currentIndex = 0; // 현재 보는 클립 인덱스
  bool _showSubtitle = true;
  int _advanceCount = 0;
  bool _initialized = false;

  @override
  void initState() {
    super.initState();
    _showSubtitle = PaConfig.shortsShowSubtitles;
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      context.read<ShortsProvider>().setAutoNext(PaConfig.autoNext);
    });
    // ✅ Provider에서 랜덤 10개 로딩
    Future.microtask(() {
      context.read<ShortsProvider>().loadInitial();
    });
  }

  void _maybeShowAdOnAdvance(BuildContext context, int oldIndex, int newIndex) {
    // 뒤로/같은 페이지는 무시, 앞으로 N칸 이동만 카운트
    final delta = newIndex - oldIndex;
    if (delta <= 0) return;

    final ad = context.read<AdProvider>();
    final shouldShow = ad.incrementBy(delta); // 내부에서 premium/모듈연산/저장 처리

    if (shouldShow) {
      _pauseSignal.value = true;
      AdService().showAd(); // premium이면 incrementBy가 false를 반환 → 여기 안 옴
      _pauseSignal.value = false;
    }
  }

  @override
  void dispose() {
    _pauseSignal.dispose();
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final iap = context.watch<IapProvider>();
    final premium = iap.isPremium;

    return Consumer<ShortsProvider>(
      builder: (_, shorts, __) {
        if (shorts.loading && shorts.shorts.isEmpty) {
          return const Center(child: CircularProgressIndicator());
        }
        if (shorts.shorts.isEmpty) {
          return const Center(
              child: Text("영상이 없습니다", style: TextStyle(color: Colors.white)));
        }

        return Scaffold(
          backgroundColor: Colors.black,
          body: Stack(
            children: [
              PageView.builder(
                controller: _pageController,
                scrollDirection: Axis.vertical,
                itemCount: shorts.shorts.length,
                onPageChanged: (i) {
                  // 초기 호출 한 번은 무시 (PageView가 첫 빌드 때도 불릴 수 있음)
                  if (!_initialized) {
                    _initialized = true;
                  } else {
                    _maybeShowAdOnAdvance(
                        context, _currentIndex, i);
                  }
                  setState(() => _currentIndex = i);
                },
                itemBuilder: (context, index) {
                  final item = shorts.shorts[index];
                  context
                      .read<DashboardUiProvider>()
                      .logRecent(item.clip.id); // 최근 본 클립 기록

                  return ShortsWidgets.ShortsPage(
                    key: ValueKey(item.clip.id),
                    isActive: index == _currentIndex,
                    filePath: item.clip.filePath,
                    durationMs: item.clip.durationMs,
                    autoNextEnabled: shorts.autoNext,
                    segments: item.segments,
                    pauseSignal: _pauseSignal,
                    showSubtilte: _showSubtitle,
                    onEnded: () {
                      final sp = context.read<ShortsProvider>();

                      final isLast = index >= shorts.shorts.length - 1;
                      if (!sp.autoNext || isLast) return;
                      if (_pageController.hasClients &&
                          _pageController.page?.round() == index) {
                        _pageController.nextPage(
                          duration: const Duration(milliseconds: 700),
                          curve: Curves.easeOutQuart,
                        );
                      }
                    },
                  );
                },
              ),
              // Top progress (story-like)
              Positioned(
                top: 60,
                left: 0,
                right: 0,
                child: SafeArea(
                  bottom: false,
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(12, 8, 12, 0),
                    child: ShortsWidgets.ProgressBar(
                      index: _currentIndex,
                      total: shorts.shorts.length,
                    ),
                  ),
                ),
              ),

              // Right action rail
              Positioned(
                right: 12,
                bottom: 110,
                child: ShortsWidgets.ActionRail(
                  autoNextEnabled: shorts.autoNext,
                  // Provider 상태
                  onAutoNextChanged: (enabled) {
                    shorts.setAutoNext(enabled);
                  },
                  onOpenExternalPlayer: () {
                    final item = shorts.shorts[_currentIndex];
                    final clipId = item.clip.id;

                    _pauseSignal.value = true; // 모두 멈춰/해제

                    context.pushNamed(
                      PaRoutes.clipsPlay,
                      queryParameters: {'clipId': clipId.toString()},
                    ).then((_) {
                      _pauseSignal.value = false;
                    });
                  },
                  showSubtitle: _showSubtitle,
                  onSubtitleChanged: (enabled) {
                    setState(() {
                      _showSubtitle = enabled;
                    });
                  },
                ),
              ),

              // Branding badges
              Positioned(
                left: 12,
                top: 12 + MediaQuery.of(context).padding.top,
                child: Row(
                  children: [
                    for (final tag in shorts.shorts[_currentIndex].tags)
                      Padding(
                        padding: const EdgeInsets.only(right: 8),
                        child: ShortsWidgets.Badge(
                          label: tag.name, // Drift Tag 모델의 name
                          icon: Icons
                              .star_border_rounded, // 적당한 아이콘, 원하면 tag마다 다르게
                        ),
                      ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
