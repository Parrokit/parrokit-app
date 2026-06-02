import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:parrokit/core/utils/app_logger.dart';

// 환경변수 파일을 로드한다.
Future<void> initEnv() async {
  try {
    AppLogger.i('[Bootstrap][Env] start');
    await dotenv.load(fileName: '.env');
    AppLogger.i('[Bootstrap][Env] success');
  } catch (e) {
    AppLogger.e('[Bootstrap][Env] failed', error: e);
  }
}
