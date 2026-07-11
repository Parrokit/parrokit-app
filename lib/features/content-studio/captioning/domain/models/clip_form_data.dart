// ============================================================================
// lib/features/content-studio/captioning/domain/models/clip_form_data.dart
// ============================================================================
//
// [역할]
// 클립 에디터 폼 데이터. UI 독립적인 순수 데이터 클래스.
//
// [레이어]
// Domain Layer
// ============================================================================

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
  final String? collectionName;
  final String clipTitle;
  final int? durationMs;
  final List<SegmentInput> segments;
  final List<String> tags;
  final String? filePath;

  const ClipFormData({
    this.collectionName,
    this.clipTitle = '',
    this.durationMs,
    this.segments = const [],
    this.tags = const [],
    this.filePath,
  });

  ClipFormData copyWith({
    Object? collectionName = _sentinel,
    String? clipTitle,
    int? durationMs,
    List<SegmentInput>? segments,
    List<String>? tags,
    String? filePath,
  }) {
    return ClipFormData(
      collectionName: collectionName == _sentinel
          ? this.collectionName
          : collectionName as String?,
      clipTitle: clipTitle ?? this.clipTitle,
      durationMs: durationMs ?? this.durationMs,
      segments: segments ?? this.segments,
      tags: tags ?? this.tags,
      filePath: filePath ?? this.filePath,
    );
  }
}

const _sentinel = Object();
