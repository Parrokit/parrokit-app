import '../repositories/community_notification_repository.dart';

class MarkAllNotificationsReadUseCase {
  final CommunityNotificationRepository _repository;

  MarkAllNotificationsReadUseCase(this._repository);

  Future<void> execute(String userId) {
    return _repository.markAllAsRead(userId);
  }
}
