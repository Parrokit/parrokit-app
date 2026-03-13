// ============================================================================
// lib/features/_content/editor/presentation/sections/segments_section.dart
// ============================================================================
//
// [역할]
// 자막 세그먼트 섹션 위젯.
// STT 버튼, 구간 추가/삭제, 세그먼트 카드 횡스크롤(PageView).
//
// [레이어]
// Presentation Layer > Sections
// ============================================================================

import 'package:flutter/material.dart';
import 'package:parrokit/core/utils/show_toast.dart';

import '../../data/constants/editor_strings.dart';
import '../../domain/editor_state.dart';
import '../widgets/stt_progress_card.dart';
import '../widgets/segment_card.dart';
import '../clip_editor_view_model.dart';

/// 자막 세그먼트 섹션.
class SegmentsSection extends StatefulWidget {
  const SegmentsSection({super.key, required this.vm});

  final ClipEditorViewModel vm;

  @override
  State<SegmentsSection> createState() => _SegmentsSectionState();
}

class _SegmentsSectionState extends State<SegmentsSection> {
  final ScrollController _scrollCtrl = ScrollController();
  int _currentPage = 0;

  @override
  void initState() {
    super.initState();
    _scrollCtrl.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollCtrl.removeListener(_onScroll);
    _scrollCtrl.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (!_scrollCtrl.hasClients) return;
    final width = MediaQuery.of(context).size.width - 32;
    if (width <= 0) return;

    final newPage = (_scrollCtrl.offset / width).round();
    final total = widget.vm.segmentForms.length;
    if (newPage != _currentPage && newPage >= 0 && newPage < total) {
      setState(() => _currentPage = newPage);
    }
  }

  void _addAndJump() {
    final newIndex = widget.vm.segmentForms.length;
    widget.vm.addSegment();
    
    // 페이지 번호를 즉시 업데이트하여 UI 반응성 개선
    setState(() => _currentPage = newIndex);
    
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (widget.vm.segmentForms.isNotEmpty) {
        final width = MediaQuery.of(context).size.width - 32;
        _scrollCtrl.animateTo(
          newIndex * width,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  void _deleteCurrentAndAdjust() {
    final total = widget.vm.segmentForms.length;
    if (total <= 1) {
      showToast('마지막 구간은 삭제할 수 없습니다.');
      return;
    }

    final deletedIndex = _currentPage;
    // 삭제된 인덱스의 이전(max 0)으로 타겟 설정
    final targetPage = (deletedIndex - 1).clamp(0, total - 2);

    widget.vm.removeSegment(deletedIndex);

    // 즉시 업데이트하여 "구간 X / Y" 텍스트 동기화
    setState(() => _currentPage = targetPage);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (widget.vm.segmentForms.isNotEmpty) {
        final width = MediaQuery.of(context).size.width - 32;
        _scrollCtrl.jumpTo(targetPage * width);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final vm = widget.vm;
    final total = vm.segmentForms.length;
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          EditorStrings.segmentsNotice,
          style: tt.bodySmall?.copyWith(
            color: cs.onSurfaceVariant,
          ),
        ),
        const SizedBox(height: 8),

        // STT 진행 상황
        if (vm.isSttProcessing) ...[
          SttProgressCard(
            sttState: vm.sttState,
            sttProgress: vm.sttProgress,
            sttTotal: vm.sttTotal,
          ),
          const SizedBox(height: 12),
        ],

        // 버튼 행
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
                  ? _sttStatusText(vm.sttState)
                  : EditorStrings.sttButtonLabel),
              onPressed: vm.isSttProcessing ? null : vm.onSttAndDraft,
            ),
            const SizedBox(width: 8),
            OutlinedButton.icon(
              icon: const Icon(Icons.add_rounded, size: 18),
              label: Text(EditorStrings.addSegmentButtonLabel),
              onPressed: vm.isSttProcessing ? null : _addAndJump,
            ),
          ],
        ),

        if (total > 0) ...[
          const SizedBox(height: 14),

          // 페이지 인디케이터 + 삭제 버튼
          Row(
            children: [
              const SizedBox(width: 10),
              Text(
                '구간 ${_currentPage + 1} / $total',
                style: tt.bodySmall?.copyWith(color: cs.onSurfaceVariant),
              ),
              const Spacer(),
              TextButton.icon(
                icon: Icon(
                  Icons.delete_outline_rounded,
                  size: 16,
                  color: cs.error,
                ),
                label: Text(
                  EditorStrings.removeSegmentButtonLabel,
                  style: TextStyle(color: cs.error),
                ),
                onPressed: vm.isSttProcessing ? null : _deleteCurrentAndAdjust,
              ),
            ],
          ),
          const SizedBox(height: 6),
          SingleChildScrollView(
            controller: _scrollCtrl,
            scrollDirection: Axis.horizontal,
            physics: const PageScrollPhysics(), // 페이지 단위 스크롤
            child: Row(
              children: List.generate(total, (i) {
                return Container(
                  width: MediaQuery.of(context).size.width - 32, // 좌우 패딩 제외한 너비
                  padding: const EdgeInsets.only(right: 8),
                  child: SegmentCard(
                    index: i + 1,
                    startCtl: vm.segmentForms[i].startCtl,
                    endCtl: vm.segmentForms[i].endCtl,
                    originalCtl: vm.segmentForms[i].originalCtl,
                    pronCtl: vm.segmentForms[i].pronCtl,
                    koCtl: vm.segmentForms[i].koCtl,
                    enabled: !vm.isSttProcessing,
                  ),
                );
              }),
            ),
          )
        ],
      ],
    );
  }

  String _sttStatusText(SttProcessState state) {
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
}
