import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:parrokit/core/router/app_routes.dart';
import 'package:parrokit/features/community/notification/domain/entities/community_notification_item.dart';
import 'package:parrokit/features/community/notification/presentation/providers/community_notification_provider.dart';
import 'package:parrokit/features/community/notification/presentation/widgets/community_notification_empty_state.dart';
import 'package:parrokit/features/community/notification/presentation/widgets/community_notification_tile.dart';

class CommunityNotificationListSection extends StatelessWidget {
  final CommunityNotificationProvider provider;

  const CommunityNotificationListSection({
    super.key,
    required this.provider,
  });

  @override
  Widget build(BuildContext context) {
    if (provider.isLoading && provider.notifications.isEmpty) {
      return const Center(child: CircularProgressIndicator());
    }

    if (provider.notifications.isEmpty) {
      return const CommunityNotificationEmptyState();
    }

    return RefreshIndicator(
      onRefresh: provider.refresh,
      child: ListView.separated(
        physics: const AlwaysScrollableScrollPhysics(),
        itemCount: provider.notifications.length,
        separatorBuilder: (_, __) => const Divider(height: 1),
        itemBuilder: (context, index) {
          final item = provider.notifications[index];
          return CommunityNotificationTile(
            item: item,
            onTap: () async {
              await provider.markAsRead(item.id);
              if (!context.mounted) return;
              context.push(_resolveRoutePath(item));
            },
          );
        },
      ),
    );
  }

  String _resolveRoutePath(CommunityNotificationItem item) {
    switch (item.boardType) {
      case 'question':
        return AppRoutes.communityQuestionViewPathOf(item.postId);
      case 'vote':
        return AppRoutes.communityVoteViewPathOf(item.postId);
      default:
        return AppRoutes.communityBoardViewPathOf(item.postId);
    }
  }
}
