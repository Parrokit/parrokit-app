import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:parrokit/core/services/firebase/firebase_messaging_service.dart';
import 'package:parrokit/core/utils/app_logger.dart';
import 'package:parrokit/features/community/notification/domain/entities/community_notification_item.dart';
import 'package:parrokit/features/community/notification/domain/usecases/delete_all_notifications_usecase.dart';
import 'package:parrokit/features/community/notification/domain/usecases/delete_notification_usecase.dart';
import 'package:parrokit/features/community/notification/domain/usecases/fetch_notifications_usecase.dart';
import 'package:parrokit/features/community/notification/domain/usecases/mark_all_notifications_read_usecase.dart';
import 'package:parrokit/features/community/notification/domain/usecases/mark_notification_read_usecase.dart';
import 'package:parrokit/features/community/notification/domain/usecases/watch_notifications_usecase.dart';

class CommunityNotificationProvider extends ChangeNotifier {
  final WatchNotificationsUseCase _watchNotificationsUseCase;
  final FetchNotificationsUseCase _fetchNotificationsUseCase;
  final MarkNotificationReadUseCase _markNotificationReadUseCase;
  final MarkAllNotificationsReadUseCase _markAllNotificationsReadUseCase;
  final DeleteNotificationUseCase _deleteNotificationUseCase;
  final DeleteAllNotificationsUseCase _deleteAllNotificationsUseCase;
  final FirebaseMessagingService _messagingService;

  StreamSubscription<List<CommunityNotificationItem>>? _subscription;

  String? _currentUserId;
  bool _isLoading = false;
  String? _errorMessage;
  List<CommunityNotificationItem> _notifications = [];
  bool _isActive = false;

  CommunityNotificationProvider({
    required WatchNotificationsUseCase watchNotificationsUseCase,
    required FetchNotificationsUseCase fetchNotificationsUseCase,
    required MarkNotificationReadUseCase markNotificationReadUseCase,
    required MarkAllNotificationsReadUseCase markAllNotificationsReadUseCase,
    required DeleteNotificationUseCase deleteNotificationUseCase,
    required DeleteAllNotificationsUseCase deleteAllNotificationsUseCase,
    required FirebaseMessagingService messagingService,
  })  : _watchNotificationsUseCase = watchNotificationsUseCase,
        _fetchNotificationsUseCase = fetchNotificationsUseCase,
        _markNotificationReadUseCase = markNotificationReadUseCase,
        _markAllNotificationsReadUseCase = markAllNotificationsReadUseCase,
        _deleteNotificationUseCase = deleteNotificationUseCase,
        _deleteAllNotificationsUseCase = deleteAllNotificationsUseCase,
        _messagingService = messagingService;

  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  List<CommunityNotificationItem> get notifications => _notifications;
  int get unreadCount => _notifications.where((item) => !item.isRead).length;
  bool get hasNotifications => _notifications.isNotEmpty;

  void syncUser(String? userId) {
    final previousUserId = _currentUserId;

    if (_currentUserId == userId) {
      return;
    }

    _currentUserId = userId;
    _errorMessage = null;
    _notifications = [];
    _stopListening();

    if (userId == null || userId.isEmpty) {
      if (previousUserId != null && previousUserId.isNotEmpty) {
        unawaited(_messagingService.clearUserToken(previousUserId));
      }
      _messagingService.dispose();
      _isLoading = false;
      _notifyListenersSafe();
      return;
    }

    _notifyListenersSafe();
    unawaited(_messagingService.syncUserToken(userId));

    if (_isActive) {
      _isLoading = true;
      _notifyListenersSafe();
      unawaited(_initForUser(userId));
    }
  }

  Future<void> activate() async {
    final userId = _currentUserId;
    if (userId == null || userId.isEmpty) return;

    if (_isActive) return;
    _isActive = true;
    _isLoading = true;
    _notifyListenersSafe();

    await _initForUser(userId);
  }

  Future<void> deactivate() async {
    _isActive = false;
    _stopListening();
    _isLoading = false;
    _notifyListenersSafe();
  }

  Future<void> refresh() async {
    final userId = _currentUserId;
    if (userId == null || userId.isEmpty) return;

    _isLoading = true;
    _notifyListenersSafe();

    try {
      final notifications = await _fetchNotificationsUseCase.execute(userId);
      _notifications = notifications;
      _errorMessage = null;
    } catch (e) {
      _errorMessage = e.toString();
      AppLogger.e(
        '[CommunityNotification][Provider] refresh failed userId=$userId',
        error: e,
      );
    } finally {
      _isLoading = false;
      _notifyListenersSafe();
    }
  }

  Future<void> markAsRead(String notificationId) async {
    final userId = _currentUserId;
    if (userId == null || userId.isEmpty || notificationId.isEmpty) return;

    try {
      await _markNotificationReadUseCase.execute(
        userId: userId,
        notificationId: notificationId,
      );
    } catch (e) {
      _errorMessage = e.toString();
      AppLogger.e(
        '[CommunityNotification][Provider] markAsRead failed notificationId=$notificationId',
        error: e,
      );
      _notifyListenersSafe();
    }
  }

  Future<void> markAllAsRead() async {
    final userId = _currentUserId;
    if (userId == null || userId.isEmpty) return;

    try {
      await _markAllNotificationsReadUseCase.execute(userId);
    } catch (e) {
      _errorMessage = e.toString();
      AppLogger.e(
        '[CommunityNotification][Provider] markAllAsRead failed userId=$userId',
        error: e,
      );
      _notifyListenersSafe();
    }
  }

  Future<void> deleteNotification(String notificationId) async {
    final userId = _currentUserId;
    if (userId == null || userId.isEmpty || notificationId.isEmpty) return;

    try {
      await _deleteNotificationUseCase.execute(
        userId: userId,
        notificationId: notificationId,
      );
    } catch (e) {
      _errorMessage = e.toString();
      AppLogger.e(
        '[CommunityNotification][Provider] deleteNotification failed notificationId=$notificationId',
        error: e,
      );
      _notifyListenersSafe();
    }
  }

  Future<void> deleteAllNotifications() async {
    final userId = _currentUserId;
    if (userId == null || userId.isEmpty) return;

    try {
      await _deleteAllNotificationsUseCase.execute(userId);
    } catch (e) {
      _errorMessage = e.toString();
      AppLogger.e(
        '[CommunityNotification][Provider] deleteAllNotifications failed userId=$userId',
        error: e,
      );
      _notifyListenersSafe();
    }
  }

  Future<void> _initForUser(String userId) async {
    try {
      final initialNotifications =
          await _fetchNotificationsUseCase.execute(userId);
      _notifications = initialNotifications;

      if (!_isActive) {
        _isLoading = false;
        _notifyListenersSafe();
        return;
      }

      _subscription = _watchNotificationsUseCase.execute(userId).listen(
        (items) {
          if (!_isActive) return;
          _notifications = items;
          _errorMessage = null;
          _isLoading = false;
          _notifyListenersSafe();
        },
        onError: (error) {
          _errorMessage = error.toString();
          _isLoading = false;
          AppLogger.e(
            '[CommunityNotification][Provider] watch stream failed userId=$userId',
            error: error,
          );
          _notifyListenersSafe();
        },
      );
    } catch (e) {
      _errorMessage = e.toString();
      AppLogger.e(
        '[CommunityNotification][Provider] init failed userId=$userId',
        error: e,
      );
    } finally {
      _isLoading = false;
      _notifyListenersSafe();
    }
  }

  void _stopListening() {
    unawaited(_subscription?.cancel());
    _subscription = null;
  }

  void _notifyListenersSafe() {
    if (hasListeners) {
      notifyListeners();
    }
  }

  @override
  void dispose() {
    _stopListening();
    _messagingService.dispose();
    super.dispose();
  }
}
