// ============================================================================
// lib/features/_content/editor/presentation/view_model/editor_segment_mixin.dart
// ============================================================================
//
// [역할]
// 세그먼트 관리 mixin.
//
// [레이어]
// Presentation Layer > ViewModel > Mixin
// ============================================================================

import 'package:flutter/material.dart';

import '../../domain/editor_state.dart';

/// 세그먼트 관리 mixin.
mixin EditorSegmentMixin on ChangeNotifier {
  // 의존성 (추상 getter)
  void showToast(String msg);

  // ─────────────────────────────────────────────────────────────────
  // 상태
  // ─────────────────────────────────────────────────────────────────
  final List<SegmentFormData> segmentForms = [];

  // ─────────────────────────────────────────────────────────────────
  // 세그먼트 관리
  // ─────────────────────────────────────────────────────────────────
  void initSegmentForms() {
    segmentForms.add(SegmentFormData.empty());
  }

  void addSegment() {
    final nf = SegmentFormData.empty();
    if (segmentForms.isNotEmpty) {
      nf.startCtl.text = segmentForms.last.endCtl.text;
    }
    segmentForms.add(nf);
    notifyListeners();
  }

  void removeSegment(int index) {
    if (segmentForms.length <= 1) {
      showToast('세그먼트는 최소 1개 이상 필요합니다.');
      return;
    }
    final f = segmentForms.removeAt(index);
    f.dispose();
    notifyListeners();
  }

  void ensureSegmentFormsLength(int count) {
    if (segmentForms.length < count) {
      while (segmentForms.length < count) {
        final nf = SegmentFormData.empty();
        if (segmentForms.isNotEmpty) {
          nf.startCtl.text = segmentForms.last.endCtl.text;
        }
        segmentForms.add(nf);
      }
    } else if (segmentForms.length > count) {
      while (segmentForms.length > count) {
        final removed = segmentForms.removeLast();
        removed.dispose();
      }
    }
    notifyListeners();
  }

  void setSegmentAt(
    int index, {
    required String start,
    required String end,
    required String original,
    required String pron,
    required String ko,
  }) {
    final f = segmentForms[index];
    f.startCtl.text = start;
    f.endCtl.text = end;
    f.originalCtl.text = original;
    f.pronCtl.text = pron;
    f.koCtl.text = ko;
    notifyListeners();
  }

  void disposeSegmentForms() {
    for (final f in segmentForms) {
      f.dispose();
    }
    segmentForms.clear();
  }
}
