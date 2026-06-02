import '../entities/activity_item.dart';

abstract class ActivityRepository {
  Future<List<ActivityItem>> getActivities({
    required String userId,
    required String boardType,
    required String activityType,
    int limit,
  });
}
