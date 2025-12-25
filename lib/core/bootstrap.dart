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

import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:provider/provider.dart';

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
import 'package:parrokit/core/provider/ad_provider.dart';

import 'app.dart';
import 'di/providers.dart';

/// 앱 부트스트랩 - main()에서 호출.
///
/// 모든 초기화 완료 후 runApp() 실행.
Future<void> bootstrap() async {
  WidgetsFlutterBinding.ensureInitialized();

  // ─────────────────────────────────────────────────────────────────
  // 1. 외부 서비스 초기화
  // ─────────────────────────────────────────────────────────────────
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  await dotenv.load(fileName: ".env");
  await BgAudio.instance.ensureAudioHandler();

  // ─────────────────────────────────────────────────────────────────
  // 2. 앱 설정 로드
  // ─────────────────────────────────────────────────────────────────
  await AppConfig.loadFromPrefs();
  final themeProvider = ThemeProvider();
  await themeProvider.loadTheme();

  // ─────────────────────────────────────────────────────────────────
  // 3. 라우터 설정
  // ─────────────────────────────────────────────────────────────────
  final seenIntro = await IntroPrefs.hasSeen();
  final router = buildAppRouter(seenIntro: seenIntro);

  // ─────────────────────────────────────────────────────────────────
  // 4. 광고 SDK 초기화
  // ─────────────────────────────────────────────────────────────────
  await MobileAds.instance.initialize();
  AdService().loadAd();

  // ─────────────────────────────────────────────────────────────────
  // 5. 인증 서비스 설정
  // ─────────────────────────────────────────────────────────────────
  final prefs = await SharedPreferences.getInstance();
  final userPrefs = UserPrefs(prefs);
  final authService = FirebaseAuthService();
  final userService = FirebaseUserService();
  final userRepository = UserRepository(userPrefs, authService, userService);

  // ─────────────────────────────────────────────────────────────────
  // 6. IAP 및 광고 Provider
  // ─────────────────────────────────────────────────────────────────
  final iapProvider = IapProvider();
  await iapProvider.init();
  final adProvider = AdProvider(initialPremium: iapProvider.isPremium);

  // ─────────────────────────────────────────────────────────────────
  // 7. 앱 실행
  // ─────────────────────────────────────────────────────────────────
  runApp(
    MultiProvider(
      providers: buildProviders(
        themeProvider: themeProvider,
        iapProvider: iapProvider,
        adProvider: adProvider,
        userRepository: userRepository,
      ),
      child: App(router: router),
    ),
  );
}
