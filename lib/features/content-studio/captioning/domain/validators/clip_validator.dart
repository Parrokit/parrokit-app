// ============================================================================
// lib/features/content-studio/captioning/domain/validators/clip_validator.dart
// ============================================================================
//
// [역할]
// 클립 폼 유효성 검증 로직. UI 독립적인 순수 비즈니스 로직.
//
// [레이어]
// Domain Layer
// ============================================================================

import '../models/clip_form_data.dart';

class ValidationResult {
  final bool isValid;
  final String? errorMessage;

  const ValidationResult.valid()
      : isValid = true,
        errorMessage = null;

  const ValidationResult.invalid(this.errorMessage) : isValid = false;
}

class ClipValidator {
  static const int maxDurationMs = 5 * 60 * 1000;
  static final RegExp timecodePattern = RegExp(r'^\d{2}:\d{2}\.\d{3}$');

  ValidationResult validateForm(ClipFormData form) {
    if (form.filePath == null || form.filePath!.isEmpty) {
      return const ValidationResult.invalid('영상 파일을 먼저 선택해 주세요.');
    }

    if (form.collectionName == null || form.collectionName!.trim().isEmpty) {
      return const ValidationResult.invalid('컬렉션은 필수입니다.');
    }

    if (form.clipTitle.trim().isEmpty) {
      return const ValidationResult.invalid('클립 제목은 필수입니다.');
    }

    if (form.durationMs == null || form.durationMs! <= 0) {
      return const ValidationResult.invalid('영상 길이(duration)는 필수입니다.');
    }
    if (form.durationMs! > maxDurationMs) {
      return const ValidationResult.invalid('영상 길이는 최대 5분까지만 허용됩니다.');
    }

    final segmentResult = validateSegments(form.segments, form.durationMs!);
    if (!segmentResult.isValid) {
      return segmentResult;
    }

    return const ValidationResult.valid();
  }

  ValidationResult validateSegments(
      List<SegmentInput> segments, int durationMs) {
    if (segments.isEmpty) {
      return const ValidationResult.invalid('세그먼트는 최소 1개 이상 필요합니다.');
    }

    for (int i = 0; i < segments.length; i++) {
      final seg = segments[i];
      final idx = i + 1;

      if (!seg.isComplete) {
        return ValidationResult.invalid('세그먼트 $idx: 모든 필드는 필수입니다.');
      }

      if (!timecodePattern.hasMatch(seg.start)) {
        return ValidationResult.invalid('세그먼트 $idx: 시작 시각 형식 오류.');
      }
      if (!timecodePattern.hasMatch(seg.end)) {
        return ValidationResult.invalid('세그먼트 $idx: 종료 시각 형식 오류.');
      }

      final startMs = _parseTimecode(seg.start);
      final endMs = _parseTimecode(seg.end);

      if (endMs <= startMs) {
        return ValidationResult.invalid('세그먼트 $idx: 종료가 시작보다 커야 합니다.');
      }
      if (startMs < 0 || endMs > durationMs) {
        return ValidationResult.invalid('세그먼트 $idx: 구간이 영상 길이를 벗어납니다.');
      }
    }

    final sorted = List<SegmentInput>.from(segments)
      ..sort(
          (a, b) => _parseTimecode(a.start).compareTo(_parseTimecode(b.start)));

    for (int i = 1; i < sorted.length; i++) {
      final prevEnd = _parseTimecode(sorted[i - 1].end);
      final currStart = _parseTimecode(sorted[i].start);
      if (currStart < prevEnd) {
        return ValidationResult.invalid('세그먼트 $i와 ${i + 1}이 겹칩니다.');
      }
    }

    return const ValidationResult.valid();
  }

  int _parseTimecode(String tc) {
    final parts = tc.split(':');
    if (parts.length != 2) return 0;
    final min = int.tryParse(parts[0]) ?? 0;
    final secParts = parts[1].split('.');
    if (secParts.length != 2) return min * 60 * 1000;
    final sec = int.tryParse(secParts[0]) ?? 0;
    final ms = int.tryParse(secParts[1]) ?? 0;
    return (min * 60 + sec) * 1000 + ms;
  }
}
