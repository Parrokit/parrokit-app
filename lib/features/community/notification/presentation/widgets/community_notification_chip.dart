import 'package:flutter/material.dart';

class CommunityNotificationChip extends StatelessWidget {
  final String boardType;

  const CommunityNotificationChip({
    super.key,
    required this.boardType,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final label = _labelForBoardType(boardType);

    return Chip(
      label: Text(
        label,
        style: theme.textTheme.labelMedium?.copyWith(
          fontWeight: FontWeight.w700,
          color: theme.colorScheme.primary,
        ),
      ),
      side: BorderSide(color: theme.colorScheme.primary.withValues(alpha: 0.16)),
      backgroundColor: theme.colorScheme.primaryContainer.withValues(alpha: 0.4),
      materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
      visualDensity: VisualDensity.compact,
      padding: EdgeInsets.zero,
    );
  }

  String _labelForBoardType(String boardType) {
    switch (boardType) {
      case 'question':
        return '질문';
      case 'vote':
        return '투표';
      default:
        return '일반';
    }
  }
}
