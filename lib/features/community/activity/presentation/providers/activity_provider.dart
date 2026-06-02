import 'package:flutter/material.dart';
import '../../domain/entities/activity_item.dart';
import '../../domain/entities/activity_cursor.dart';
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

  bool _isLoadingMore = false;
  bool get isLoadingMore => _isLoadingMore;

  bool _hasMore = true;
  bool get hasMore => _hasMore;

  ActivityCursor? _nextCursor;
  String? _userId;
  String? _boardType;
  String? _activityType;
  static const int _pageSize = 20;

  Future<void> fetchActivities({
    required String userId,
    required String boardType,
    required String activityType,
  }) async {
    _userId = userId;
    _boardType = boardType;
    _activityType = activityType;
    _nextCursor = null;
    _hasMore = true;
    _activities = [];
    await _loadPage(reset: true);
  }

  Future<void> refresh() async {
    if (_userId == null || _boardType == null || _activityType == null) return;
    await fetchActivities(
      userId: _userId!,
      boardType: _boardType!,
      activityType: _activityType!,
    );
  }

  Future<void> loadMore() async {
    if (_userId == null || _boardType == null || _activityType == null) return;
    if (_isLoadingMore || !_hasMore) return;
    await _loadPage();
  }

  Future<void> _loadPage({bool reset = false}) async {
    if (_userId == null || _boardType == null || _activityType == null) return;

    _isLoading = true;
    _isLoadingMore = !reset;
    _error = null;
    notifyListeners();

    try {
      final page = await _getActivitiesUseCase(
        userId: _userId!,
        boardType: _boardType!,
        activityType: _activityType!,
        limit: _pageSize,
        startAfter: _nextCursor,
      );
      if (reset) {
        _activities = page.items;
      } else {
        _activities = [..._activities, ...page.items];
      }
      _hasMore = page.hasMore;
      _nextCursor = page.nextCursor;
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      _isLoadingMore = false;
      notifyListeners();
    }
  }
}
