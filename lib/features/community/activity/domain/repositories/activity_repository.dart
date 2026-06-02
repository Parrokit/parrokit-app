import '../entities/activity_page.dart';
import '../entities/activity_cursor.dart';

abstract class ActivityRepository {
  Future<ActivityPage> getActivities({
    required String userId,
    required String boardType,
    required String activityType,
    int limit,
    ActivityCursor? startAfter,
  });
}
