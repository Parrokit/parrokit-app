import 'package:flutter/material.dart';
import '../../domain/entities/activity_item.dart';
import '../../domain/usecases/get_activities_usecase.dart';
import '../../data/repositories/activity_repository_impl.dart';

class ActivityProvider extends ChangeNotifier {
  final GetActivitiesUseCase _getActivitiesUseCase;

  ActivityProvider({GetActivitiesUseCase? getActivitiesUseCase})
      : _getActivitiesUseCase = getActivitiesUseCase ?? GetActivitiesUseCase(ActivityRepositoryImpl());

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  String? _error;
  String? get error => _error;

  List<ActivityItem> _activities = [];
  List<ActivityItem> get activities => _activities;

  Future<void> fetchActivities({
    required String userId,
    required String boardType,
    required String activityType,
    int limit = 100,
  }) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _activities = await _getActivitiesUseCase(
        userId: userId,
        boardType: boardType,
        activityType: activityType,
        limit: limit,
      );
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
