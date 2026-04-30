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
import 'package:parrokit/features/auth/sign-in/sign_in_screen.dart';
import 'package:parrokit/features/auth/sign-up/sign_up_screen.dart';
import 'package:parrokit/features/auth/find-pw/find_pw_screen.dart';
import 'package:parrokit/features/dashboard/presentation/dashboard_screen.dart';
import 'package:parrokit/features/community/presentation/community_screen.dart';
import 'package:parrokit/features/community/presentation/board_view_screen.dart';
import 'package:parrokit/features/community/presentation/board_write_screen.dart';
import 'package:parrokit/features/community/presentation/community_menu_screen.dart';
import 'package:parrokit/features/content/shorts/presentation/shorts_screen.dart';
import 'package:parrokit/features/content/library/presentation/library_screen.dart';
import 'package:parrokit/features/settings/more/presentation/more_screen.dart';
import 'package:parrokit/features/discovery/recent/presentation/recent_screen.dart';
import 'package:parrokit/features/content/clip-editor/presentation/clip_editor_screen.dart';
import 'package:parrokit/features/content/player/presentation/clip_player_screen.dart';

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
    initialLocation: AppRoutes.dashboardPath,
    redirect: _handleRedirect,
    refreshListenable: userProvider,
    routes: [
      // ─────────────────────────────────────────────────────────────────
      // 단독 라우트 (쉘 외부)
      // ─────────────────────────────────────────────────────────────────
      _authRoute,
      GoRoute(
        path: AppRoutes.communityBoardWritePath,
        name: AppRoutes.communityBoardWrite,
        builder: (context, state) => const BoardWriteScreen(),
      ),
      GoRoute(
        path: AppRoutes.communityMenuPath,
        name: AppRoutes.communityMenu,
        builder: (context, state) => const CommunityMenuScreen(),
      ),
      GoRoute(
        path: AppRoutes.communityBoardViewPath,
        name: AppRoutes.communityBoardView,
        builder: (context, state) {
          final postId = int.tryParse(state.pathParameters['postId'] ?? '');
          if (postId == null) {
            return const Scaffold(
              body: Center(
                child: Text('postId가 필요합니다. (/community/board/:postId)'),
              ),
            );
          }
          return BoardViewScreen(postId: postId);
        },
      ),

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

  // 2) Auth guard
  final user = Provider.of<UserProvider>(context, listen: false);
  final isOnAuth = loc.startsWith(AppRoutes.authPath);
  final isOnIntro = loc.startsWith(AppRoutes.introPath);

  if (!user.isLoggedIn && !isOnAuth && !isOnIntro) {
    return '${AppRoutes.authPath}/${AppRoutes.signInPath}';
  }

  if (user.isLoggedIn && isOnAuth) {
    return AppRoutes.dashboardPath;
  }

  // Handle bare /auth redirect to /auth/sign-in
  if (loc == AppRoutes.authPath) {
    return '${AppRoutes.authPath}/${AppRoutes.signInPath}';
  }

  return null;
}

// ─────────────────────────────────────────────────────────────────────────────
// Route Definitions
// ─────────────────────────────────────────────────────────────────────────────

GoRoute get _authRoute => GoRoute(
      path: AppRoutes.authPath,
      name: AppRoutes.auth,
      redirect: (context, state) {
        if (state.uri.toString() == AppRoutes.authPath) {
          return '${AppRoutes.authPath}/${AppRoutes.signInPath}';
        }
        return null;
      },
      routes: [
        GoRoute(
          path: AppRoutes.signInPath,
          name: AppRoutes.signIn,
          pageBuilder: (context, state) => NoTransitionPage(
            name: AppRoutes.signIn,
            child: const SignInScreen(),
          ),
        ),
        GoRoute(
          path: AppRoutes.signUpPath,
          name: AppRoutes.signUp,
          pageBuilder: (context, state) => NoTransitionPage(
            name: AppRoutes.signUp,
            child: const SignUpScreen(),
          ),
        ),
        GoRoute(
          path: AppRoutes.findPwPath,
          name: AppRoutes.findPw,
          pageBuilder: (context, state) => NoTransitionPage(
            name: AppRoutes.findPw,
            child: const FindPwScreen(),
          ),
        ),
      ],
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

        // Community
        GoRoute(
          path: AppRoutes.communityPath,
          name: AppRoutes.community,
          pageBuilder: (context, state) => const NoTransitionPage(
            name: AppRoutes.community,
            child: CommunityScreen(),
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
                initialCollectionName:
                    state.uri.queryParameters['collectionName'],
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
