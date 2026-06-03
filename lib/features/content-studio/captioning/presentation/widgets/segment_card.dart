import 'package:flutter/material.dart';
import 'package:parrokit/core/shared/theme/app_colors.dart';
import 'package:parrokit/core/shared/theme/app_spacing.dart';
import 'package:parrokit/core/shared/utils/show_toast.dart';
import 'package:video_player/video_player.dart';

import '../../data/services/time_code_service.dart';
import 'labeled_text_field.dart';
import 'time_triplet_field.dart';

class SegmentCard extends StatelessWidget {
  const SegmentCard({
    super.key,
    required this.playerController,
    required this.startCtl,
    required this.endCtl,
    required this.originalCtl,
    required this.pronCtl,
    required this.koCtl,
    this.enabled = true,
    this.onDelete,
  });

  final VideoPlayerController? playerController;
  final TextEditingController startCtl;
  final TextEditingController endCtl;
  final TextEditingController originalCtl;
  final TextEditingController pronCtl;
  final TextEditingController koCtl;
  final bool enabled;
  final VoidCallback? onDelete;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return IgnorePointer(
      ignoring: !enabled,
      child: Opacity(
        opacity: enabled ? 1.0 : 0.5,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Wrap(
                    spacing: AppSpacing.sm,
                    runSpacing: AppSpacing.sm,
                    children: [
                      _SegmentTimeButton(
                        label: 'A 등록',
                        onPressed: _registerA,
                        color: theme.colorScheme.primary,
                        isDark: isDark,
                      ),
                      _SegmentTimeButton(
                        label: 'B 등록',
                        onPressed: _registerB,
                        color: theme.colorScheme.primary,
                        isDark: isDark,
                      ),
                    ],
                  ),
                ),
                if (onDelete != null)
                  IconButton(
                    icon: Icon(Icons.delete_outline_rounded,
                        color: theme.colorScheme.error, size: 20),
                    onPressed: onDelete,
                  ),
              ],
            ),
            const SizedBox(height: AppSpacing.md),
            Container(
              padding: const EdgeInsets.all(AppSpacing.md),
              decoration: BoxDecoration(
                color: isDark
                    ? AppColors.surfaceContainerDark
                    : AppColors.surfaceContainer,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  TimeTripletField(
                    label: '시작',
                    target: startCtl,
                    showGuide: false,
                  ),
                  const SizedBox(height: AppSpacing.md),
                  TimeTripletField(label: '끝', target: endCtl),
                ],
              ),
            ),
            const SizedBox(height: AppSpacing.md),
            LabeledTextField(
              label: '원문',
              hint: '원문을 입력하세요',
              controller: originalCtl,
              prefixIcon: Icons.translate,
              clearable: true,
            ),
            const SizedBox(height: AppSpacing.sm),
            LabeledTextField(
              label: '한국어',
              hint: '한국어를 입력하세요',
              controller: koCtl,
              prefixIcon: Icons.subtitles_outlined,
              clearable: true,
            ),
            const SizedBox(height: AppSpacing.sm),
            LabeledTextField(
              label: '발음',
              hint: '발음을 입력하세요',
              controller: pronCtl,
              prefixIcon: Icons.record_voice_over_outlined,
              clearable: true,
            ),
          ],
        ),
      ),
    );
  }

  void _registerA() {
    final ms = _currentPositionMs();
    if (ms == null) return;

    final next = TimecodeService().msToMMSSmmm(ms);
    final currentB = _parseMs(endCtl.text);
    if (currentB != null && ms > currentB) {
      endCtl.text = next;
    }
    startCtl.text = next;
  }

  void _registerB() {
    final ms = _currentPositionMs();
    if (ms == null) return;

    final next = TimecodeService().msToMMSSmmm(ms);
    final currentA = _parseMs(startCtl.text);
    if (currentA != null && ms < currentA) {
      startCtl.text = next;
    }
    endCtl.text = next;
  }

  int? _currentPositionMs() {
    final c = playerController;
    if (c == null || !c.value.isInitialized) {
      showToast('재생 위치를 확인할 수 없습니다.');
      return null;
    }
    return c.value.position.inMilliseconds;
  }

  int? _parseMs(String value) {
    final text = value.trim();
    if (text.isEmpty) return null;
    try {
      return TimecodeService().parseToMs(text);
    } catch (_) {
      return null;
    }
  }
}

class _SegmentTimeButton extends StatelessWidget {
  const _SegmentTimeButton({
    required this.label,
    required this.onPressed,
    required this.color,
    required this.isDark,
  });

  final String label;
  final VoidCallback? onPressed;
  final Color color;
  final bool isDark;

  @override
  Widget build(BuildContext context) {
    final bg = isDark ? AppColors.primarySubtleDark : AppColors.primarySubtle;
    return FilledButton.tonal(
      onPressed: onPressed,
      style: FilledButton.styleFrom(
        backgroundColor: bg,
        foregroundColor: color,
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        textStyle: const TextStyle(fontWeight: FontWeight.w800),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
      child: Text(label),
    );
  }
}
