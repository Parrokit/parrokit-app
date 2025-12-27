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

import '../../data/editor_strings.dart';
import '../../domain/editor_state.dart';
import '../widgets/section_title.dart';
import '../widgets/cards/segment_card.dart';
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
        SectionTitle(EditorStrings.segmentsSectionTitle),
        const SizedBox(height: 10),
        Text(EditorStrings.segmentsNotice),
        const SizedBox(height: 5),

        // STT 진행 상황 표시
        if (vm.isSttProcessing) ...[
          _buildSttProgressCard(context),
          const SizedBox(height: 12),
        ],

        Row(
          children: [
            FilledButton.icon(
              icon: vm.isSttProcessing
                  ? const SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.white,
                      ),
                    )
                  : const Icon(Icons.subtitles_outlined, size: 18),
              label: Text(vm.isSttProcessing
                  ? _getSttStatusText(vm.sttState)
                  : EditorStrings.sttButtonLabel),
              onPressed: vm.isSttProcessing ? null : vm.onSttAndDraft,
            ),
            const SizedBox(width: 8),
            OutlinedButton.icon(
              icon: const Icon(Icons.add_rounded, size: 18),
              label: Text(EditorStrings.addSegmentButtonLabel),
              onPressed: vm.isSttProcessing ? null : vm.addSegment,
            ),
            const Spacer(),
          ],
        ),
        const SizedBox(height: 12),
        _buildSegmentsList(),
      ],
    );
  }

  Widget _buildSttProgressCard(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    // 번역 중일 때 배치 진행률 표시
    final translatingLabel =
        vm.sttTotal > 0 && vm.sttState == SttProcessState.translating
            ? '번역 중 (${vm.sttProgress}/${vm.sttTotal})'
            : '번역 중';

    final steps = [
      (SttProcessState.extracting, '오디오 추출', Icons.music_note_rounded),
      (SttProcessState.transcribing, '음성 인식 (STT)', Icons.hearing_rounded),
      (SttProcessState.translating, translatingLabel, Icons.translate_rounded),
    ];

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: cs.primaryContainer.withValues(alpha: 0.3),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: cs.primary.withValues(alpha: 0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.auto_awesome, color: cs.primary, size: 20),
              const SizedBox(width: 8),
              Text(
                'AI 자막 생성 중...',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: cs.primary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          ...steps.map((step) {
            final (state, label, icon) = step;
            final isActive = vm.sttState == state;
            final isCompleted = vm.sttState.index > state.index;

            return Padding(
              padding: const EdgeInsets.symmetric(vertical: 4),
              child: Row(
                children: [
                  if (isCompleted)
                    Icon(Icons.check_circle, color: cs.primary, size: 20)
                  else if (isActive)
                    SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: cs.primary,
                      ),
                    )
                  else
                    Icon(Icons.circle_outlined,
                        color: cs.onSurface.withValues(alpha: 0.3), size: 20),
                  const SizedBox(width: 12),
                  Icon(icon,
                      size: 18,
                      color: isActive || isCompleted
                          ? cs.primary
                          : cs.onSurface.withValues(alpha: 0.4)),
                  const SizedBox(width: 8),
                  Text(
                    label,
                    style: TextStyle(
                      fontWeight:
                          isActive ? FontWeight.bold : FontWeight.normal,
                      color: isActive || isCompleted
                          ? cs.onSurface
                          : cs.onSurface.withValues(alpha: 0.5),
                    ),
                  ),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }

  String _getSttStatusText(SttProcessState state) {
    switch (state) {
      case SttProcessState.extracting:
        return '추출 중...';
      case SttProcessState.transcribing:
        return '인식 중...';
      case SttProcessState.translating:
        return '번역 중...';
      case SttProcessState.done:
        return '완료!';
      case SttProcessState.error:
        return '오류';
      default:
        return EditorStrings.sttButtonLabel;
    }
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
            enabled: !vm.isSttProcessing,
          ),
          const SizedBox(height: 6),
          Row(
            children: [
              const SizedBox(width: 8),
              OutlinedButton.icon(
                icon: const Icon(Icons.delete_outline, size: 18),
                label: Text(EditorStrings.removeSegmentButtonLabel),
                onPressed:
                    vm.isSttProcessing ? null : () => vm.removeSegment(i),
              ),
            ],
          ),
          const SizedBox(height: 24),
        ],
      ],
    );
  }
}
