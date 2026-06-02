import '../entities/community_notification_item.dart';
import '../repositories/community_notification_repository.dart';

class WatchNotificationsUseCase {
  final CommunityNotificationRepository _repository;

  WatchNotificationsUseCase(this._repository);

  Stream<List<CommunityNotificationItem>> execute(String userId) {
    return _repository.watchNotifications(userId);
  }
}
