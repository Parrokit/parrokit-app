import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:parrokit/core/shared/utils/app_logger.dart';
import 'package:parrokit/features/community/notification/data/models/community_notification_model.dart';
import 'package:parrokit/features/community/notification/domain/entities/community_notification_item.dart';
import 'package:parrokit/features/community/notification/domain/repositories/community_notification_repository.dart';

class CommunityNotificationRepositoryImpl
    implements CommunityNotificationRepository {
  final FirebaseFirestore _firestore;

  CommunityNotificationRepositoryImpl({FirebaseFirestore? firestore})
      : _firestore = firestore ?? FirebaseFirestore.instance;

  CollectionReference<Map<String, dynamic>> _collection(String userId) {
    return _firestore.collection('users').doc(userId).collection('notifications');
  }

  DocumentReference<Map<String, dynamic>> _userDoc(String userId) {
    return _firestore.collection('users').doc(userId);
  }

  @override
  Stream<List<CommunityNotificationItem>> watchNotifications(String userId) {
    if (userId.isEmpty) {
      return const Stream<List<CommunityNotificationItem>>.empty();
    }

    return _collection(userId)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map(
          (snapshot) => snapshot.docs
              .map(
                (doc) => CommunityNotificationModel.fromJson(
                  id: doc.id,
                  json: doc.data(),
                ),
              )
              .toList(),
        );
  }

  @override
  Future<List<CommunityNotificationItem>> fetchNotifications(String userId) async {
    if (userId.isEmpty) return const [];

    try {
      final snapshot = await _collection(userId)
          .orderBy('createdAt', descending: true)
          .get();

      return snapshot.docs
          .map(
            (doc) => CommunityNotificationModel.fromJson(
              id: doc.id,
              json: doc.data(),
            ),
          )
          .toList();
    } catch (e) {
      AppLogger.e(
        '[CommunityNotification][Repository] fetch failed userId=$userId',
        error: e,
      );
      return const [];
    }
  }

  @override
  Future<void> markAsRead({
    required String userId,
    required String notificationId,
  }) async {
    if (userId.isEmpty || notificationId.isEmpty) return;

    try {
      await _firestore.runTransaction((transaction) async {
        final notificationRef = _collection(userId).doc(notificationId);
        final userRef = _userDoc(userId);
        final notificationSnap = await transaction.get(notificationRef);
        if (!notificationSnap.exists) return;

        final notificationData = notificationSnap.data() ?? const {};
        final isRead = notificationData['isRead'] as bool? ?? false;
        if (isRead) return;

        transaction.set(notificationRef, {
          'isRead': true,
          'readAt': FieldValue.serverTimestamp(),
        }, SetOptions(merge: true));
        transaction.set(userRef, {
          'unreadNotificationCount': FieldValue.increment(-1),
          'updatedAt': FieldValue.serverTimestamp(),
        }, SetOptions(merge: true));
      });
    } catch (e) {
      AppLogger.e(
        '[CommunityNotification][Repository] markAsRead failed userId=$userId notificationId=$notificationId',
        error: e,
      );
      throw Exception('알림을 읽음 처리하지 못했어요.');
    }
  }

  @override
  Future<void> markAllAsRead(String userId) async {
    if (userId.isEmpty) return;

    try {
      final unreadSnapshot = await _collection(userId)
          .where('isRead', isEqualTo: false)
          .get();

      if (unreadSnapshot.docs.isEmpty) return;

      final batch = _firestore.batch();
      for (final doc in unreadSnapshot.docs) {
        batch.set(doc.reference, {
          'isRead': true,
          'readAt': FieldValue.serverTimestamp(),
        }, SetOptions(merge: true));
      }
      batch.set(_userDoc(userId), {
        'unreadNotificationCount': 0,
        'updatedAt': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));
      await batch.commit();
    } catch (e) {
      AppLogger.e(
        '[CommunityNotification][Repository] markAllAsRead failed userId=$userId',
        error: e,
      );
      throw Exception('알림 전체 읽음 처리에 실패했어요.');
    }
  }

  @override
  Future<void> deleteNotification({
    required String userId,
    required String notificationId,
  }) async {
    if (userId.isEmpty || notificationId.isEmpty) return;

    try {
      await _firestore.runTransaction((transaction) async {
        final notificationRef = _collection(userId).doc(notificationId);
        final userRef = _userDoc(userId);
        final notificationSnap = await transaction.get(notificationRef);
        if (!notificationSnap.exists) return;

        final notificationData = notificationSnap.data() ?? const {};
        final isRead = notificationData['isRead'] as bool? ?? false;

        transaction.delete(notificationRef);
        if (!isRead) {
          transaction.set(userRef, {
            'unreadNotificationCount': FieldValue.increment(-1),
            'updatedAt': FieldValue.serverTimestamp(),
          }, SetOptions(merge: true));
        }
      });
    } catch (e) {
      AppLogger.e(
        '[CommunityNotification][Repository] deleteNotification failed userId=$userId notificationId=$notificationId',
        error: e,
      );
      throw Exception('알림을 삭제하지 못했어요.');
    }
  }

  @override
  Future<void> deleteAllNotifications(String userId) async {
    if (userId.isEmpty) return;

    try {
      final snapshot = await _collection(userId).get();
      if (snapshot.docs.isEmpty) return;

      final batch = _firestore.batch();
      for (final doc in snapshot.docs) {
        batch.delete(doc.reference);
      }
      batch.set(_userDoc(userId), {
        'unreadNotificationCount': 0,
        'updatedAt': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));
      await batch.commit();
    } catch (e) {
      AppLogger.e(
        '[CommunityNotification][Repository] deleteAllNotifications failed userId=$userId',
        error: e,
      );
      throw Exception('알림 전체 삭제에 실패했어요.');
    }
  }
}
