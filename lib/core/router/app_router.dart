// ============================================================================
// lib/core/router/app_router.dart
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
import 'package:provider/provider.dart';
import 'package:parrokit/core/provider/user_provider.dart';

// Features - Screens
import 'package:parrokit/features/_entry/intro/presentation/intro_screen.dart';
import 'package:parrokit/features/_entry/auth/presentation/auth_screen.dart';
import 'package:parrokit/features/_entry/dashboard/presentation/dashboard_screen.dart';
import 'package:parrokit/features/_content/shorts/presentation/shorts_screen.dart';
import 'package:parrokit/features/_content/library/presentation/library_screen.dart';
import 'package:parrokit/features/_settings/more/presentation/more_screen.dart';
import 'package:parrokit/features/_discovery/recent/presentation/recent_screen.dart';
import 'package:parrokit/features/_content/clip_editor/presentation/clip_editor_screen.dart';
import 'package:parrokit/features/_content/player/presentation/clip_player_screen.dart';
import 'package:parrokit/features/_settings/payment/presentation/payment_screen.dart';
import 'package:parrokit/features/_settings/payment/presentation/payment_success_screen.dart';
import 'package:parrokit/features/_settings/payment/presentation/payment_fail_screen.dart';
import 'package:parrokit/features/_settings/payment/domain/payment_args.dart';

// Router 관련
import 'app_routes.dart';
import 'app_shell.dart';

// Re-export for convenience
export 'app_routes.dart';

/// 루트 네비게이터 키 (전역 컨텍스트 접근용)
final rootNavigatorKey = GlobalKey<NavigatorState>();

/// GoRouter 빌더.
///
/// [seenIntro]: 인트로를 봤는지 여부에 따라 초기 경로 결정.
GoRouter buildAppRouter({
  required bool seenIntro,
  required UserProvider userProvider,
}) {
  return GoRouter(
    navigatorKey: rootNavigatorKey,
    debugLogDiagnostics: true,
    initialLocation: seenIntro ? AppRoutes.dashboardPath : AppRoutes.introPath,
    redirect: _handleRedirect,
    refreshListenable: userProvider,
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
    return AppRoutes.dashboardPath;
  }

  // 1) PortOne(Iamport) 앱 스킴 처리
  if (uri.scheme == 'parrokit') {
    final successParam =
        uri.queryParameters['imp_success'] ?? uri.queryParameters['success'];

    if (successParam == 'true') {
      return AppRoutes.paymentSuccessPath;
    }
    if (successParam == 'false') {
      return AppRoutes.paymentFailPath;
    }

    // 옛날 방식 지원
    if (loc.startsWith('parrokit://payment/success')) {
      return AppRoutes.paymentSuccessPath;
    }
    if (loc.startsWith('parrokit://payment/fail')) {
      return AppRoutes.paymentFailPath;
    }

    return AppRoutes.dashboardPath;
  }

  // 2) Auth guard
  final user = Provider.of<UserProvider>(context, listen: false);
  final isOnAuth = loc.startsWith(AppRoutes.authPath);
  final isOnIntro = loc.startsWith(AppRoutes.introPath);

  if (!user.isLoggedIn && !isOnAuth && !isOnIntro) {
    return AppRoutes.authPath;
  }

  if (user.isLoggedIn && isOnAuth) {
    return AppRoutes.dashboardPath;
  }

  return null;
}

// ─────────────────────────────────────────────────────────────────────────────
// Route Definitions
// ─────────────────────────────────────────────────────────────────────────────

GoRoute get _introRoute => GoRoute(
      path: AppRoutes.introPath,
      name: AppRoutes.intro,
      pageBuilder: (context, state) => NoTransitionPage(
        name: AppRoutes.intro,
        child: const IntroScreen(),
      ),
    );

GoRoute get _authRoute => GoRoute(
      path: AppRoutes.authPath,
      name: AppRoutes.auth,
      pageBuilder: (context, state) => NoTransitionPage(
        name: AppRoutes.auth,
        child: const AuthScreen(),
      ),
    );

GoRoute get _paymentRoute => GoRoute(
      path: AppRoutes.paymentPath,
      name: AppRoutes.payment,
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
      path: AppRoutes.paymentSuccessPath,
      name: AppRoutes.paymentSuccess,
      builder: (context, state) => const PaymentSuccessScreen(),
    );

GoRoute get _paymentFailRoute => GoRoute(
      path: AppRoutes.paymentFailPath,
      name: AppRoutes.paymentFail,
      builder: (context, state) => const PaymentFailScreen(),
    );

// ─────────────────────────────────────────────────────────────────────────────
// Shell Route (Bottom Navigation)
// ─────────────────────────────────────────────────────────────────────────────

ShellRoute get _shellRoute => ShellRoute(
      builder: (context, state, child) => AppShell(child: child),
      routes: [
        // Dashboard
        GoRoute(
          path: AppRoutes.dashboardPath,
          name: AppRoutes.dashboard,
          pageBuilder: (context, state) => NoTransitionPage(
            name: AppRoutes.dashboard,
            child: DashboardScreen(),
          ),
        ),

        // Explore (Shorts)
        GoRoute(
          path: AppRoutes.explorePath,
          name: AppRoutes.explore,
          pageBuilder: (context, state) => const NoTransitionPage(
            name: AppRoutes.explore,
            child: ShortsScreen(),
          ),
        ),

        // Library
        GoRoute(
          path: AppRoutes.libraryPath,
          name: AppRoutes.library,
          pageBuilder: (context, state) => NoTransitionPage(
            name: AppRoutes.library,
            child: LibraryScreen(
              initialCollectionId:
                  int.tryParse(state.uri.queryParameters['collectionId'] ?? ''),
              initialTab: int.tryParse(state.uri.queryParameters['tab'] ?? ''),
            ),
          ),
        ),

        // More
        GoRoute(
          path: AppRoutes.morePath,
          name: AppRoutes.more,
          pageBuilder: (context, state) => const NoTransitionPage(
            name: AppRoutes.more,
            child: MoreScreen(),
          ),
        ),

        // Recents
        GoRoute(
          path: AppRoutes.recentsPath,
          name: AppRoutes.recents,
          pageBuilder: (context, state) => const NoTransitionPage(
            name: AppRoutes.recents,
            child: RecentScreen(),
          ),
        ),

        // Clips (with nested routes)
        GoRoute(
          path: AppRoutes.clipsPath,
          name: AppRoutes.clips,
          builder: (context, state) => const SizedBox.shrink(),
          routes: [
            GoRoute(
              path: AppRoutes.clipsCreatePath,
              name: AppRoutes.clipsCreate,
              builder: (context, state) => ClipEditorScreen(
                initialCollectionName: state.uri.queryParameters['collectionName'],
              ),
            ),
            GoRoute(
              path: AppRoutes.clipsEditPath,
              name: AppRoutes.clipsEdit,
              builder: (context, state) {
                final clipIdStr = state.uri.queryParameters['clipId'];
                final clipId = int.tryParse(clipIdStr ?? '');
                return ClipEditorScreen(clipId: clipId);
              },
            ),
            GoRoute(
              path: AppRoutes.clipsPlayPath,
              name: AppRoutes.clipsPlay,
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
