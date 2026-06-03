import 'package:flutter/material.dart';
import 'package:parrokit/core/shared/theme/app_colors.dart';
import 'package:parrokit/core/shared/theme/app_radius.dart';
import 'package:parrokit/core/shared/theme/app_spacing.dart';

import '../../data/constants/editor_strings.dart';
import 'time_triplet_field.dart';

import 'labeled_text_field.dart';

class SegmentCard extends StatelessWidget {
  const SegmentCard({
    super.key,
    required this.index,
    required this.startCtl,
    required this.endCtl,
    required this.originalCtl,
    required this.pronCtl,
    required this.koCtl,
    this.enabled = true,
    this.onDelete,
  });

  final int index;
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
    final tt = theme.textTheme;
    final isDark = theme.brightness == Brightness.dark;
    final mutedText =
        isDark ? AppColors.textSecondaryDark : AppColors.textSecondary;

    return IgnorePointer(
      ignoring: !enabled,
      child: Opacity(
        opacity: enabled ? 1.0 : 0.5,
        child: Container(
          padding: EdgeInsets.zero,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    width: 34,
                    height: 34,
                    decoration: BoxDecoration(
                      color: isDark
                          ? AppColors.primarySubtleDark
                          : AppColors.primarySubtle,
                      borderRadius: BorderRadius.circular(AppRadius.sm),
                    ),
                    child: Icon(
                      Icons.notes_rounded,
                      size: 18,
                      color: theme.colorScheme.primary,
                    ),
                  ),
                  const SizedBox(width: AppSpacing.sm),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          EditorStrings.segmentCardTitle(index),
                          style: tt.titleMedium?.copyWith(
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          '시간과 자막을 함께 조정합니다.',
                          style: tt.bodySmall?.copyWith(color: mutedText),
                        ),
                      ],
                    ),
                  ),
                  if (onDelete != null)
                    IconButton(
                      icon: Icon(Icons.delete_outline_rounded,
                          color: theme.colorScheme.error, size: 20),
                      onPressed: onDelete,
                      tooltip: EditorStrings.removeSegmentButtonLabel,
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
                  borderRadius: BorderRadius.circular(AppRadius.md),
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
                label: EditorStrings.originalLabel,
                hint: EditorStrings.originalHint,
                controller: originalCtl,
                prefixIcon: Icons.translate,
                clearable: true,
              ),
              const SizedBox(height: AppSpacing.sm),
              LabeledTextField(
                label: EditorStrings.koLabel,
                hint: EditorStrings.koHint,
                controller: koCtl,
                prefixIcon: Icons.subtitles_outlined,
                clearable: true,
              ),
              const SizedBox(height: AppSpacing.sm),
              LabeledTextField(
                label: EditorStrings.pronLabel,
                hint: EditorStrings.pronHint,
                controller: pronCtl,
                prefixIcon: Icons.record_voice_over_outlined,
                clearable: true,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
