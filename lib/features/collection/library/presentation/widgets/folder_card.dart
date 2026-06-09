import 'package:flutter/material.dart';
import 'package:parrokit/core/shared/theme/app_spacing.dart';

/// [역할]
/// 라이브러리 폴더 뷰의 폴더 카드 아이템.
class FolderCard extends StatelessWidget {
  const FolderCard({
    super.key,
    required this.name,
    required this.onTap,
    this.deleteMode = false,
    this.isGridView = true,
  });

  final String name;
  final VoidCallback onTap;
  final bool deleteMode;
  final bool isGridView;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return InkWell(
      borderRadius: BorderRadius.circular(14),
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: deleteMode
              ? cs.errorContainer.withValues(alpha: 0.3)
              : cs.surface,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: deleteMode ? cs.error : cs.outlineVariant,
            width: deleteMode ? 1.2 : 0.8,
          ),
        ),
        padding: const EdgeInsets.all(AppSpacing.md),
        child: isGridView
            ? Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    deleteMode ? Icons.delete_outline_rounded : Icons.folder_rounded,
                    size: 28,
                    color: deleteMode ? cs.error : null,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    name,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          fontWeight: FontWeight.w700,
                          color: deleteMode ? cs.error : null,
                        ),
                  ),
                ],
              )
            : Row(
                children: [
                  const SizedBox(width: 8),
                  Icon(
                    deleteMode ? Icons.delete_outline_rounded : Icons.folder_rounded,
                    size: 28,
                    color: deleteMode ? cs.error : null,
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Text(
                      name,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w700,
                            color: deleteMode ? cs.error : null,
                          ),
                    ),
                  ),
                ],
              ),
      ),
    );
  }
}
