// lib/core/bootstrap/bootstrap.dart
//
// [역할]
// 앱 초기화 부트스트랩 오케스트레이션.
//
// [레이어]
// Core Layer
// ============================================================================

import 'package:flutter/material.dart';
import 'package:parrokit/core/app.dart';
import 'package:parrokit/core/bootstrap/bootstrap_dependencies.dart';
import 'package:parrokit/core/bootstrap/bootstrap_steps.dart';
import 'package:parrokit/core/di/providers.dart';
import 'package:parrokit/core/services/firebase/firebase_messaging_service.dart';
import 'package:parrokit/core/router/app_router.dart';
import 'package:parrokit/core/utils/app_logger.dart';
import 'package:parrokit/data/local/prefs/intro_prefs.dart';
import 'package:provider/provider.dart';

// 앱 시작 초기화 순서를 오케스트레이션한다.
Future<void> bootstrap() async {
  WidgetsFlutterBinding.ensureInitialized();
  AppLogger.i('[Bootstrap][Start] app initialization');

  await initAppConfig();

  final themeProvider = await createThemeProvider();
  await ensureInternetOrShowOffline(themeProvider);

  await initFirebase();
  FirebaseMessagingService.registerBackgroundHandler();
  initCrashlytics();
  await initEnv();
  await initKakao();
  await initAudio();

  final userProvider = await createUserProvider();

  final seenIntro = await IntroPrefs.hasSeen();
  final router = buildAppRouter(seenIntro: seenIntro, userProvider: userProvider);

  await initAds();
  await initRevenueCat(userProvider);

  final iapProvider = await createIapProvider();
  final adProvider = createAdProvider(iapProvider: iapProvider);
  bindPremiumSync(iapProvider: iapProvider, adProvider: adProvider);

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

  AppLogger.i('[Bootstrap][Done] app started');
}
