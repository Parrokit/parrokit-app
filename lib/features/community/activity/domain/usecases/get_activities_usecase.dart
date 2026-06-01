import '../entities/activity_item.dart';
import '../repositories/activity_repository.dart';

class GetActivitiesUseCase {
  final ActivityRepository _repository;

  GetActivitiesUseCase(this._repository);

  Future<List<ActivityItem>> call({
    required String userId,
    required String boardType,
    required String activityType,
  }) {
    return _repository.getActivities(
      userId: userId,
      boardType: boardType,
      activityType: activityType,
    );
  }
}
