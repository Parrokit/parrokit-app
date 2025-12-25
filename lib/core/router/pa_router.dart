// ============================================================================
// lib/core/router/pa_router.dart
// ============================================================================
//
// [역할]
// GoRouter 빌더.
// 앱 라우팅 정의 및 딥링크/리다이렉트 로직 처리.
//
// [레이어]
// Core Layer > Router
// ============================================================================

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

// Features - Screens
import 'package:parrokit/features/intro/presentation/intro_screen.dart';
import 'package:parrokit/features/auth/presentation/auth_screen.dart';
import 'package:parrokit/features/dashboard/presentation/dashboard_screen.dart';
import 'package:parrokit/features/shorts/shorts_screen.dart';
import 'package:parrokit/features/library/library_screen.dart';
import 'package:parrokit/features/more/more_screen.dart';
import 'package:parrokit/features/recent/recent_screen.dart';
import 'package:parrokit/features/editor/clip_editor_screen.dart';
import 'package:parrokit/features/player/clip_player_screen.dart';
import 'package:parrokit/features/recom/screens/recom_screen.dart';
import 'package:parrokit/features/recom/screens/recommendation_result_screen.dart';
import 'package:parrokit/features/recom/entities/recom_result_args.dart';
import 'package:parrokit/features/payment/presentation/payment_screen.dart';
import 'package:parrokit/features/payment/presentation/payment_success_screen.dart';
import 'package:parrokit/features/payment/presentation/payment_fail_screen.dart';
import 'package:parrokit/features/payment/domain/payment_args.dart';

// Router 관련
import 'pa_routes.dart';
import 'paro_shell.dart';

// Re-export for convenience
export 'pa_routes.dart';

/// GoRouter 빌더.
///
/// [seenIntro]: 인트로를 봤는지 여부에 따라 초기 경로 결정.
GoRouter buildPaRouter({required bool seenIntro}) {
  return GoRouter(
    debugLogDiagnostics: true,
    initialLocation: seenIntro ? PaRoutes.dashboardPath : PaRoutes.introPath,
    redirect: _handleRedirect,
    routes: [
      // ─────────────────────────────────────────────────────────────────
      // 단독 라우트 (쉘 외부)
      // ─────────────────────────────────────────────────────────────────
      _introRoute,
      _authRoute,
      _paymentRoute,
      _paymentSuccessRoute,
      _paymentFailRoute,

      // ─────────────────────────────────────────────────────────────────
      // ShellRoute (하단 네비바 + 자식 화면)
      // ─────────────────────────────────────────────────────────────────
      _shellRoute,
    ],
  );
}

// ─────────────────────────────────────────────────────────────────────────────
// Redirect Handler
// ─────────────────────────────────────────────────────────────────────────────

String? _handleRedirect(BuildContext context, GoRouterState state) {
  final uri = state.uri;
  final loc = uri.toString();

  // 0) 앱 루트('/') → 대시보드로
  if (loc == '/') {
    return PaRoutes.dashboardPath;
  }

  // 1) PortOne(Iamport) 앱 스킴 처리
  if (uri.scheme == 'parrokit') {
    final successParam =
        uri.queryParameters['imp_success'] ?? uri.queryParameters['success'];

    if (successParam == 'true') {
      return PaRoutes.paymentSuccessPath;
    }
    if (successParam == 'false') {
      return PaRoutes.paymentFailPath;
    }

    // 옛날 방식 지원
    if (loc.startsWith('parrokit://payment/success')) {
      return PaRoutes.paymentSuccessPath;
    }
    if (loc.startsWith('parrokit://payment/fail')) {
      return PaRoutes.paymentFailPath;
    }

    return PaRoutes.dashboardPath;
  }

  return null;
}

// ─────────────────────────────────────────────────────────────────────────────
// Route Definitions
// ─────────────────────────────────────────────────────────────────────────────

GoRoute get _introRoute => GoRoute(
      path: PaRoutes.introPath,
      name: PaRoutes.intro,
      pageBuilder: (context, state) => const NoTransitionPage(
        child: IntroScreen(),
      ),
    );

GoRoute get _authRoute => GoRoute(
      path: PaRoutes.authPath,
      name: PaRoutes.auth,
      pageBuilder: (context, state) => const NoTransitionPage(
        child: AuthScreen(),
      ),
    );

GoRoute get _paymentRoute => GoRoute(
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
            // TODO: 서버에 결제 상태 조회 요청 후 처리
          },
        );
      },
    );

GoRoute get _paymentSuccessRoute => GoRoute(
      path: PaRoutes.paymentSuccessPath,
      name: PaRoutes.paymentSuccess,
      builder: (context, state) => const PaymentSuccessScreen(),
    );

GoRoute get _paymentFailRoute => GoRoute(
      path: PaRoutes.paymentFailPath,
      name: PaRoutes.paymentFail,
      builder: (context, state) => const PaymentFailScreen(),
    );

// ─────────────────────────────────────────────────────────────────────────────
// Shell Route (Bottom Navigation)
// ─────────────────────────────────────────────────────────────────────────────

ShellRoute get _shellRoute => ShellRoute(
      builder: (context, state, child) => ParoShell(child: child),
      routes: [
        // Dashboard
        GoRoute(
          path: PaRoutes.dashboardPath,
          name: PaRoutes.dashboard,
          pageBuilder: (context, state) => NoTransitionPage(
            child: DashboardScreen(),
          ),
        ),

        // Explore (Shorts)
        GoRoute(
          path: PaRoutes.explorePath,
          name: PaRoutes.explore,
          pageBuilder: (context, state) => const NoTransitionPage(
            child: ShortsScreen(),
          ),
        ),

        // Library
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
              initialTab: int.tryParse(state.uri.queryParameters['tab'] ?? ''),
            ),
          ),
        ),

        // Recommendation
        GoRoute(
          path: PaRoutes.recomPath,
          name: PaRoutes.recom,
          pageBuilder: (context, state) => const NoTransitionPage(
            child: RecomScreen(),
          ),
        ),

        // Recommendation Result
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

        // More
        GoRoute(
          path: PaRoutes.morePath,
          name: PaRoutes.more,
          pageBuilder: (context, state) => const NoTransitionPage(
            child: MoreScreen(),
          ),
        ),

        // Recents
        GoRoute(
          path: PaRoutes.recentsPath,
          name: PaRoutes.recents,
          pageBuilder: (context, state) => const NoTransitionPage(
            child: RecentScreen(),
          ),
        ),

        // Clips (with nested routes)
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
              path: PaRoutes.clipsEditPath,
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
                    body: Center(
                      child: Text('clipId가 필요합니다. (?clipId=123)'),
                    ),
                  );
                }
                return ClipPlayerScreen(clipId: clipId);
              },
            ),
          ],
        ),
      ],
    );
