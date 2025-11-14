// lib/pa_router.dart
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:parrokit/mvp/onboarding/onboarding_screen.dart';
import 'package:parrokit/mvp/recent/recent_screen.dart';
import 'package:parrokit/mvp/recom/screens/recom_screen.dart';

import 'package:parrokit/mvp/shorts/shorts_screen.dart';
import 'package:parrokit/mvp/editor/clip_editor_screen.dart';
import 'package:parrokit/mvp/library/library_screen.dart';
import 'package:parrokit/mvp/navbar/paro_bottom_navbar.dart';

import 'package:parrokit/mvp/dashboard/dashboard_screen.dart';
import 'package:parrokit/mvp/player/clip_player_screen.dart';
import 'package:parrokit/mvp/more/more_screen.dart';

/// 라우트 이름/경로 상수
abstract class PaRoutes {
  // names
  static const dashboard = 'dashboard';
  static const explore = 'explore';
  static const library = 'library';
  static const more = 'more';
  static const clips = 'clips';
  static const recom = 'recom';
  static const recents = 'recents';
  static const clipsCreate = 'clips_create';
  static const clipsEdit = 'clips_edit';
  static const clipsPlay = 'clips_play';
  static const onboarding = 'onboarding';

  // paths
  static const dashboardPath = '/dashboard';
  static const explorePath = '/explore';
  static const libraryPath = '/library';
  static const morePath = '/more';
  static const clipsPath = '/clips';
  static const recomPath = '/recom';
  static const recentsPath = '/recents';
  static const clipsCreatePath = 'create';
  static const clipsEditPath = 'edit';
  static const clipsPlayPath = 'play';
  static const onboardingPath = '/onboarding';
}

GoRouter buildPaRouter({required bool seenOnboarding}) {
  return GoRouter(
    initialLocation:
        seenOnboarding ? PaRoutes.dashboardPath : PaRoutes.onboardingPath,
    routes: [
      GoRoute(
        path: PaRoutes.onboardingPath,
        name: PaRoutes.onboarding,
        pageBuilder: (context, state) => const NoTransitionPage(
          child: OnboardingScreen(),
        ),
      ),
      // ShellRoute: 하단 네비바 고정 + 내부 자식 화면만 바뀜
      ShellRoute(
        builder: (context, state, child) {
          return _ParoShellGo(child: child);
        },
        routes: [
          GoRoute(
            path: PaRoutes.dashboardPath,
            name: PaRoutes.dashboard,
            pageBuilder: (context, state) => NoTransitionPage(
              child: DashboardScreen(),
            ),
          ),
          GoRoute(
            path: PaRoutes.explorePath,
            name: PaRoutes.explore,
            pageBuilder: (context, state) => const NoTransitionPage(
              child: ShortsScreen(),
            ),
          ),
          GoRoute(
            path: PaRoutes.libraryPath,
            name: PaRoutes.library,
            pageBuilder: (context, state) => NoTransitionPage(
              child: LibraryScreen(
                initialTitleId:
                    int.tryParse(state.uri.queryParameters['titleId'] ?? ''),
                initialReleaseId:
                    int.tryParse(state.uri.queryParameters['releaseId'] ?? ''),
                initialEpisodeId:
                    int.tryParse(state.uri.queryParameters['episodeId'] ?? ''),
                initialTab:
                    int.tryParse(state.uri.queryParameters['tab'] ?? ''),
              ),
            ),
          ),
          GoRoute(
            path: PaRoutes.recomPath,
            name: PaRoutes.recom,
            pageBuilder: (context, state) => const NoTransitionPage(
              child: RecomScreen(),
            ),
          ),
          GoRoute(
            path: PaRoutes.morePath,
            name: PaRoutes.more,
            pageBuilder: (context, state) => const NoTransitionPage(
              child: MoreScreen(),
            ),
          ),
          GoRoute(
            path: PaRoutes.recentsPath,
            name: PaRoutes.recents,
            pageBuilder: (context, state) => const NoTransitionPage(
              child: RecentScreen(),
            ),
          ),
          GoRoute(
            path: PaRoutes.clipsPath,
            name: PaRoutes.clips,
            builder: (context, state) => const SizedBox.shrink(),
            routes: [
              GoRoute(
                path: PaRoutes.clipsCreatePath,
                name: PaRoutes.clipsCreate,
                builder: (context, state) => ClipEditorScreen(),
              ),
              GoRoute(
                path: PaRoutes.clipsEditPath, // 'edit'
                name: PaRoutes.clipsEdit,
                builder: (context, state) {
                  final clipIdStr = state.uri.queryParameters['clipId'];
                  final clipId = int.tryParse(clipIdStr ?? '');
                  return ClipEditorScreen(clipId: clipId);
                },
              ),
              GoRoute(
                path: PaRoutes.clipsPlayPath,
                name: PaRoutes.clipsPlay,
                builder: (context, state) {
                  final clipIdStr = state.uri.queryParameters['clipId'];
                  final clipId = int.tryParse(clipIdStr ?? '');
                  if (clipId == null) {
                    return const Scaffold(
                      body: Center(child: Text('clipId가 필요합니다. (?clipId=123)')),
                    );
                  }
                  return ClipPlayerScreen(clipId: clipId);
                },
              ),
            ],
          ),
        ],
      ),
    ],
  );
}

class _ParoShellGo extends StatelessWidget {
  const _ParoShellGo({required this.child});

  final Widget child;

  int _indexFromLocation(String location) {
    if (location.startsWith(PaRoutes.explorePath)) return 1;
    if (location.startsWith(PaRoutes.libraryPath)) return 2;
    if (location.startsWith(PaRoutes.recomPath)) return 3;
    if (location.startsWith(PaRoutes.morePath)) return 4;
    return 0;
  }

  @override
  Widget build(BuildContext context) {
    final loc = GoRouterState.of(context).uri.toString();
    final currentIndex = _indexFromLocation(loc);

    final hideNav = loc.startsWith('/clips/') || loc == PaRoutes.recentsPath;
    // 👆 예: /clips/... 에서는 NavBar 숨기기

    return Scaffold(
      body: child,
      bottomNavigationBar: hideNav
          ? null // 이 경우 NavBar 안나옴
          : ParoBottomNavBar(
              currentIndex: currentIndex,
              onTap: (i) {
                switch (i) {
                  case 0:
                    context.go(PaRoutes.dashboardPath);
                    break;
                  case 1:
                    context.go(PaRoutes.explorePath);
                    break;
                  case 2:
                    context.go(PaRoutes.libraryPath);
                    break;
                  case 3:
                    context.go(PaRoutes.recomPath);
                    break;
                  case 4:
                    context.go(PaRoutes.morePath);
                    break;
                }
              },
            ),
    );
  }
}
