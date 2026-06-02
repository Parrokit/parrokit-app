import 'package:parrokit/core/utils/app_logger.dart';
import 'package:parrokit/core/utils/audio_bg.dart';

// 백그라운드 오디오 핸들러를 초기화한다.
Future<void> initAudio() async {
  try {
    AppLogger.i('[Bootstrap][Audio] start');
    await BgAudio.instance.ensureAudioHandler();
    AppLogger.i('[Bootstrap][Audio] success');
  } catch (e) {
    AppLogger.e('[Bootstrap][Audio] failed', error: e);
  }
}
