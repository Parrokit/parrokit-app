import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:kakao_flutter_sdk/kakao_flutter_sdk.dart';
import 'package:parrokit/core/utils/app_logger.dart';

// 카카오 SDK 키를 읽어 SDK를 초기화한다.
Future<void> initKakao() async {
  try {
    AppLogger.i('[Bootstrap][Kakao] start');
    final nativeAppKey = dotenv.env['KAKAO_NATIVE_APP_KEY'];
    final javaScriptAppKey = dotenv.env['KAKAO_JAVASCRIPT_APP_KEY'];

    if (nativeAppKey != null && nativeAppKey.isNotEmpty) {
      KakaoSdk.init(
        nativeAppKey: nativeAppKey,
        javaScriptAppKey: javaScriptAppKey,
      );
      AppLogger.i('[Bootstrap][Kakao] success');
    } else {
      AppLogger.w('[Bootstrap][Kakao] missing key: KAKAO_NATIVE_APP_KEY');
    }
  } catch (e) {
    AppLogger.e('[Bootstrap][Kakao] failed', error: e);
  }
}
