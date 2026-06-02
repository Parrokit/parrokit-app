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
import 'package:parrokit/core/shared/utils/show_toast.dart';
import 'package:parrokit/core/shared/theme/app_colors.dart';
import 'package:parrokit/core/shared/theme/app_radius.dart';
import 'package:parrokit/core/shared/theme/app_spacing.dart';

import '../../data/constants/editor_strings.dart';
import '../../domain/editor_state.dart';
import '../widgets/stt_progress_card.dart';
import '../widgets/segment_card.dart';
import '../captioning_view_model.dart';

/// 자막 세그먼트 섹션.
class SegmentsSection extends StatefulWidget {
  const SegmentsSection({super.key, required this.vm});

  final CaptioningViewModel vm;

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
    final tt = Theme.of(context).textTheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final mutedText =
        isDark ? AppColors.textSecondaryDark : AppColors.textSecondary;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.all(AppSpacing.lg),
          decoration: BoxDecoration(
            color: isDark
                ? AppColors.surfaceContainerDark
                : AppColors.surfaceContainer,
            borderRadius: BorderRadius.circular(AppRadius.md),
            border: Border.all(
              color: isDark
                  ? AppColors.dividerSubtleDark
                  : AppColors.dividerSubtle,
            ),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.primary,
                  borderRadius: BorderRadius.circular(AppRadius.sm),
                ),
                child: const Icon(
                  Icons.subtitles_rounded,
                  color: Colors.white,
                ),
              ),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '자막 구간',
                      style: tt.titleMedium?.copyWith(
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    const SizedBox(height: AppSpacing.xs),
                    Text(
                      '구간을 넘겨보며 시작/끝 시간, 원문, 발음, 번역을 한 화면에서 정리합니다.',
                      style: tt.bodyMedium?.copyWith(color: mutedText),
                    ),
                    const SizedBox(height: AppSpacing.sm),
                    Wrap(
                      spacing: AppSpacing.sm,
                      runSpacing: AppSpacing.sm,
                      children: [
                        _StatusChip(
                          icon: Icons.list_alt_rounded,
                          label: '총 $total개 구간',
                        ),
                        _StatusChip(
                          icon: Icons.swipe_rounded,
                          label: '가로 스와이프',
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: AppSpacing.lg),

        // STT 진행 상황
        if (vm.isSttProcessing) ...[
          SttProgressCard(
            sttState: vm.sttState,
            sttProgress: vm.sttProgress,
            sttTotal: vm.sttTotal,
          ),
          const SizedBox(height: 12),
        ],

        if (total > 0) ...[
          _ActionBar(
            currentPage: _currentPage + 1,
            total: total,
            isProcessing: vm.isSttProcessing,
            sttLabel: vm.isSttProcessing
                ? _sttStatusText(vm.sttState)
                : EditorStrings.sttButtonLabel,
            onSttPressed:
                vm.isSttProcessing ? null : () => vm.onSttAndDraft(context),
            onAddPressed: vm.isSttProcessing ? null : _addAndJump,
            onDeletePressed:
                vm.isSttProcessing ? null : _deleteCurrentAndAdjust,
          ),
          const SizedBox(height: AppSpacing.sm),
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
          ),
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

class _ActionBar extends StatelessWidget {
  const _ActionBar({
    required this.currentPage,
    required this.total,
    required this.isProcessing,
    required this.sttLabel,
    required this.onSttPressed,
    required this.onAddPressed,
    required this.onDeletePressed,
  });

  final int currentPage;
  final int total;
  final bool isProcessing;
  final String sttLabel;
  final VoidCallback? onSttPressed;
  final VoidCallback? onAddPressed;
  final VoidCallback? onDeletePressed;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    final isDark = theme.brightness == Brightness.dark;
    final border =
        isDark ? AppColors.dividerSubtleDark : AppColors.dividerSubtle;

    return Container(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.md,
        AppSpacing.sm,
        AppSpacing.md,
        AppSpacing.sm,
      ),
      decoration: BoxDecoration(
        color: isDark ? AppColors.surfaceContainerDark : AppColors.surface,
        borderRadius: BorderRadius.circular(AppRadius.md),
        border: Border.all(color: border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                '구간 $currentPage / $total',
                style: theme.textTheme.bodySmall?.copyWith(
                  color: cs.onSurfaceVariant,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.sm),
          Wrap(
            spacing: AppSpacing.xs,
            runSpacing: AppSpacing.xs,
            alignment: WrapAlignment.start,
            children: [
              TextButton.icon(
                icon: isProcessing
                    ? const SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                    : const Icon(Icons.subtitles_outlined, size: 18),
                label: Text(sttLabel),
                onPressed: onSttPressed,
              ),
              TextButton.icon(
                icon: const Icon(Icons.add_rounded, size: 18),
                label: Text(EditorStrings.addSegmentButtonLabel),
                onPressed: onAddPressed,
              ),
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
                onPressed: onDeletePressed,
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _StatusChip extends StatelessWidget {
  const _StatusChip({
    required this.icon,
    required this.label,
  });

  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.md,
        vertical: AppSpacing.sm,
      ),
      decoration: BoxDecoration(
        color: isDark ? AppColors.primarySubtleDark : AppColors.primarySubtle,
        borderRadius: BorderRadius.circular(AppRadius.full),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: theme.colorScheme.primary),
          const SizedBox(width: AppSpacing.xs),
          Text(
            label,
            style: theme.textTheme.labelMedium?.copyWith(
              color: theme.colorScheme.primary,
              fontWeight: FontWeight.w800,
            ),
          ),
        ],
      ),
    );
  }
}
