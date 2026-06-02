import '../entities/community_notification_item.dart';

abstract class CommunityNotificationRepository {
  Stream<List<CommunityNotificationItem>> watchNotifications(String userId);
  Future<List<CommunityNotificationItem>> fetchNotifications(String userId);
  Future<void> markAsRead({
    required String userId,
    required String notificationId,
  });
  Future<void> markAllAsRead(String userId);
}
