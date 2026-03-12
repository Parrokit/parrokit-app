// ============================================================================
// lib/features/_content/clip_editor/data/adapters/openai_asr_adapter.dart
// ============================================================================
//
// [역할]
// OpenAI GPT-4o Transcribe API 어댑터.
// ASRPort 인터페이스 구현. 동영상→WAV 변환 후 STT 수행.
//
// [레이어]
// Data Layer > Adapters
// ============================================================================

// dart 내장
import 'dart:convert';
import 'dart:io';

// package
import 'package:ffmpeg_kit_flutter/ffmpeg_kit.dart';

import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:parrokit/core/utils/app_logger.dart';

// relative
import '../constants/openai_constants.dart';
import '../ports/asr_port.dart';

/// OpenAI ASR(Automatic Speech Recognition) 어댑터.
///
/// GPT-4o Transcribe Diarize 모델을 사용하여
/// 오디오/비디오 파일을 텍스트로 변환합니다.
class OpenAIAsrAdapter implements ASRPort {
  // ─────────────────────────────────────────────────────────────────
  // 상수
  // ─────────────────────────────────────────────────────────────────

  /// FFmpeg 지원 오디오 확장자
  static const _audioExtensions = {
    '.mp3',
    '.wav',
    '.m4a',
    '.aac',
    '.flac',
    '.ogg',
    '.wma',
    '.opus',
    '.amr',
  };

  /// FFmpeg 지원 비디오 확장자
  static const _videoExtensions = {
    '.mp4',
    '.mov',
    '.mkv',
    '.webm',
    '.avi',
    '.wmv',
    '.flv',
    '.m4v',
    '.3gp',
    '.ts',
    '.mts',
    '.m2ts',
  };

  // ─────────────────────────────────────────────────────────────────
  // 필드
  // ─────────────────────────────────────────────────────────────────
  final String apiKey;

  OpenAIAsrAdapter({required this.apiKey});

  // ─────────────────────────────────────────────────────────────────
  // 파일 변환
  // ─────────────────────────────────────────────────────────────────

  /// 동영상/오디오 파일을 WAV로 변환합니다.
  ///
  /// 이미 오디오 파일이면 그대로 반환합니다.
  Future<String> _ensureWav(String path) async {
    // iOS에서 "file://" prefix 제거
    final normalized = path.startsWith('file://') ? path.substring(7) : path;
    final ext = p.extension(normalized).toLowerCase();

    // 이미 오디오 파일이면 그대로 반환
    final isAudio = _audioExtensions.contains(ext);
    final isVideo = _videoExtensions.contains(ext);
    if (isAudio && !isVideo) return normalized;

    // WAV로 변환
    try {
      final tmpDir = await getTemporaryDirectory();
      final wavPath =
          '${tmpDir.path}/stt_${DateTime.now().millisecondsSinceEpoch}.wav';

      final cmd =
          '-hide_banner -loglevel info -y -i "$normalized" -vn -af "volume=2" -ac 1 -ar 16000 -sample_fmt s16 -c:a pcm_s16le "$wavPath"';

      final session = await FFmpegKit.execute(cmd);
      final rc = await session.getReturnCode();

      if (rc != null && rc.isValueSuccess() && await File(wavPath).exists()) {
        return wavPath;
      }

      // 변환 실패 시 원본 반환 (Whisper가 일부 포맷 지원)
      final logs = await session.getAllLogsAsString();
      AppLogger.e('FFmpeg 변환 실패. rc=${rc?.getValue()}\n$logs');
      return normalized;
    } on MissingPluginException catch (e) {
      AppLogger.w('FFmpeg 플러그인 없음. 원본 사용. $e');
      return normalized;
    } catch (e) {
      AppLogger.e('FFmpeg 예외. 원본 사용. $e');
      return normalized;
    }
  }

  // ─────────────────────────────────────────────────────────────────
  // ASRPort 구현
  // ─────────────────────────────────────────────────────────────────

  @override
  Future<ASRResult> transcribe({
    String? filePath,
    Uint8List? bytes,
    String? language,
    bool withSegments = true,
    Duration? timeout,
  }) async {
    // 입력 검증
    if ((filePath == null || filePath.isEmpty) &&
        (bytes == null || bytes.isEmpty)) {
      throw ArgumentError('filePath 또는 bytes 중 하나는 필수입니다.');
    }

    // API 키 정리
    final cleanKey =
        apiKey.trim().replaceAll('\u201C', '').replaceAll('\u201D', '');
    if (cleanKey.isEmpty) {
      throw ArgumentError('OPENAI_API_KEY가 비어있습니다.');
    }

    // HTTP 요청 구성
    final req =
        http.MultipartRequest('POST', Uri.parse(OpenAIConstants.asrEndpoint));
    req.headers['Authorization'] = 'Bearer $cleanKey';
    req.fields['model'] = OpenAIConstants.asrDefaultModel;
    req.fields['temperature'] = '0';
    req.fields['response_format'] = 'diarized_json';
    req.fields['chunking_strategy'] = 'auto';

    if (language != null && language.isNotEmpty) {
      req.fields['language'] = language;
    }

    // 파일 첨부
    if (filePath != null && filePath.isNotEmpty) {
      final uploadPath = await _ensureWav(filePath);
      final filename = p.basename(uploadPath);

      AppLogger.d('STT 업로드: $uploadPath');

      req.files.add(await http.MultipartFile.fromPath(
        'file',
        uploadPath,
        filename: filename,
        contentType: MediaType('audio', 'wav'),
      ));
    } else {
      final filename = 'audio_${DateTime.now().millisecondsSinceEpoch}.wav';
      req.files.add(http.MultipartFile.fromBytes(
        'file',
        bytes!,
        filename: filename,
        contentType: MediaType('audio', 'wav'),
      ));
    }

    // API 호출
    final streamed =
        await req.send().timeout(timeout ?? const Duration(seconds: 1000));
    final res = await http.Response.fromStream(streamed);

    if (res.statusCode != 200) {
      throw Exception('ASR 실패(${res.statusCode}): ${res.body}');
    }

    // 응답 파싱
    final map = jsonDecode(res.body) as Map<String, dynamic>;
    AppLogger.d('ASR 응답: ${res.body}');

    return _parseResult(map, withSegments);
  }

  // ─────────────────────────────────────────────────────────────────
  // 응답 파싱
  // ─────────────────────────────────────────────────────────────────

  /// API 응답을 ASRResult로 파싱합니다.
  ASRResult _parseResult(Map<String, dynamic> map, bool withSegments) {
    final text = (map['text'] as String?)?.trim() ?? '';

    if (!withSegments) {
      return ASRResult(text: text);
    }

    final segments = <ASRSegment>[];
    final segSrc = map['segments'];

    if (segSrc is List) {
      for (final e in segSrc) {
        if (e is Map) {
          final startSec = _parseDouble(e['start']);
          final endSec = _parseDouble(e['end']);
          final segText = (e['text'] as String?)?.trim() ?? '';

          segments.add(ASRSegment(
            startMs: (startSec * 1000).round(),
            endMs: (endSec * 1000).round(),
            text: segText,
          ));
        }
      }
    }

    return ASRResult(text: text, segments: segments);
  }

  /// 숫자 값을 double로 파싱합니다.
  double _parseDouble(dynamic value) {
    if (value is num) return value.toDouble();
    return double.tryParse('$value') ?? 0.0;
  }
}
