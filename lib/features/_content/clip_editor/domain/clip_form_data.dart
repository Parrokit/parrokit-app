// ============================================================================
// lib/features/_content/clip_editor/domain/clip_form_data.dart
// ============================================================================
//
// [역할]
// 클립 에디터 폼 데이터. UI 독립적인 순수 데이터 클래스.
//
// [레이어]
// Domain Layer
// ============================================================================

import 'editor_state.dart';

/// 세그먼트 순수 데이터 (UI 독립적).
class SegmentInput {
  final String start;
  final String end;
  final String original;
  final String pron;
  final String ko;

  const SegmentInput({
    this.start = '',
    this.end = '',
    this.original = '',
    this.pron = '',
    this.ko = '',
  });

  SegmentInput copyWith({
    String? start,
    String? end,
    String? original,
    String? pron,
    String? ko,
  }) {
    return SegmentInput(
      start: start ?? this.start,
      end: end ?? this.end,
      original: original ?? this.original,
      pron: pron ?? this.pron,
      ko: ko ?? this.ko,
    );
  }

  bool get isEmpty =>
      start.isEmpty &&
      end.isEmpty &&
      original.isEmpty &&
      pron.isEmpty &&
      ko.isEmpty;

  bool get isComplete =>
      start.isNotEmpty &&
      end.isNotEmpty &&
      original.isNotEmpty &&
      pron.isNotEmpty &&
      ko.isNotEmpty;
}

/// 클립 에디터 폼 전체 데이터.
class ClipFormData {
  final String titleName;
  final String titleNameNative;
  final String clipTitle;
  final String epiTitle;
  final int? seasonNumber;
  final int? episodeNumber;
  final ContentType contentType;
  final int? durationMs;
  final List<SegmentInput> segments;
  final List<String> tags;
  final String? filePath;

  const ClipFormData({
    this.titleName = '',
    this.titleNameNative = '-',
    this.clipTitle = '',
    this.epiTitle = '',
    this.seasonNumber,
    this.episodeNumber,
    this.contentType = ContentType.season,
    this.durationMs,
    this.segments = const [],
    this.tags = const [],
    this.filePath,
  });

  ClipFormData copyWith({
    String? titleName,
    String? titleNameNative,
    String? clipTitle,
    String? epiTitle,
    int? seasonNumber,
    int? episodeNumber,
    ContentType? contentType,
    int? durationMs,
    List<SegmentInput>? segments,
    List<String>? tags,
    String? filePath,
  }) {
    return ClipFormData(
      titleName: titleName ?? this.titleName,
      titleNameNative: titleNameNative ?? this.titleNameNative,
      clipTitle: clipTitle ?? this.clipTitle,
      epiTitle: epiTitle ?? this.epiTitle,
      seasonNumber: seasonNumber ?? this.seasonNumber,
      episodeNumber: episodeNumber ?? this.episodeNumber,
      contentType: contentType ?? this.contentType,
      durationMs: durationMs ?? this.durationMs,
      segments: segments ?? this.segments,
      tags: tags ?? this.tags,
      filePath: filePath ?? this.filePath,
    );
  }

  /// 타입 문자열 (API용).
  String get typeString =>
      contentType == ContentType.season ? 'season' : 'movie';
}
