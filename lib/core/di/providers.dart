// ============================================================================
// lib/core/di/providers.dart
// ============================================================================
//
// [역할]
// 앱 전역 Provider 목록 정의.
// MultiProvider에서 사용할 Provider 리스트 생성.
//
// [레이어]
// Core Layer > DI
// ============================================================================

import 'package:provider/provider.dart';
import 'package:provider/single_child_widget.dart';

import 'package:parrokit/data/local/app_database.dart';
import 'package:parrokit/core/repositories/user_repository.dart';
import 'package:parrokit/core/provider/theme_provider.dart';
import 'package:parrokit/core/provider/iap_provider.dart';
import 'package:parrokit/core/provider/ad_provider.dart';
import 'package:parrokit/core/provider/user_provider.dart';
import 'package:parrokit/core/provider/clip_activity_provider.dart';
import 'package:parrokit/core/provider/media_provider.dart';
import 'package:parrokit/core/provider/shorts_provider.dart';
import 'package:parrokit/core/provider/tag_filter_provider.dart';

/// Provider 목록 생성.
///
/// 초기화된 Provider들을 받아서 전체 Provider 리스트 반환.
List<SingleChildWidget> buildProviders({
  required ThemeProvider themeProvider,
  required IapProvider iapProvider,
  required AdProvider adProvider,
  required UserRepository userRepository,
}) {
  return [
    // ─────────────────────────────────────────────────────────────────
    // 이미 초기화된 Provider들 (Value)
    // ─────────────────────────────────────────────────────────────────
    ChangeNotifierProvider<ThemeProvider>.value(value: themeProvider),
    ChangeNotifierProvider<IapProvider>.value(value: iapProvider),
    ChangeNotifierProvider<AdProvider>.value(value: adProvider),

    // ─────────────────────────────────────────────────────────────────
    // 데이터베이스
    // ─────────────────────────────────────────────────────────────────
    Provider<AppDatabase>(
      create: (_) => AppDatabase(),
      dispose: (_, db) => db.close(),
    ),

    // ─────────────────────────────────────────────────────────────────
    // 사용자 관련
    // ─────────────────────────────────────────────────────────────────
    ChangeNotifierProvider(
      create: (_) => UserProvider(userRepository)..init(),
    ),

    // ─────────────────────────────────────────────────────────────────
    // 기능별 Provider들
    // ─────────────────────────────────────────────────────────────────
    ChangeNotifierProvider<ClipActivityProvider>(
      lazy: false,
      create: (c) => ClipActivityProvider(c.read<AppDatabase>()),
    ),
    ChangeNotifierProvider<MediaProvider>(
      create: (c) => MediaProvider(c.read<AppDatabase>()),
    ),
    ChangeNotifierProvider<ShortsProvider>(
      create: (c) => ShortsProvider(c.read<AppDatabase>()),
    ),
    ChangeNotifierProvider<TagFilterProvider>(
      create: (c) => TagFilterProvider(c.read<AppDatabase>()),
    ),
  ];
}
