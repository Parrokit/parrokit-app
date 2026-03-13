// ============================================================================
// lib/features/editor/domain/editor_state.dart
// ============================================================================
//
// [역할]
// 클립 에디터 상태 정의 (enum, 상태 클래스).
//
// [레이어]
// Domain Layer
// ============================================================================

import 'package:flutter/material.dart';

/// 저장 상태.
enum EditorSaveState {
  idle,
  saving,
  success,
  error,
}

/// STT 처리 진행 상태.
enum SttProcessState {
  idle, // 대기
  extracting, // 오디오 추출 중
  transcribing, // 음성 인식 중 (STT)
  translating, // 번역 중
  done, // 완료
  error, // 오류
}

/// 에디터 스텝.
enum EditorStep {
  file, // 0: 파일 선택
  collection, // 1: 컬렉션 (선택)
  titles, // 2: 클립 제목
  tags, // 3: 태그
  segments, // 4: 세그먼트
}

/// 세그먼트 입력 데이터.
class SegmentData {
  String start;
  String end;
  String original;
  String pron;
  String ko;

  SegmentData({
    this.start = '',
    this.end = '',
    this.original = '',
    this.pron = '',
    this.ko = '',
  });

  SegmentData copyWith({
    String? start,
    String? end,
    String? original,
    String? pron,
    String? ko,
  }) {
    return SegmentData(
      start: start ?? this.start,
      end: end ?? this.end,
      original: original ?? this.original,
      pron: pron ?? this.pron,
      ko: ko ?? this.ko,
    );
  }
}

/// 세그먼트 폼 데이터 (TextEditingController 포함).
class SegmentFormData {
  final TextEditingController startCtl;
  final TextEditingController endCtl;
  final TextEditingController originalCtl;
  final TextEditingController pronCtl;
  final TextEditingController koCtl;

  SegmentFormData({
    required this.startCtl,
    required this.endCtl,
    required this.originalCtl,
    required this.pronCtl,
    required this.koCtl,
  });

  factory SegmentFormData.empty() => SegmentFormData(
        startCtl: TextEditingController(),
        endCtl: TextEditingController(),
        originalCtl: TextEditingController(),
        pronCtl: TextEditingController(),
        koCtl: TextEditingController(),
      );

  void dispose() {
    startCtl.dispose();
    endCtl.dispose();
    originalCtl.dispose();
    pronCtl.dispose();
    koCtl.dispose();
  }
}
