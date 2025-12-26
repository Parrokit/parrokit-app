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

import 'package:parrokit/core/router/app_router.dart';
import 'package:parrokit/core/utils/show_toast.dart';
import '../../domain/editor_state.dart';

/// 세그먼트 관리 mixin.
mixin EditorSegmentMixin on ChangeNotifier {
  // 의존성 (추상 getter)

  // ─────────────────────────────────────────────────────────────────
  // 상태
  // ─────────────────────────────────────────────────────────────────
  final List<SegmentFormData> segmentForms = [];

  // ─────────────────────────────────────────────────────────────────
  // 세그먼트 관리
  // ─────────────────────────────────────────────────────────────────

  /// 초기 세그먼트(폼) 하나를 추가 생성합니다.
  void initSegmentForms() {
    segmentForms.add(SegmentFormData.empty());
  }

  /// 새로운 세그먼트 폼을 추가합니다.
  /// 이전 세그먼트의 종료 시간을 새 세그먼트의 시작 시간으로 자동 입력합니다.
  void addSegment() {
    final nf = SegmentFormData.empty();
    if (segmentForms.isNotEmpty) {
      nf.startCtl.text = segmentForms.last.endCtl.text;
    }
    segmentForms.add(nf);
    notifyListeners();
  }

  /// 특정 인덱스의 세그먼트를 제거합니다.
  /// (최소 1개는 유지해야 합니다)
  void removeSegment(int index) {
    if (segmentForms.length <= 1) {
      if (rootNavigatorKey.currentContext != null) {
        showToast(rootNavigatorKey.currentContext!, '세그먼트는 최소 1개 이상 필요합니다.');
      }
      return;
    }
    final f = segmentForms.removeAt(index);
    f.dispose();
    notifyListeners();
  }

  /// 세그먼트 폼의 개수를 [count]개로 맞춥니다 (추가/삭제).
  /// 자동 생성(STT 등) 시 사용됩니다.
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

  /// 특정 인덱스의 세그먼트 값을 설정합니다. (STT 결과 반영 등)
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

  /// 모든 세그먼트 폼 리소스를 해제합니다.
  void disposeSegmentForms() {
    for (final f in segmentForms) {
      f.dispose();
    }
    segmentForms.clear();
  }
}
