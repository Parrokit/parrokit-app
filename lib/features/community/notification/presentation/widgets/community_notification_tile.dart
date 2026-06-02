import 'package:flutter/material.dart';
import 'package:parrokit/features/community/notification/domain/entities/community_notification_item.dart';
import 'community_notification_chip.dart';

class CommunityNotificationTile extends StatelessWidget {
  final CommunityNotificationItem item;
  final VoidCallback onTap;

  const CommunityNotificationTile({
    super.key,
    required this.item,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Material(
      color: item.isRead
          ? colorScheme.surface
          : colorScheme.primary.withValues(alpha: 0.04),
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 16, 12, 16),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              _buildLeadingIcon(colorScheme),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            item.title.isEmpty ? '새 알림' : item.title,
                            style: theme.textTheme.titleSmall?.copyWith(
                              fontWeight: item.isRead ? FontWeight.w500 : FontWeight.w700,
                              color: colorScheme.onSurface,
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        _UnreadDot(isRead: item.isRead),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      item.body,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: colorScheme.onSurfaceVariant,
                        height: 1.4,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        CommunityNotificationChip(boardType: item.boardType),
                        const Spacer(),
                        Text(
                          _formatRelativeTime(item.createdAt),
                          style: theme.textTheme.labelMedium?.copyWith(
                            color: colorScheme.onSurfaceVariant,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLeadingIcon(ColorScheme colorScheme) {
    final iconData = _iconForBoardType(item.boardType);
    final backgroundColor = _backgroundColorForBoardType(colorScheme, item.boardType);
    final foregroundColor = _foregroundColorForBoardType(colorScheme, item.boardType);

    return Container(
      width: 40,
      height: 40,
      decoration: BoxDecoration(
        color: backgroundColor,
        shape: BoxShape.circle,
      ),
      child: Icon(iconData, size: 20, color: foregroundColor),
    );
  }

  IconData _iconForBoardType(String boardType) {
    switch (boardType) {
      case 'question':
        return Icons.quiz_rounded;
      case 'vote':
        return Icons.how_to_vote_rounded;
      default:
        return Icons.forum_rounded;
    }
  }

  Color _backgroundColorForBoardType(ColorScheme colorScheme, String boardType) {
    switch (boardType) {
      case 'question':
        return colorScheme.secondaryContainer.withValues(alpha: 0.55);
      case 'vote':
        return colorScheme.tertiaryContainer.withValues(alpha: 0.45);
      default:
        return colorScheme.primaryContainer.withValues(alpha: 0.45);
    }
  }

  Color _foregroundColorForBoardType(ColorScheme colorScheme, String boardType) {
    switch (boardType) {
      case 'question':
        return colorScheme.onSecondaryContainer;
      case 'vote':
        return colorScheme.onTertiaryContainer;
      default:
        return colorScheme.onPrimaryContainer;
    }
  }

  String _formatRelativeTime(DateTime createdAt) {
    final diff = DateTime.now().difference(createdAt);
    if (diff.inMinutes < 1) return '방금 전';
    if (diff.inHours < 1) return '${diff.inMinutes}분 전';
    if (diff.inDays < 1) return '${diff.inHours}시간 전';
    if (diff.inDays < 7) return '${diff.inDays}일 전';
    return '${createdAt.month}/${createdAt.day}';
  }
}

class _UnreadDot extends StatelessWidget {
  final bool isRead;

  const _UnreadDot({required this.isRead});

  @override
  Widget build(BuildContext context) {
    if (isRead) {
      return const SizedBox(width: 8);
    }

    final colorScheme = Theme.of(context).colorScheme;
    return Container(
      width: 8,
      height: 8,
      decoration: BoxDecoration(
        color: colorScheme.primary,
        shape: BoxShape.circle,
      ),
    );
  }
}
