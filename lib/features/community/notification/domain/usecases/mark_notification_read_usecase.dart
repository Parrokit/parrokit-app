import '../repositories/community_notification_repository.dart';

class MarkNotificationReadUseCase {
  final CommunityNotificationRepository _repository;

  MarkNotificationReadUseCase(this._repository);

  Future<void> execute({
    required String userId,
    required String notificationId,
  }) {
    return _repository.markAsRead(
      userId: userId,
      notificationId: notificationId,
    );
  }
}
