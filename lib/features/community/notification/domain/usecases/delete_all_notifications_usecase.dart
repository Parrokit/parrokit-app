import '../repositories/community_notification_repository.dart';

class DeleteAllNotificationsUseCase {
  final CommunityNotificationRepository _repository;

  DeleteAllNotificationsUseCase(this._repository);

  Future<void> execute(String userId) {
    return _repository.deleteAllNotifications(userId);
  }
}
