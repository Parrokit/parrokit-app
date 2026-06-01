import '../../domain/entities/activity_item.dart';
import '../../domain/repositories/activity_repository.dart';
import '../models/activity_model.dart';

class ActivityRepositoryImpl implements ActivityRepository {
  @override
  Future<List<ActivityItem>> getActivities({
    required String boardType,
    required String activityType,
  }) async {
    // API 호출을 시뮬레이션하기 위한 지연 시간
    await Future.delayed(const Duration(seconds: 1));

    // 하드코딩이 아닌 동적 더미 데이터 생성
    return List.generate(10, (index) {
      return ActivityModel(
        id: 'activity_${boardType}_${activityType}_$index',
        title: '더미 $boardType $activityType 제목 ${index + 1}',
        content: '이것은 $boardType $activityType에 대한 더미 콘텐츠입니다. 나중에 실제 API 데이터로 교체될 예정입니다.',
        createdAt: DateTime.now().subtract(Duration(days: index, hours: index * 2)),
        boardType: boardType,
        activityType: activityType,
        likeCount: (index * 7) % 50,
        commentCount: (index * 3) % 20,
        viewCount: (index * 13) % 200 + 10,
      );
    });
  }
}
