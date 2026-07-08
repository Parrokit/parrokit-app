// ============================================================================
// lib/core/router/app_shell.dart
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
import 'package:parrokit/core/app/navigation/app_bottom_navbar.dart';
import 'package:parrokit/core/app/router/app_routes.dart';
import 'package:parrokit/core/state/provider/clip_provider.dart';
import 'package:provider/provider.dart';

/// 앱 메인 쉘 위젯.
///
/// 바텀 네비게이션 바를 포함한 레이아웃.
/// 특정 경로(`/clips/...`, `/recents`)에서는 네비바 숨김.
class AppShell extends StatelessWidget {
  const AppShell({super.key, required this.child});

  final Widget child;

  /// 현재 경로에서 탭 인덱스 계산
  int _indexFromLocation(String location) {
    if (location.startsWith(AppRoutes.communityPath)) return 1;
    if (location.startsWith(AppRoutes.explorePath)) return 2;
    if (location.startsWith(AppRoutes.collectionPath)) return 3;
    if (location.startsWith(AppRoutes.morePath)) return 4;
    return 0; // dashboard
  }

  @override
  Widget build(BuildContext context) {
    final location = GoRouterState.of(context).uri.toString();
    final currentIndex = _indexFromLocation(location);
    final clipProvider = context.watch<ClipProvider>();

    // 네비바 숨김 조건
    final hideNav = location.startsWith('/clips/') ||
        location == AppRoutes.recentsPath ||
        location == AppRoutes.contentStudioBridgePath ||
        location.startsWith('${AppRoutes.contentStudioBridgePath}/');
    final isCollectionRoute = location.startsWith(AppRoutes.collectionPath);
    final showCollectionSelectionBar = isCollectionRoute &&
        clipProvider.isCollectionMenuOpen &&
        clipProvider.selectedCollectionId != null;

    return Scaffold(
      body: child,
      bottomNavigationBar: hideNav
          ? null
          : showCollectionSelectionBar
              ? _buildCollectionSelectionBar(context)
              : AppBottomNavBar(
                  currentIndex: currentIndex,
                  onTap: (i) => _onTabTap(context, i),
                ),
    );
  }

  Widget _buildCollectionSelectionBar(BuildContext context) {
    final clipProvider = context.read<ClipProvider>();
    final colorScheme = Theme.of(context).colorScheme;

    return SafeArea(
      top: false,
      child: Container(
        margin: const EdgeInsets.fromLTRB(12, 0, 12, 10),
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
        decoration: BoxDecoration(
          color: colorScheme.surface,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
              color: colorScheme.outlineVariant.withValues(alpha: 0.35)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.08),
              blurRadius: 18,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            IconButton(
              tooltip: '검색',
              icon: const Icon(Icons.search_rounded),
              onPressed: () {},
            ),
            IconButton(
              tooltip: 'Google Drive',
              icon: const Icon(Icons.cloud_upload_rounded),
              onPressed: clipProvider.selectedCollectionId == null
                  ? null
                  : () async {
                      final provider = context.read<ClipProvider>();
                      if (provider.hasGoogleDriveLinked) {
                        final confirmed = await showDialog<bool>(
                          context: context,
                          builder: (dialogContext) => AlertDialog(
                            title: const Text('Google Drive 연동 해제'),
                            content: const Text(
                              '연동을 해제하면 Google Drive에 있던 파일들을 모두 기기로 옮긴 뒤, 계정을 분리합니다.',
                            ),
                            actions: [
                              TextButton(
                                onPressed: () =>
                                    Navigator.pop(dialogContext, false),
                                child: const Text('취소'),
                              ),
                              FilledButton(
                                onPressed: () =>
                                    Navigator.pop(dialogContext, true),
                                child: const Text('연동 해제'),
                              ),
                            ],
                          ),
                        );
                        if (confirmed != true) return;
                        await provider.disconnectGoogleDrive();
                      } else {
                        await provider.connectGoogleDrive();
                      }
                    },
            ),
            IconButton(
              tooltip: '저장공간',
              icon: const Icon(Icons.storage_rounded),
              onPressed: () {
                context.pushNamed(AppRoutes.storageCacheManagement);
              },
            ),
            IconButton(
              tooltip: '닫기',
              icon: const Icon(Icons.close_rounded),
              onPressed: clipProvider.closeCollectionMenu,
            ),
          ],
        ),
      ),
    );
  }

  /// 탭 선택 시 네비게이션
  void _onTabTap(BuildContext context, int index) {
    switch (index) {
      case 0:
        context.go(AppRoutes.dashboardPath);
        break;
      case 1:
        context.go(AppRoutes.communityPath);
        break;
      case 2:
        context.go(AppRoutes.explorePath);
        break;
      case 3:
        context.go(AppRoutes.collectionPath);
        break;
      case 4:
        context.go(AppRoutes.morePath);
        break;
    }
  }
}
