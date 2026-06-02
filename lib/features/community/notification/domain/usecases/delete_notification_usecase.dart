import '../repositories/community_notification_repository.dart';

class DeleteNotificationUseCase {
  final CommunityNotificationRepository _repository;

  DeleteNotificationUseCase(this._repository);

  Future<void> execute({
    required String userId,
    required String notificationId,
  }) {
    return _repository.deleteNotification(
      userId: userId,
      notificationId: notificationId,
    );
  }
}
