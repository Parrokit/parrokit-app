import 'package:flutter/material.dart';
import 'package:parrokit/core/theme/app_colors.dart';
import 'package:intl/intl.dart';
import '../../domain/entities/activity_item.dart';

class ActivityCard extends StatelessWidget {
  const ActivityCard({
    super.key,
    required this.item,
    this.onTap,
  });

  final ActivityItem item;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          border: Border(
            bottom: BorderSide(color: Colors.grey[200]!),
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                _buildBoardBadge(),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    item.title,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textPrimary,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              item.content,
              style: const TextStyle(
                fontSize: 14,
                color: AppColors.textSecondary,
                height: 1.4,
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Text(
                  DateFormat('yyyy.MM.dd HH:mm').format(item.createdAt),
                  style: const TextStyle(
                    fontSize: 12,
                    color: AppColors.textTertiary,
                  ),
                ),
                const Spacer(),
                _buildCountIcon(Icons.thumb_up_alt_outlined, item.likeCount),
                const SizedBox(width: 12),
                _buildCountIcon(
                  Icons.chat_bubble_outline_rounded,
                  item.commentCount,
                ),
                const SizedBox(width: 12),
                _buildCountIcon(Icons.remove_red_eye_outlined, item.viewCount),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCountIcon(IconData icon, int count) {
    return Row(
      children: [
        Icon(icon, size: 14, color: AppColors.textTertiary),
        const SizedBox(width: 4),
        Text(
          count.toString(),
          style: const TextStyle(
            fontSize: 12,
            color: AppColors.textTertiary,
          ),
        ),
      ],
    );
  }

  Widget _buildBoardBadge() {
    Color bgColor;
    Color textColor;
    String label;

    switch (item.boardType) {
      case 'question':
        bgColor = AppColors.communityQuestionAccentSoft;
        textColor = AppColors.communityQuestionAccent;
        label = '질문';
        break;
      case 'vote':
        bgColor = AppColors.communityVoteAccentSoft;
        textColor = AppColors.communityVoteAccent;
        label = '투표';
        break;
      case 'board':
      default:
        bgColor = AppColors.communityBoardAccentSoft;
        textColor = AppColors.communityBoardAccent;
        label = '일반';
        break;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w700,
          color: textColor,
        ),
      ),
    );
  }
}
