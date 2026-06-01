import '../entities/activity_item.dart';
import '../repositories/activity_repository.dart';

class GetActivitiesUseCase {
  final ActivityRepository _repository;

  GetActivitiesUseCase(this._repository);

  Future<List<ActivityItem>> call({
    required String boardType,
    required String activityType,
  }) {
    return _repository.getActivities(
      boardType: boardType,
      activityType: activityType,
    );
  }
}
