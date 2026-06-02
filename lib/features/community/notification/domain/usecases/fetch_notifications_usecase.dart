import '../entities/community_notification_item.dart';
import '../repositories/community_notification_repository.dart';

class FetchNotificationsUseCase {
  final CommunityNotificationRepository _repository;

  FetchNotificationsUseCase(this._repository);

  Future<List<CommunityNotificationItem>> execute(String userId) {
    return _repository.fetchNotifications(userId);
  }
}
