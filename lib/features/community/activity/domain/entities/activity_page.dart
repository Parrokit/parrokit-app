import 'activity_cursor.dart';
import 'activity_item.dart';

class ActivityPage {
  final List<ActivityItem> items;
  final bool hasMore;
  final ActivityCursor? nextCursor;

  const ActivityPage({
    required this.items,
    required this.hasMore,
    this.nextCursor,
  });
}
