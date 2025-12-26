// ============================================================================
// lib/features/_content/editor/presentation/sections/segments_section.dart
// ============================================================================
//
// [역할]
// 자막 세그먼트 섹션 위젯.
// STT 버튼, 구간 추가/삭제, 세그먼트 카드 목록.
//
// [레이어]
// Presentation Layer > Sections
// ============================================================================

import 'package:flutter/material.dart';

import '../widgets/section_title.dart';
import '../widgets/segment_card.dart';
import '../clip_editor_view_model.dart';

/// 자막 세그먼트 섹션.
class SegmentsSection extends StatelessWidget {
  const SegmentsSection({super.key, required this.vm});

  final ClipEditorViewModel vm;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SectionTitle("자막 정보"),
        const SizedBox(height: 10),
        const Text(
          "* 자동 자막 기능은 주변 소음이 크거나\n   음악이 포함된 영상에서는 정확도가 낮을 수 있어요.",
        ),
        const SizedBox(height: 5),
        Row(
          children: [
            FilledButton.icon(
              icon: const Icon(Icons.subtitles_outlined, size: 18),
              label: const Text('자동 자막 달기'),
              onPressed: vm.onSttAndDraft,
            ),
            const SizedBox(width: 8),
            OutlinedButton.icon(
              icon: const Icon(Icons.add_rounded, size: 18),
              label: const Text('구간 추가'),
              onPressed: vm.addSegment,
            ),
            const Spacer(),
          ],
        ),
        const SizedBox(height: 12),
        _buildSegmentsList(),
      ],
    );
  }

  Widget _buildSegmentsList() {
    final total = vm.segmentForms.length;
    return Column(
      children: [
        for (int i = total - 1; i >= 0; i--) ...[
          SegmentCard(
            index: i + 1,
            startCtl: vm.segmentForms[i].startCtl,
            endCtl: vm.segmentForms[i].endCtl,
            originalCtl: vm.segmentForms[i].originalCtl,
            pronCtl: vm.segmentForms[i].pronCtl,
            koCtl: vm.segmentForms[i].koCtl,
          ),
          const SizedBox(height: 6),
          Row(
            children: [
              const SizedBox(width: 8),
              OutlinedButton.icon(
                icon: const Icon(Icons.delete_outline, size: 18),
                label: const Text('구간 삭제'),
                onPressed: () => vm.removeSegment(i),
              ),
            ],
          ),
          const SizedBox(height: 24),
        ],
      ],
    );
  }
}
