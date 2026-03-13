// ============================================================================
// lib/core/bootstrap.dart
// ============================================================================
//
// [역할]
// 앱 초기화 부트스트랩.
// Firebase, 환경변수, 오디오, 광고, 인증 서비스 등 초기화.
//
// [레이어]
// Core Layer
// ============================================================================

import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:provider/provider.dart';
import 'package:flutter/foundation.dart' show kReleaseMode;
import 'package:parrokit/core/config/firebase_options.dart';
import 'package:parrokit/data/local/prefs/intro_prefs.dart';
import 'package:parrokit/data/local/prefs/user_prefs.dart';
import 'package:parrokit/core/config/app_config.dart';
import 'package:parrokit/core/router/app_router.dart';
import 'package:parrokit/core/repositories/user_repository.dart';
import 'package:parrokit/core/services/firebase_auth_service.dart';
import 'package:parrokit/core/services/firebase_user_service.dart';
import 'package:parrokit/core/services/ad_service.dart';
import 'package:parrokit/core/utils/audio_bg.dart';
import 'package:parrokit/core/provider/theme_provider.dart';
import 'package:parrokit/core/provider/iap_provider.dart';
import 'package:parrokit/core/provider/user_provider.dart';
import 'package:parrokit/features/_content/shorts/presentation/providers/ad_provider.dart';
import 'package:parrokit/features/_content/shorts/data/shorts_ad_repository.dart';

import 'app.dart';
import 'di/providers.dart';

/// 앱 부트스트랩 - main()에서 호출.
///
/// 모든 초기화 완료 후 runApp() 실행.
Future<void> bootstrap() async {
  WidgetsFlutterBinding.ensureInitialized();

  // ─────────────────────────────────────────────────────────────────
  // 외부 서비스 초기화
  // ─────────────────────────────────────────────────────────────────
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  // ─────────────────────────────────────────────────────────────────
  // Crashlytics - Flutter 에러 및 비동기 에러 자동 수집
  // ─────────────────────────────────────────────────────────────────
  if (kReleaseMode) {
    FlutterError.onError = FirebaseCrashlytics.instance.recordFlutterFatalError;
    PlatformDispatcher.instance.onError = (error, stack) {
      FirebaseCrashlytics.instance.recordError(error, stack, fatal: true);
      return true;
    };
  }

  await dotenv.load(fileName: ".env");
  await BgAudio.instance.ensureAudioHandler();

  // ─────────────────────────────────────────────────────────────────
  // 앱 설정 로드
  // ─────────────────────────────────────────────────────────────────
  await AppConfig.loadFromPrefs();
  final themeProvider = ThemeProvider();
  await themeProvider.loadTheme();

  // ─────────────────────────────────────────────────────────────────
  // 인증 서비스 설정 (라우터보다 먼저 — refreshListenable에 필요)
  // ─────────────────────────────────────────────────────────────────
  final prefs = await SharedPreferences.getInstance();
  final userPrefs = UserPrefs(prefs);
  final authService = FirebaseAuthService();
  final userService = FirebaseUserService();
  final userRepository = UserRepository(userPrefs, authService, userService);
  final userProvider = UserProvider(userRepository);
  await userProvider.init();

  // ─────────────────────────────────────────────────────────────────
  // 라우터 설정
  // ─────────────────────────────────────────────────────────────────
  final seenIntro = await IntroPrefs.hasSeen();
  final router = buildAppRouter(seenIntro: seenIntro, userProvider: userProvider);

  // ─────────────────────────────────────────────────────────────────
  // 광고 SDK 초기화
  // ─────────────────────────────────────────────────────────────────
  await MobileAds.instance.initialize();
  AdService().loadAd();

  // ─────────────────────────────────────────────────────────────────
  // IAP 및 광고 Provider
  // ─────────────────────────────────────────────────────────────────
  final iapProvider = IapProvider();
  await iapProvider.init();
  final adRepository = ShortsAdRepository();
  final adProvider = AdProvider(
    repository: adRepository,
    initialPremium: iapProvider.isPremium,
  );

  // ─────────────────────────────────────────────────────────────────
  // 앱 실행
  // ─────────────────────────────────────────────────────────────────
  runApp(
    MultiProvider(
      providers: buildProviders(
        themeProvider: themeProvider,
        iapProvider: iapProvider,
        adProvider: adProvider,
        userProvider: userProvider,
      ),
      child: App(router: router),
    ),
  );
}
