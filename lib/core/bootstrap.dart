// lib/core/bootstrap.dart
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
import 'package:kakao_flutter_sdk/kakao_flutter_sdk.dart';
import 'package:parrokit/core/utils/has_internet.dart';
import 'package:parrokit/features/settings/no_internet/no_internet_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:provider/provider.dart';
import 'package:flutter/foundation.dart' show kDebugMode, kReleaseMode;
import 'package:parrokit/core/config/firebase_options.dart';
import 'package:parrokit/data/local/prefs/intro_prefs.dart';
import 'package:parrokit/data/local/prefs/user_prefs.dart';
import 'package:parrokit/core/config/app_config.dart';
import 'package:parrokit/core/router/app_router.dart';
import 'package:parrokit/core/repositories/user_repository.dart';
import 'package:parrokit/core/services/firebase/firebase_auth_service.dart';
import 'package:parrokit/core/services/firebase/firebase_user_service.dart';
import 'package:purchases_flutter/purchases_flutter.dart';
import 'package:parrokit/core/services/ad_service.dart';
import 'package:parrokit/core/utils/audio_bg.dart';
import 'package:parrokit/core/provider/theme_provider.dart';
import 'package:parrokit/core/provider/iap_provider.dart';
import 'package:parrokit/core/provider/user_provider.dart';
import 'package:parrokit/features/content/shorts/presentation/providers/ad_provider.dart';
import 'package:parrokit/features/content/shorts/data/shorts_ad_repository.dart';
import 'app.dart';
import 'di/providers.dart';

Future<void> bootstrap() async {
  WidgetsFlutterBinding.ensureInitialized();

  // 앱 설정 로드
  await _initAppConfig();
  final themeProvider = ThemeProvider();
  await themeProvider.loadTheme();

  // 인터넷 연결 확인
  _initInternet(themeProvider);

  // 외부 서비스 초기화
  await _initFirebase();

  // Crashlytics 분석
  _initCrashlytics();

  // 환경변수 설정
  await _initEnv();

  // 카카오 SDK 초기화
  await _initKakao();

  // 오디오 설정
  await _initAudio();

  // 인증 서비스 설정
  final userProvider = await _initUserProvider();

  // 라우터 설정
  final seenIntro = await IntroPrefs.hasSeen();
  final router =
      buildAppRouter(seenIntro: seenIntro, userProvider: userProvider);

  // 광고 SDK 초기화
  await _initAds();

  // RevenueCat 초기화
  await _initRevenueCat(userProvider);

  // IAP 및 광고 Provider
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

  // 앱 실행
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

Future<void> _initInternet(ThemeProvider themeProvider) async {
  if (!await hasInternet()) {
    runApp(
      ChangeNotifierProvider.value(
        value: themeProvider,
        child: const NoInternetScreen(),
      ),
    );
    return;
  }
}

// 초기화 세부 함수
Future<void> _initAppConfig() async {
  try {
    await AppConfig.loadFromPrefs();
  } catch (e) {
    debugPrint('AppConfig load failed: $e');
  }
}

Future<void> _initFirebase() async {
  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    ).timeout(const Duration(seconds: 8));
  } catch (e) {
    debugPrint('Firebase init failed: $e');
  }
}

void _initCrashlytics() {
  try {
    if (kReleaseMode) {
      FlutterError.onError =
          FirebaseCrashlytics.instance.recordFlutterFatalError;
      PlatformDispatcher.instance.onError = (error, stack) {
        FirebaseCrashlytics.instance.recordError(error, stack, fatal: true);
        return true;
      };
    }
  } catch (e) {
    debugPrint('Crashlytics init failed: $e');
  }
}

Future<void> _initEnv() async {
  try {
    await dotenv.load(fileName: ".env");
  } catch (e) {
    debugPrint('Env load failed: $e');
  }
}

Future<void> _initKakao() async {
  try {
    final nativeAppKey = dotenv.env['KAKAO_NATIVE_APP_KEY'];
    final javaScriptAppKey = dotenv.env['KAKAO_JAVASCRIPT_APP_KEY'];

    if (nativeAppKey != null && nativeAppKey.isNotEmpty) {
      KakaoSdk.init(
        nativeAppKey: nativeAppKey,
        javaScriptAppKey: javaScriptAppKey,
      );
    } else {
      debugPrint('Kakao init failed: KAKAO_NATIVE_APP_KEY is missing in .env');
    }
  } catch (e) {
    debugPrint('Kakao init failed: $e');
  }
}

Future<void> _initAudio() async {
  try {
    await BgAudio.instance.ensureAudioHandler();
  } catch (e) {
    debugPrint('Audio init failed: $e');
  }
}

Future<UserProvider> _initUserProvider() async {
  try {
    final prefs = await SharedPreferences.getInstance();
    final userProvider = UserProvider(
      UserRepository(
        UserPrefs(prefs),
        FirebaseAuthService(),
        FirebaseUserService(),
      ),
    );
    await userProvider.init();
    return userProvider;
  } catch (e) {
    debugPrint('UserProvider init failed: $e');
    // 실패 시 빈 저장소를 가진 기본 객체라도 반환하여 앱 중단 방지
    return UserProvider(
      UserRepository(
        UserPrefs(null as dynamic),
        FirebaseAuthService(),
        FirebaseUserService(),
      ),
    );
  }
}

Future<void> _initAds() async {
  try {
    // 광고 SDK 초기화
    await MobileAds.instance.initialize();

    // 테스트 기기 ID 등록
    RequestConfiguration configuration = RequestConfiguration(
      testDeviceIds: [
        "49CD5924-A2F7-4DD9-9FD2-5545ACD55D6B", // iPhone 16 Pro
        "9DBB0D7B-2CDF-440E-A886-134E853705BB", // Samsung SM-A217N
        "B298412BB206519738CFD5AEFB066264", // Samsung SM-A217N 2
      ],
    );

    // 설정 적용
    await MobileAds.instance.updateRequestConfiguration(configuration);

    // 광고 로드
    AdService().loadAd();

    debugPrint("✅ Parrokit: 모든 테스트 기기 설정 완료 및 광고 로드 시작");
  } catch (e) {
    debugPrint('❌ Ads init failed: $e');
  }
}

Future<void> _initRevenueCat(UserProvider userProvider) async {
  try {
    String? apiKey;
    if (kDebugMode) {
      apiKey = dotenv.env['REVENUECAT_TEST_API_KEY'];
    } else {
      apiKey = Platform.isAndroid
          ? dotenv.env['REVENUECAT_ANDROID_API_KEY']
          : dotenv.env['REVENUECAT_APPLE_API_KEY'];
    }

    if (apiKey != null && apiKey.isNotEmpty) {
      await Purchases.configure(PurchasesConfiguration(apiKey));
      if (userProvider.isLoggedIn && userProvider.currentUser != null) {
        await Purchases.logIn(userProvider.currentUser!.id);
      }
    }
  } catch (e) {
    debugPrint('RevenueCat init failed: $e');
  }
}
