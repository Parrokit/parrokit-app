// ============================================================================
// lib/core/app.dart
// ============================================================================
//
// [역할]
// 앱 루트 위젯.
// MaterialApp 설정 및 테마/라우터 구성.
//
// [레이어]
// Core Layer
// ============================================================================

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:parrokit/core/provider/theme_provider.dart';
import 'package:parrokit/core/theme/app_theme.dart';

/// 앱 루트 위젯.
///
/// MaterialApp.router를 사용하여 GoRouter 기반 라우팅.
/// 테마는 ThemeProvider로 관리.
class App extends StatelessWidget {
  const App({super.key, required this.router});

  final GoRouter router;

  @override
  Widget build(BuildContext context) {
    final theme = context.watch<ThemeProvider>();

    return MaterialApp.router(
      title: 'Parrokit',
      theme: AppTheme.light,
      darkTheme: AppTheme.dark,
      themeMode: theme.themeMode,
      routerConfig: router,
      debugShowCheckedModeBanner: false,
    );
  }
}
