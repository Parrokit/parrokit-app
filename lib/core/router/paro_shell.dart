// ============================================================================
// lib/core/router/paro_shell.dart
// ============================================================================
//
// [역할]
// 앱 메인 쉘 위젯.
// 바텀 네비게이션 바를 포함한 레이아웃 쉘.
// 특정 경로에서는 네비바 숨김.
//
// [레이어]
// Core Layer > Router
// ============================================================================

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:parrokit/core/navigation/paro_bottom_navbar.dart';
import 'pa_routes.dart';

/// 앱 메인 쉘 위젯.
///
/// 바텀 네비게이션 바를 포함한 레이아웃.
/// 특정 경로(`/clips/...`, `/recents`)에서는 네비바 숨김.
class ParoShell extends StatelessWidget {
  const ParoShell({super.key, required this.child});

  final Widget child;

  /// 현재 경로에서 탭 인덱스 계산
  int _indexFromLocation(String location) {
    if (location.startsWith(PaRoutes.explorePath)) return 1;
    if (location.startsWith(PaRoutes.libraryPath)) return 2;
    if (location.startsWith(PaRoutes.recomPath)) return 3;
    if (location.startsWith(PaRoutes.morePath)) return 4;
    return 0; // dashboard
  }

  @override
  Widget build(BuildContext context) {
    final location = GoRouterState.of(context).uri.toString();
    final currentIndex = _indexFromLocation(location);

    // 네비바 숨김 조건
    final hideNav =
        location.startsWith('/clips/') || location == PaRoutes.recentsPath;

    return Scaffold(
      body: child,
      bottomNavigationBar: hideNav
          ? null
          : ParoBottomNavBar(
              currentIndex: currentIndex,
              onTap: (i) => _onTabTap(context, i),
            ),
    );
  }

  /// 탭 선택 시 네비게이션
  void _onTabTap(BuildContext context, int index) {
    switch (index) {
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
  }
}
