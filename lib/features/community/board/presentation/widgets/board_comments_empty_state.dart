import 'package:flutter/material.dart';
import 'package:parrokit/core/shared/theme/app_colors.dart';

class BoardCommentsEmptyState extends StatelessWidget {
  const BoardCommentsEmptyState({super.key, required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Column(
      children: [
        const SizedBox(height: 130),
        const Center(
          child: Text(
            '첫 댓글을 남겨보세요',
            style: TextStyle(
              fontSize: 16,
              color: AppColors.textTertiary,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
        const SizedBox(height: 24),
        Center(
          child: InkWell(
            onTap: onTap,
            borderRadius: BorderRadius.circular(12),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              decoration: BoxDecoration(
                color: colorScheme.surfaceContainerHigh,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.edit_outlined, size: 24, color: colorScheme.onSurfaceVariant),
                  const SizedBox(width: 10),
                  Text(
                    '댓글 쓰기',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w800,
                      color: colorScheme.onSurface,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}
