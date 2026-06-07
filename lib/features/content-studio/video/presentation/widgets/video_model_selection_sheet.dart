import 'package:flutter/material.dart';
import 'package:parrokit/core/shared/theme/app_colors.dart';
import 'package:parrokit/core/shared/theme/app_radius.dart';
import 'package:parrokit/core/shared/theme/app_spacing.dart';
import 'package:parrokit/features/content-studio/video/presentation/video_provider.dart';

class VideoModelSelectionSheet extends StatelessWidget {
  const VideoModelSelectionSheet({super.key, required this.provider});

  final VideoProvider provider;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    final models = [
      {'id': 'veo3.1-lite', 'name': 'Veo 3.1 Lite', 'description': '빠른 생성 속도, 적은 비용'},
      {'id': 'veo3.1-full', 'name': 'Veo 3.1 Full', 'description': '고품질 영상 생성, 디테일 최적화'},
    ];

    return Container(
      constraints: BoxConstraints(
        maxHeight: MediaQuery.of(context).size.height * 0.85,
      ),
      decoration: BoxDecoration(
        color: isDark ? AppColors.surfaceDark : AppColors.surface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(AppRadius.lg)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          const SizedBox(height: AppSpacing.sm),
          Center(
            child: Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: isDark ? Colors.grey.shade700 : Colors.grey.shade300,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          const SizedBox(height: AppSpacing.lg),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
            child: Text(
              '영상 생성 모델 선택',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          ListView.builder(
            shrinkWrap: true,
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
            itemCount: models.length,
            itemBuilder: (context, index) {
              final model = models[index];
              final isSelected = provider.model == model['id'];

              return ListTile(
                title: Text(
                  model['name']!,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                    color: isSelected ? theme.colorScheme.primary : null,
                  ),
                ),
                subtitle: Text(
                  model['description']!,
                  style: theme.textTheme.labelSmall?.copyWith(
                    color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondary,
                  ),
                ),
                trailing: isSelected
                    ? Icon(Icons.check_circle_rounded, color: theme.colorScheme.primary)
                    : null,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(AppRadius.sm),
                ),
                onTap: () {
                  provider.updateModel(model['id']!);
                  Navigator.pop(context);
                },
              );
            },
          ),
          const SizedBox(height: AppSpacing.xl),
        ],
      ),
    );
  }
}
