import 'dart:io';

import 'package:flutter/foundation.dart' show kDebugMode;
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:parrokit/core/provider/user_provider.dart';
import 'package:parrokit/core/utils/app_logger.dart';
import 'package:purchases_flutter/purchases_flutter.dart';

// RevenueCat을 초기화하고 로그인 상태를 동기화한다.
Future<void> initRevenueCat(UserProvider userProvider) async {
  try {
    AppLogger.i('[Bootstrap][RevenueCat] start');
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
      AppLogger.i('[Bootstrap][RevenueCat] success');
    } else {
      AppLogger.w('[Bootstrap][RevenueCat] api key missing');
    }
  } catch (e) {
    AppLogger.e('[Bootstrap][RevenueCat] failed', error: e);
  }
}
