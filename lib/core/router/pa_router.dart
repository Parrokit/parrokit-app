// lib/pa_router.dart
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:parrokit/features/onboarding/onboarding_screen.dart';
import 'package:parrokit/features/payment/payment_args.dart';
import 'package:parrokit/features/payment/payment_screen.dart';
import 'package:parrokit/features/recent/recent_screen.dart';
import 'package:parrokit/features/recom/entities/recom_result_args.dart';
import 'package:parrokit/features/recom/screens/recom_screen.dart';
import 'package:parrokit/features/auth/auth_screen.dart';
import 'package:parrokit/features/recom/screens/recommendation_result_screen.dart';

import 'package:parrokit/features/shorts/shorts_screen.dart';
import 'package:parrokit/features/editor/clip_editor_screen.dart';
import 'package:parrokit/features/library/library_screen.dart';
import 'package:parrokit/features/navbar/paro_bottom_navbar.dart';

import 'package:parrokit/features/dashboard/dashboard_screen.dart';
import 'package:parrokit/features/player/clip_player_screen.dart';
import 'package:parrokit/features/more/more_screen.dart';

/// 라우트 이름/경로 상수
abstract class PaRoutes {
  // names
  static const dashboard = 'dashboard';
  static const explore = 'explore';
  static const library = 'library';
  static const more = 'more';
  static const clips = 'clips';
  static const recom = 'recom';
  static const recomResult = 'recom_result';
  static const recents = 'recents';
  static const clipsCreate = 'clips_create';
  static const clipsEdit = 'clips_edit';
  static const clipsPlay = 'clips_play';
  static const onboarding = 'onboarding';
  static const auth = 'auth';
  static const payment = 'payment';
  static const paymentSuccess = 'payment_success';
  static const paymentFail = 'payment_fail';

  // paths
  static const dashboardPath = '/dashboard';
  static const explorePath = '/explore';
  static const libraryPath = '/library';
  static const morePath = '/more';
  static const clipsPath = '/clips';
  static const recomPath = '/recom';
  static const recomResultPath = '/recom/result';
  static const recentsPath = '/recents';
  static const clipsCreatePath = 'create';
  static const clipsEditPath = 'edit';
  static const clipsPlayPath = 'play';
  static const onboardingPath = '/onboarding';
  static const authPath = '/auth';
  static const paymentPath = '/payment';
  static const paymentSuccessPath = '/payment/success';
  static const paymentFailPath = '/payment/fail';
}



GoRouter buildPaRouter({required bool seenOnboarding}) {
  return GoRouter(
    debugLogDiagnostics: true,
    initialLocation:
        seenOnboarding ? PaRoutes.dashboardPath : PaRoutes.onboardingPath,
    redirect: (context, state) {
      final uri = state.uri;
      final loc = uri.toString();

      // 0) 앱 루트('/') → 대시보드로
      if (loc == '/') {
        return PaRoutes.dashboardPath;
      }

      // 1) PortOne(Iamport) 앱 스킴 처리
      // 예: parrokit:///?imp_success=true&imp_uid=...&merchant_uid=...
      if (uri.scheme == 'parrokit') {
        final successParam =
            uri.queryParameters['imp_success'] ?? uri.queryParameters['success'];

        if (successParam == 'true') {
          return PaRoutes.paymentSuccessPath;
        }
        if (successParam == 'false') {
          return PaRoutes.paymentFailPath;
        }

        // 옛날 방식: parrokit://payment/success 같은 형태도 지원
        if (loc.startsWith('parrokit://payment/success')) {
          return PaRoutes.paymentSuccessPath;
        }
        if (loc.startsWith('parrokit://payment/fail')) {
          return PaRoutes.paymentFailPath;
        }

        // 그 외 parrokit://* 로 열리면 기본적으로 대시보드로
        return PaRoutes.dashboardPath;
      }

      return null; // 나머지는 그대로 둠
    },

    routes: [
      GoRoute(
        path: PaRoutes.onboardingPath,
        name: PaRoutes.onboarding,
        pageBuilder: (context, state) => const NoTransitionPage(
          child: OnboardingScreen(),
        ),
      ),
      GoRoute(
        path: PaRoutes.authPath,
        name: PaRoutes.auth,
        pageBuilder: (context, state) => const NoTransitionPage(
          child: AuthScreen(),
        ),
      ),
      GoRoute(
         path: PaRoutes.paymentPath,
         name: PaRoutes.payment,
         builder: (context, state) {
           final args = state.extra as PaymentArgs;
           return PaymentScreen(
             merchantUid: args.merchantUid,
             amount: args.amount,
             coins: args.coins,
             productName: args.productName,
             buyerEmail: args.buyerEmail,
             onResult: (result) {
               // TODO: 서버에 결제 상태 조회 요청 후, Navigator.pop 등 처리
             },
           );
         },
       ),
      GoRoute(
        path: PaRoutes.paymentSuccessPath,
        name: PaRoutes.paymentSuccess,
        builder: (context, state) => const PaymentSuccessScreen(),
      ),
      GoRoute(
        path: PaRoutes.paymentFailPath,
        name: PaRoutes.paymentFail,
        builder: (context, state) => const PaymentFailScreen(),
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
            path: PaRoutes.recomResultPath,
            name: PaRoutes.recomResult,
            builder: (context, state) {
              final args = state.extra as RecomResultArgs;
              return RecommendationResultScreen(
                results: args.results,
                titles: args.titles,
                topK: args.topK,
                cutoff: args.cutoff,
                excludeWatched: args.excludeWatched,
              );
            },
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
