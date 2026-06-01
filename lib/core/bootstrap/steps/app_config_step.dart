import 'package:parrokit/core/config/app_config.dart';
import 'package:parrokit/core/utils/app_logger.dart';

// 앱 설정을 로드해 런타임 구성값을 준비한다.
Future<void> initAppConfig() async {
  try {
    AppLogger.i('[Bootstrap][AppConfig] start');
    await AppConfig.loadFromPrefs();
    AppLogger.i('[Bootstrap][AppConfig] success');
  } catch (e) {
    AppLogger.e('[Bootstrap][AppConfig] failed', error: e);
  }
}
