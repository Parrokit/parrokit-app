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

import 'dart:io';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:provider/provider.dart';
import 'package:flutter/foundation.dart' show kDebugMode, kReleaseMode;
import 'package:parrokit/core/config/firebase_options.dart';
import 'package:parrokit/data/local/prefs/intro_prefs.dart';
import 'package:parrokit/data/local/prefs/user_prefs.dart';
import 'package:parrokit/core/config/app_config.dart';
import 'package:parrokit/core/router/app_router.dart';
import 'package:parrokit/core/repositories/user_repository.dart';
import 'package:parrokit/core/services/firebase_auth_service.dart';
import 'package:parrokit/core/services/firebase_user_service.dart';
import 'package:purchases_flutter/purchases_flutter.dart';
import 'package:parrokit/core/services/ad_service.dart';
import 'package:parrokit/core/utils/audio_bg.dart';
import 'package:parrokit/core/provider/theme_provider.dart';
import 'package:parrokit/core/provider/iap_provider.dart';
import 'package:parrokit/core/provider/user_provider.dart';
import 'package:parrokit/features/_content/shorts/presentation/providers/ad_provider.dart';
import 'package:parrokit/features/_content/shorts/data/shorts_ad_repository.dart';

import 'app.dart';
import 'di/providers.dart';

/// 인터넷 연결 여부 확인 (DNS 조회 방식, 추가 패키지 불필요).
Future<bool> _hasInternet() async {
  try {
    final result = await InternetAddress.lookup('google.com')
        .timeout(const Duration(seconds: 3));
    return result.isNotEmpty && result[0].rawAddress.isNotEmpty;
  } catch (_) {
    return false;
  }
}

/// 인터넷 없을 때 띄우는 최소 앱.
class _NoInternetApp extends StatelessWidget {
  const _NoInternetApp();

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Builder(
        builder: (context) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            showDialog<void>(
              context: context,
              barrierDismissible: false,
              builder: (_) => AlertDialog(
                title: const Text('인터넷 연결 필요'),
                content: const Text('앱을 사용하려면 인터넷에 연결해 주세요.'),
                actions: [
                  TextButton(
                    onPressed: () => exit(0),
                    child: const Text('확인'),
                  ),
                ],
              ),
            );
          });
          return const Scaffold();
        },
      ),
    );
  }
}

/// 앱 부트스트랩 - main()에서 호출.
///
/// 모든 초기화 완료 후 runApp() 실행.
Future<void> bootstrap() async {
  WidgetsFlutterBinding.ensureInitialized();
  // ─────────────────────────────────────────────────────────────────
  // 앱 설정 로드
  // ─────────────────────────────────────────────────────────────────
  await AppConfig.loadFromPrefs();
  final themeProvider = ThemeProvider();
  await themeProvider.loadTheme();

  // ─────────────────────────────────────────────────────────────────
  // 인터넷 연결 확인
  // ─────────────────────────────────────────────────────────────────
  if (!await _hasInternet()) {
    runApp(const _NoInternetApp());
    return;
  }

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
  final router =
      buildAppRouter(seenIntro: seenIntro, userProvider: userProvider);

  // ─────────────────────────────────────────────────────────────────
  // 광고 SDK 초기화
  // ─────────────────────────────────────────────────────────────────
  await MobileAds.instance.initialize();
  AdService().loadAd();

  // ─────────────────────────────────────────────────────────────────
  // RevenueCat 초기화
  // ─────────────────────────────────────────────────────────────────

  // 예시 코드
  if (kDebugMode) {
    await Purchases.configure(
      PurchasesConfiguration(dotenv.env['REVENUECAT_TEST_API_KEY']!),
    );
    if (userProvider.isLoggedIn && userProvider.currentUser != null) {
      await Purchases.logIn(userProvider.currentUser!.id);
    }
  } else {
    if (Platform.isAndroid) {
      await Purchases.configure(
        PurchasesConfiguration(dotenv.env['REVENUECAT_ANDROID_API_KEY']!),
      );
      if (userProvider.isLoggedIn && userProvider.currentUser != null) {
        await Purchases.logIn(userProvider.currentUser!.id);
      }
    } else if (Platform.isIOS) {
      await Purchases.configure(
        PurchasesConfiguration(dotenv.env['REVENUECAT_APPLE_API_KEY']!),
      );
      if (userProvider.isLoggedIn && userProvider.currentUser != null) {
        await Purchases.logIn(userProvider.currentUser!.id);
      }
    }
  }

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
  // IapProvider 변경 시 AdProvider에 즉시 반영
  iapProvider.addListener(() {
    adProvider.premium = iapProvider.isPremium;
  });
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
