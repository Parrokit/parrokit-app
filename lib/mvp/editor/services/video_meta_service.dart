import 'dart:io';
import 'dart:typed_data';

import 'package:video_player/video_player.dart';
import 'package:video_thumbnail/video_thumbnail.dart';

/// 썸네일/길이 추출 서비스
abstract class VideoMetaService {
  Future<Uint8List?> thumbnail(String path);
  Future<int?> durationMs(String path);
}

class VideoMetaServiceImpl implements VideoMetaService {
  @override
  Future<Uint8List?> thumbnail(String path) async {
    try {
      return await VideoThumbnail.thumbnailData(
        video: path,
        imageFormat: ImageFormat.PNG,
        maxWidth: 256,
        quality: 75,
        timeMs: 0,
      );
    } catch (_) {
      return null;
    }
  }

  @override
  Future<int?> durationMs(String path) async {
    try {
      final c = VideoPlayerController.file(File(path));
      await c.initialize();
      final ms = c.value.duration.inMilliseconds;
      await c.dispose();
      return ms;
    } catch (_) {
      return null;
    }
  }
}
