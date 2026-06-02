import '../entities/activity_page.dart';
import '../entities/activity_cursor.dart';
import '../repositories/activity_repository.dart';

class GetActivitiesUseCase {
  final ActivityRepository _repository;

  GetActivitiesUseCase(this._repository);

  Future<ActivityPage> call({
    required String userId,
    required String boardType,
    required String activityType,
    int limit = 100,
    ActivityCursor? startAfter,
  }) {
    return _repository.getActivities(
      userId: userId,
      boardType: boardType,
      activityType: activityType,
      limit: limit,
      startAfter: startAfter,
    );
  }
}
