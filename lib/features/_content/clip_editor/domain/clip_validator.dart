// ============================================================================
// lib/features/_content/clip_editor/domain/clip_validator.dart
// ============================================================================
//
// [역할]
// 클립 폼 유효성 검증 로직. UI 독립적인 순수 비즈니스 로직.
//
// [레이어]
// Domain Layer
// ============================================================================

import 'clip_form_data.dart';

/// 검증 결과.
class ValidationResult {
  final bool isValid;
  final String? errorMessage;

  const ValidationResult.valid()
      : isValid = true,
        errorMessage = null;

  const ValidationResult.invalid(this.errorMessage) : isValid = false;
}

/// 클립 폼 유효성 검증기.
class ClipValidator {
  static const int maxDurationMs = 5 * 60 * 1000; // 5분

  /// MM:SS.mmm 형식 정규식.
  static final RegExp timecodePattern = RegExp(r'^\d{2}:\d{2}\.\d{3}$');

  /// 폼 전체 유효성 검증.
  ValidationResult validateForm(ClipFormData form) {
    // 파일 검증
    if (form.filePath == null || form.filePath!.isEmpty) {
      return const ValidationResult.invalid('영상 파일을 먼저 선택해 주세요.');
    }

    // 컬렉션 이름 (필수)
    if (form.collectionName == null || form.collectionName!.trim().isEmpty) {
      return const ValidationResult.invalid('컬렉션은 필수입니다.');
    }

    // 클립 제목
    if (form.clipTitle.trim().isEmpty) {
      return const ValidationResult.invalid('클립 제목은 필수입니다.');
    }

    // 영상 길이
    if (form.durationMs == null || form.durationMs! <= 0) {
      return const ValidationResult.invalid('영상 길이(duration)는 필수입니다.');
    }
    if (form.durationMs! > maxDurationMs) {
      return const ValidationResult.invalid('영상 길이는 최대 5분까지만 허용됩니다.');
    }

    // 세그먼트 검증
    final segmentResult = validateSegments(form.segments, form.durationMs!);
    if (!segmentResult.isValid) {
      return segmentResult;
    }

    return const ValidationResult.valid();
  }

  /// 세그먼트 목록 유효성 검증.
  ValidationResult validateSegments(
      List<SegmentInput> segments, int durationMs) {
    if (segments.isEmpty) {
      return const ValidationResult.invalid('세그먼트는 최소 1개 이상 필요합니다.');
    }

    for (int i = 0; i < segments.length; i++) {
      final seg = segments[i];
      final idx = i + 1;

      // 필수 필드 검증
      if (!seg.isComplete) {
        return ValidationResult.invalid('세그먼트 $idx: 모든 필드는 필수입니다.');
      }

      // 시간 형식 검증
      if (!timecodePattern.hasMatch(seg.start)) {
        return ValidationResult.invalid('세그먼트 $idx: 시작 시각 형식 오류.');
      }
      if (!timecodePattern.hasMatch(seg.end)) {
        return ValidationResult.invalid('세그먼트 $idx: 종료 시각 형식 오류.');
      }

      // 시간 값 검증
      final startMs = _parseTimecode(seg.start);
      final endMs = _parseTimecode(seg.end);

      if (endMs <= startMs) {
        return ValidationResult.invalid('세그먼트 $idx: 종료가 시작보다 커야 합니다.');
      }
      if (startMs < 0 || endMs > durationMs) {
        return ValidationResult.invalid('세그먼트 $idx: 구간이 영상 길이를 벗어납니다.');
      }
    }

    // 세그먼트 겹침 검증
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

  /// MM:SS.mmm 형식을 밀리초로 변환.
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
