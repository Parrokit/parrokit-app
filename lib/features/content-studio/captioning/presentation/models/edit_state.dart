// ============================================================================
// lib/features/content-studio/captioning/presentation/models/edit_state.dart
// ============================================================================
//
// [역할]
// 캡션링 화면 상태 및 폼 모델.
//
// [레이어]
// Presentation Layer > Models
// ============================================================================

import 'package:flutter/material.dart';

/// 저장 상태.
enum EditSaveState {
  idle,
  saving,
  success,
  error,
}

/// STT 처리 진행 상태.
enum SttProcessState {
  idle,
  extracting,
  transcribing,
  translating,
  done,
  error,
}

/// 에디터 스텝.
enum EditStep {
  file,
  collection,
  titles,
  tags,
  segments,
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
