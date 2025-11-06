// mvp/editor/adapters/openai_whisper_adapter.dart

import 'dart:convert';
import 'dart:typed_data';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';
import 'package:parrokit/mvp/editor/ports/asr_port.dart';
import 'package:path/path.dart' as p;
import 'package:mime/mime.dart';
import 'dart:io';
import 'package:ffmpeg_kit_flutter/ffmpeg_kit.dart';
import 'package:path_provider/path_provider.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

class OpenAIWhisperAdapter implements ASRPort {
  final String apiKey;
  final String defaultModel;

  OpenAIWhisperAdapter({
    required this.apiKey,
    this.defaultModel = 'whisper-1',
  });

  static const _endpoint = 'https://api.openai.com/v1/audio/transcriptions';

  Future<String> _ensureAudioMp3(String path) async {
    // Normalize potential "file://" prefix on iOS
    final normalized = path.startsWith('file://') ? path.substring(7) : path;
    final lower = normalized.toLowerCase();
    // If already an audio file (and not also a video extension), just return as-is
    final isAudio = lower.endsWith('.mp3') || lower.endsWith('.wav') || lower.endsWith('.m4a') || lower.endsWith('.aac') || lower.endsWith('.flac') || lower.endsWith('.ogg');
    final isVideo = lower.endsWith('.mp4') || lower.endsWith('.mov') || lower.endsWith('.mkv') || lower.endsWith('.webm') || lower.endsWith('.avi');
    if (isAudio && !isVideo) {
      return normalized;
    }
    try {
      final tmpDir = await getTemporaryDirectory();
      final base = DateTime.now().millisecondsSinceEpoch;
      final m4aOut = '${tmpDir.path}/stt_${base}.m4a';
      final wavOut = '${tmpDir.path}/stt_${base}.wav';

      // 1) Try AAC(M4A) 16kHz mono
      final m4aCmd = '-hide_banner -loglevel info -y -i "$normalized" -vn -ac 1 -ar 16000 -c:a aac -b:a 96k "$m4aOut"';
      var session = await FFmpegKit.execute(m4aCmd);
      var rc = await session.getReturnCode();
      if (rc != null && rc.isValueSuccess() && await File(m4aOut).exists()) {
        return m4aOut;
      }

      // 2) Fallback: WAV (PCM S16LE) 16kHz mono
      final wavCmd = '-hide_banner -loglevel info -y -i "$normalized" -vn -ac 1 -ar 16000 -sample_fmt s16 -c:a pcm_s16le "$wavOut"';
      session = await FFmpegKit.execute(wavCmd);
      rc = await session.getReturnCode();
      if (rc != null && rc.isValueSuccess() && await File(wavOut).exists()) {
        return wavOut;
      }

      // 3) If both fail, fall back to original (Whisper accepts common video formats)
      final logs = await session.getAllLogsAsString();
      debugPrint('FFmpeg convert failed. rc=${rc?.getValue()}\n$logs');
      return normalized;
    } on MissingPluginException catch (e) {
      debugPrint('FFmpeg plugin missing; falling back to original. $e');
      return normalized;
    } catch (e) {
      debugPrint('FFmpeg exception; falling back to original. $e');
      return normalized;
    }
  }

  @override
  Future<ASRResult> transcribe({
    String? filePath,
    Uint8List? bytes,
    String? language,
    bool withSegments = true,
    Duration? timeout,
    String? model,
  }) async {
    if ((filePath == null || filePath.isEmpty) &&
        (bytes == null || bytes.isEmpty)) {
      throw ArgumentError('filePath 또는 bytes 중 하나는 필수입니다.');
    }

    final req = http.MultipartRequest('POST', Uri.parse(_endpoint));
    // Sanitize API key: trim, strip smart quotes and surrounding quotes
    final _cleanKey = apiKey
        .trim()
        .replaceAll('\u201C', '')
        .replaceAll('\u201D', '');
    if (_cleanKey.isEmpty) {
      throw ArgumentError('OPENAI_API_KEY is empty after sanitization.');
    }
    req.headers['Authorization'] = 'Bearer $_cleanKey';

    final chosenModel = model ?? defaultModel;
    req.fields['model'] = chosenModel;
    req.fields['temperature'] = '0';

    req.fields['response_format'] = withSegments ? 'verbose_json' : 'json';
    if (language != null && language.isNotEmpty) {
      req.fields['language'] = language;
    }

    if (filePath != null && filePath.isNotEmpty) {
      // 동영상이면 mp3로 추출 후 업로드
      final uploadPath = await _ensureAudioMp3(filePath);
      final filename = p.basename(uploadPath);
      final mime = lookupMimeType(filename)
          ?? (filename.toLowerCase().endsWith('.m4a') ? 'audio/m4a'
              : filename.toLowerCase().endsWith('.wav') ? 'audio/wav'
              : filename.toLowerCase().endsWith('.mp3') ? 'audio/mpeg'
              : filename.toLowerCase().endsWith('.mp4') ? 'video/mp4'
              : 'application/octet-stream');
      req.files.add(await http.MultipartFile.fromPath(
        'file',
        uploadPath,
        filename: filename,
        contentType: MediaType.parse(mime),
      ));
    } else {
      final filename = 'audio_${DateTime.now().millisecondsSinceEpoch}.m4a';
      final mime = 'audio/m4a';
      req.files.add(http.MultipartFile.fromBytes(
        'file',
        bytes!,
        filename: filename,
        contentType: MediaType.parse(mime),
      ));
    }

    final streamed =
        await req.send().timeout(timeout ?? const Duration(seconds: 60));
    final res = await http.Response.fromStream(streamed);

    if (res.statusCode != 200) {
      throw Exception('ASR 실패(${res.statusCode}): ${res.body}');
    }

    final map = jsonDecode(res.body) as Map<String, dynamic>;
    debugPrint(res.body);

    if (withSegments) {
      final text = (map['text'] as String?)?.trim() ?? '';
      final parsed = <ASRSegment>[];

      final dynamic segSrc = map['segments'];
      if (segSrc is List) {
        for (final e in segSrc) {
          if (e is Map) {
            final startVal = e['start'];
            final endVal = e['end'];
            final segText = (e['text'] as String?)?.trim() ?? '';

            final double startSec = startVal is num
                ? startVal.toDouble()
                : double.tryParse('$startVal') ?? 0.0;
            final double endSec = endVal is num
                ? endVal.toDouble()
                : double.tryParse('$endVal') ?? 0.0;

            parsed.add(ASRSegment(
              startMs: (startSec * 1000).round(),
              endMs: (endSec * 1000).round(),
              text: segText,
            ));
          }
        }
      }

      return ASRResult(text: text, segments: parsed);
    } else {
      final text = (map['text'] as String?)?.trim() ?? '';
      return ASRResult(text: text);
    }
  }
}
