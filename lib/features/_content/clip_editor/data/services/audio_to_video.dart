// ============================================================================
// lib/features/_content/editor/data/services/audio_to_video.dart
// ============================================================================
//
// [역할]
// 오디오 파일을 비디오(mp4)로 변환하는 서비스.
// FFmpeg 기반 구현. 검은 화면에 오디오 트랙 합성.
//
// [레이어]
// Data Layer > Services
// ============================================================================

import 'package:ffmpeg_kit_flutter_new_video/ffmpeg_kit.dart';
import 'package:ffmpeg_kit_flutter_new_video/ffprobe_kit.dart';
import 'package:ffmpeg_kit_flutter_new_video/return_code.dart';
import 'dart:io';
import 'package:path/path.dart' as p;

import 'package:parrokit/core/utils/app_logger.dart';

abstract class AudioToVideoService {
  /// mp3 → mp4 변환하고 mp4 경로를 반환
  Future<String> convertToMp4(String mp3Path);

  /// mp3면 변환하고, mp4면 그대로 반환 (정규화)
  Future<String> ensureMp4(String path);
}

/// ffmpeg 기반 mp3 → mp4 변환 서비스 구현
class FfmpegAudioToVideoService implements AudioToVideoService {
  /// mp3 -> mp4 변환
  ///
  /// - input: mp3 파일 경로
  /// - output: 같은 디렉토리에 `<원래이름>_a2v.mp4` 생성 후 그 경로 반환
  @override
  Future<String> convertToMp4(String mp3Path) async {
    final inputFile = File(mp3Path);
    if (!await inputFile.exists()) {
      throw Exception('입력 mp3 파일이 존재하지 않습니다: $mp3Path');
    }

    final dir = inputFile.parent.path;
    final baseName = p.basenameWithoutExtension(mp3Path);
    final outputPath = p.join(dir, '${baseName}_a2v.mp4');

    // 이미 동일 이름의 mp4가 있다면 먼저 삭제 (원하면 덮어쓰기 옵션만으로도 가능)
    final outputFile = File(outputPath);
    if (await outputFile.exists()) {
      await outputFile.delete();
    }

    // 1. 오디오 길이 측정 (ffprobe)
    String? durationStr;
    try {
      final mediaInfoSession = await FFprobeKit.getMediaInformation(mp3Path);
      final mediaInfo = mediaInfoSession.getMediaInformation();
      final d = mediaInfo?.getDuration();
      if (d != null && double.tryParse(d) != null) {
        durationStr = d;
      }
    } catch (e) {
      AppLogger.w(
          'AudioToVideo: Duration probe failed. Fallback to -shortest. $e');
    }

    // ffmpeg 명령:
    // - 검은 화면(1280x720)을 비디오 트랙으로 생성
    // - 오디오(mp3)를 함께 mux해서 mp4 컨테이너로 출력
    //
    // -t <duration>: 오디오 길이만큼만 영상 생성 (가장 정확)
    // -shortest: 혹시 모를 오차 대비 안전장치
    final cmd = [
      '-y', // 기존 파일 덮어쓰기
      '-i', _wrapPath(mp3Path),
      '-f',
      'lavfi',
      '-i',
      'color=c=black:s=1280x720',
      if (durationStr != null) ...['-t', durationStr],
      '-shortest',
      '-c:a',
      'aac',
      _wrapPath(outputPath),
    ].join(' ');

    final session = await FFmpegKit.execute(cmd);
    final returnCode = await session.getReturnCode();

    if (!ReturnCode.isSuccess(returnCode)) {
      final logs = await session.getAllLogs();
      final logText = logs.map((l) => l.getMessage()).join('\n');
      throw Exception(
        'mp3 -> mp4 변환 실패 (code: $returnCode)\n$logText',
      );
    }

    return outputPath;
  }

  /// path가 mp3면 mp4로 변환하고, 그 외에는 그대로 반환하는 정규화 함수
  @override
  Future<String> ensureMp4(String path) async {
    final ext = p.extension(path).toLowerCase();

    if (ext == '.mp4') {
      // 이미 mp4면 그대로 사용
      return path;
    }

    const audioExtensions = {
      '.mp3',
      '.m4a',
      '.aac',
      '.wav',
      '.flac',
      '.ogg',
    };

    if (audioExtensions.contains(ext)) {
      return await convertToMp4(path);
    }

    // 그 외 확장자는 일단 그대로 통과시키고,
    // 나중에 필요하면 여기서 throw하도록 바꿔도 됨.
    return path;
  }

  /// 공백/특수문자 경로를 위해 ffmpeg 인자에서 쓸 수 있게 래핑
  String _wrapPath(String path) {
    // 단순하게 큰따옴표로 감싸기
    return '"$path"';
  }
}
