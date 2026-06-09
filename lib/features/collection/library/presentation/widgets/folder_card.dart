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
    this.isAddCard = false,
  });

  final String name;
  final VoidCallback onTap;
  final bool deleteMode;
  final bool isGridView;
  final bool isAddCard;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    
    // 상태별 색상
    final Color? iconColor = isAddCard 
        ? cs.primary 
        : (deleteMode ? cs.error : null);
    final Color? textColor = isAddCard 
        ? cs.primary 
        : (deleteMode ? cs.error : null);
    final Color borderColor = isAddCard
        ? cs.primary.withValues(alpha: 0.5)
        : (deleteMode ? cs.error : cs.outlineVariant);
    final double borderWidth = (deleteMode || isAddCard) ? 1.2 : 0.8;
    final Color bgColor = deleteMode
        ? cs.errorContainer.withValues(alpha: 0.3)
        : (isAddCard ? cs.primaryContainer.withValues(alpha: 0.1) : cs.surface);
    final IconData iconData = isAddCard
        ? Icons.add_rounded
        : (deleteMode ? Icons.delete_outline_rounded : Icons.folder_rounded);

    return InkWell(
      borderRadius: BorderRadius.circular(14),
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: bgColor,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: borderColor,
            width: borderWidth,
          ),
        ),
        padding: const EdgeInsets.all(AppSpacing.md),
        child: isGridView
            ? Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    iconData,
                    size: 28,
                    color: iconColor,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    name,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          fontWeight: FontWeight.w700,
                          color: textColor,
                        ),
                  ),
                ],
              )
            : Row(
                children: [
                  const SizedBox(width: 8),
                  Icon(
                    iconData,
                    size: 28,
                    color: iconColor,
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Text(
                      name,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w700,
                            color: textColor,
                          ),
                    ),
                  ),
                ],
              ),
      ),
    );
  }
}
