// ============================================================================
// lib/features/_content/clip_editor/data/services/draft_generation_service.dart
// ============================================================================
//
// [역할]
// STT + LLM 초안 생성 서비스.
//
// [레이어]
// Data Layer > Services
// ============================================================================

import 'dart:convert';

import '../../domain/clip_form_data.dart';
import '../ports/llm_port.dart';
import '../prompts/prompt_loader.dart';
import 'time_code_service.dart';
import '../usecases/transcribe_usecase.dart';

/// 초안 생성 결과.
class DraftResult {
  final List<SegmentInput> segments;
  final int coinCost;

  const DraftResult({
    required this.segments,
    required this.coinCost,
  });
}

/// STT + LLM 초안 생성 서비스.
class DraftGenerationService {
  final TranscribeUseCase transcribe;
  final LLMPort llm;
  final TimecodeService _timecode = TimecodeService();

  DraftGenerationService({
    required this.transcribe,
    required this.llm,
  });

  /// 영상 파일에서 STT를 수행하고 번역/발음 초안을 생성합니다.
  /// [onProgress]는 (current, total, message) 형태로 진행 상황을 전달합니다.
  Future<DraftResult> generate({
    required String filePath,
    required int durationMs,
    String language = 'ja',
    void Function(int current, int total, String message)? onProgress,
  }) async {
    // 1) STT 수행
    final asr = await transcribe(
      filePath: filePath,
      language: language,
      withSegments: true,
    );

    if (asr.segments.isEmpty) {
      return const DraftResult(segments: [], coinCost: 0);
    }

    // 2) LLM으로 번역/발음 생성
    final allDraftSegments = <SegmentInput>[];
    const batchSize = 5;
    final sys = await PromptLoader.loadSttDraftSystem();
    final userPrefix = await PromptLoader.loadSttDraftUser();

    final totalBatches = (asr.segments.length / batchSize).ceil();
    int currentBatch = 0;

    for (int offset = 0; offset < asr.segments.length; offset += batchSize) {
      currentBatch++;
      onProgress?.call(
          currentBatch, totalBatches, '번역 중 ($currentBatch/$totalBatches)');

      final batch = asr.segments.sublist(
        offset,
        (offset + batchSize > asr.segments.length)
            ? asr.segments.length
            : offset + batchSize,
      );

      final asrArray = batch
          .map((s) => {
                'start_ms': s.startMs,
                'end_ms': s.endMs,
                'text': s.text,
              })
          .toList();

      final userPrompt = '$userPrefix${jsonEncode(asrArray)}';

      final jsonStr = await llm.complete(
        systemPrompt: sys,
        userPrompt: userPrompt,
        timeout: const Duration(seconds: 60),
      );

      final map = jsonDecode(jsonStr);
      final segs = (map is Map && map['segments'] is List)
          ? (map['segments'] as List)
          : const [];

      final count = segs.length < batch.length ? segs.length : batch.length;
      for (int i = 0; i < count; i++) {
        final e = segs[i];
        final asrSeg = batch[i];
        if (e is Map) {
          allDraftSegments.add(SegmentInput(
            start: _timecode.msToMMSSmmm(asrSeg.startMs),
            end: _timecode.msToMMSSmmm(asrSeg.endMs),
            original: (e['orig'] ?? '').toString(),
            pron: (e['pron'] ?? '').toString(),
            ko: (e['ko'] ?? '').toString(),
          ));
        } else {
          allDraftSegments.add(SegmentInput(
            start: _timecode.msToMMSSmmm(asrSeg.startMs),
            end: _timecode.msToMMSSmmm(asrSeg.endMs),
          ));
        }
      }
    }

    // 3) 코인 비용 계산
    final coinCost = _calculateCoinCost(durationMs);

    return DraftResult(
      segments: _normalizeSegments(allDraftSegments, durationMs),
      coinCost: coinCost,
    );
  }

  int _calculateCoinCost(int durationMs) {
    final seconds = (durationMs / 1000).ceil();
    if (seconds <= 0) return 0;
    return ((seconds + 29) ~/ 30);
  }

  List<SegmentInput> _normalizeSegments(List<SegmentInput> segments, int durationMs) {
    final indexed = <({int startMs, int endMs, SegmentInput segment})>[];

    for (final segment in segments) {
      final startMs = _parseMs(segment.start);
      final endMs = _parseMs(segment.end);
      if (startMs == null || endMs == null) continue;
      if (startMs < 0 || endMs <= startMs) continue;
      if (startMs >= durationMs) continue;

      indexed.add((startMs: startMs, endMs: endMs, segment: segment));
    }

    indexed.sort((a, b) => a.startMs.compareTo(b.startMs));

    final normalized = <SegmentInput>[];
    var lastEnd = 0;

    for (final item in indexed) {
      var startMs = item.startMs;
      var endMs = item.endMs;

      if (startMs < lastEnd) {
        startMs = lastEnd;
      }

      if (endMs > durationMs) {
        endMs = durationMs;
      }
      if (endMs <= startMs) {
        continue;
      }

      normalized.add(
        item.segment.copyWith(
          start: _timecode.msToMMSSmmm(startMs),
          end: _timecode.msToMMSSmmm(endMs),
        ),
      );
      lastEnd = endMs;
    }

    return normalized;
  }

  int? _parseMs(String value) {
    final text = value.trim();
    if (text.isEmpty) return null;
    try {
      return _timecode.parseToMs(text);
    } catch (_) {
      return null;
    }
  }
}
