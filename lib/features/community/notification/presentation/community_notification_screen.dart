import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:parrokit/core/theme/app_colors.dart';
import 'package:parrokit/features/community/notification/presentation/providers/community_notification_provider.dart';
import 'package:parrokit/features/community/notification/presentation/sections/community_notification_list_section.dart';

class CommunityNotificationScreen extends StatelessWidget {
  const CommunityNotificationScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<CommunityNotificationProvider>(
      builder: (context, provider, _) {
        return Scaffold(
          backgroundColor: Colors.white,
          appBar: AppBar(
            backgroundColor: Colors.white,
            elevation: 0,
            centerTitle: true,
            leading: IconButton(
              onPressed: () => Navigator.of(context).pop(),
              icon: const Icon(
                Icons.arrow_back_ios_new_rounded,
                size: 24,
                color: Colors.black,
              ),
            ),
            title: const Text(
              '알림',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.w800,
                color: AppColors.textPrimary,
              ),
            ),
            actions: [
              TextButton(
                onPressed: provider.unreadCount == 0 ? null : provider.markAllAsRead,
                child: const Text(
                  '모두 읽음',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: AppColors.primary,
                  ),
                ),
              ),
              TextButton(
                onPressed: provider.hasNotifications
                    ? () async {
                        await provider.deleteAllNotifications();
                        if (!context.mounted) return;
                        if (provider.errorMessage == null) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('알림을 모두 삭제했습니다.')),
                          );
                        }
                      }
                    : null,
                child: const Text(
                  '모두 지우기',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: AppColors.danger,
                  ),
                ),
              ),
              IconButton(
                onPressed: provider.refresh,
                icon: const Icon(
                  Icons.refresh_rounded,
                  size: 24,
                  color: Colors.black87,
                ),
              ),
              const SizedBox(width: 4),
            ],
            bottom: const PreferredSize(
              preferredSize: Size.fromHeight(1),
              child: Divider(height: 1, color: AppColors.disabled),
            ),
          ),
          body: Column(
            children: [
              if (provider.errorMessage != null)
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  color: AppColors.danger.withValues(alpha: 0.08),
                  child: Text(
                    provider.errorMessage!,
                    style: const TextStyle(
                      fontSize: 14,
                      color: AppColors.danger,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              Expanded(
                child: CommunityNotificationListSection(
                  provider: provider,
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
