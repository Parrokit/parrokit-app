// lib/services/firebase_user_service.dart

import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:parrokit/data/models/user.dart';

class FirebaseUserService {
  final FirebaseFirestore _firestore;

  FirebaseUserService({FirebaseFirestore? firestore})
      : _firestore = firestore ?? FirebaseFirestore.instance;

  Future<void> initUserDocument({
    required String uid,
    required String email,
    String? photoUrl,
  }) async {
    final docRef = _firestore.collection('users').doc(uid);

    await docRef.set({
      'email': email,
      if (photoUrl != null) 'photoUrl': photoUrl,
      'createdAt': FieldValue.serverTimestamp(),
      'coins': 0,
      'unreadNotificationCount': 0,
      'blockedUserIds': <String>[],
      'fcmTokens': <String>[],
      'isPremium': false,
      'lastPurchaseAt': null,
    }, SetOptions(merge: true)); // 이미 있으면 덮어쓰지 않고 병합
  }

  Future<Map<String, dynamic>?> getUserMeta(String uid) async {
    final snap = await _firestore.collection('users').doc(uid).get();
    return snap.data();
  }

  Future<void> updateUserEconomy({
    required String uid,
    required int parrots,
    required int crackers,
  }) async {
    await _firestore.collection('users').doc(uid).update({
      'parrots': parrots,
      'crackers': crackers,
      'lastPurchaseAt': FieldValue.serverTimestamp(),
    });
  }

  Future<void> exchangeCurrency({
    required String uid,
    required int amountToDeduct,
    required int amountToAdd,
    required bool isParrotsToCrackers,
  }) async {
    final userRef = _firestore.collection('users').doc(uid);
    
    await _firestore.runTransaction((transaction) async {
      final snapshot = await transaction.get(userRef);
      if (!snapshot.exists) {
        throw Exception('유저 정보를 찾을 수 없습니다.');
      }
      
      final data = snapshot.data()!;
      int currentParrots = (data['parrots'] as num?)?.toInt() ?? 0;
      int currentCrackers = (data['crackers'] as num?)?.toInt() ?? 0;
      
      if (isParrotsToCrackers) {
        if (currentParrots < amountToDeduct) {
          throw Exception('보유하신 패롯이 부족합니다.');
        }
        currentParrots -= amountToDeduct;
        currentCrackers += amountToAdd;
      } else {
        if (currentCrackers < amountToDeduct) {
          throw Exception('보유하신 크래커가 부족합니다.');
        }
        currentCrackers -= amountToDeduct;
        currentParrots += amountToAdd;
      }
      
      transaction.update(userRef, {
        'parrots': currentParrots,
        'crackers': currentCrackers,
        'updatedAt': FieldValue.serverTimestamp(),
      });
    });
  }

  Future<void> updateUserPhoto({
    required String uid,
    required String? photoUrl,
  }) async {
    await _firestore.collection('users').doc(uid).update({
      'photoUrl': photoUrl,
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }

  Future<void> updateUserDisplayName({
    required String uid,
    required String? newNickname,
    String? oldNickname,
  }) async {
    // 닉네임 관리를 위해 기존 메서드 업그레이드
    if (newNickname == null || newNickname.isEmpty) return;
    
    // Batch 를 이용해 유저 문서와 닉네임 레지스트리를 동시 업데이트
    final batch = _firestore.batch();
    
    // 1. 유저 문서 업데이트 (lastNicknameChangedAt 기록)
    final userRef = _firestore.collection('users').doc(uid);
    batch.update(userRef, {
      'displayName': newNickname,
      'updatedAt': FieldValue.serverTimestamp(),
      'lastNicknameChangedAt': FieldValue.serverTimestamp(),
    });
    
    // 2. 새 닉네임 선점 (nicknames 컬렉션)
    final newNickRef = _firestore.collection('nicknames').doc(newNickname);
    batch.set(newNickRef, {
      'uid': uid,
      'createdAt': FieldValue.serverTimestamp(),
    });
    
    // 3. 기존 닉네임 해제 (nicknames 컬렉션)
    if (oldNickname != null && oldNickname.isNotEmpty) {
      final oldNickRef = _firestore.collection('nicknames').doc(oldNickname);
      batch.delete(oldNickRef);
    }
    
    await batch.commit();
  }

  Future<void> blockUser({
    required String uid,
    required String blockedUserId,
  }) async {
    final userRef = _firestore.collection('users').doc(uid);

    await _firestore.runTransaction((transaction) async {
      final snapshot = await transaction.get(userRef);
      if (!snapshot.exists) {
        throw Exception('유저 정보를 찾을 수 없습니다.');
      }

      transaction.update(userRef, {
        'blockedUserIds': FieldValue.arrayUnion([blockedUserId]),
        'updatedAt': FieldValue.serverTimestamp(),
      });
    });
  }

  Future<void> addFcmToken({
    required String uid,
    required String token,
  }) async {
    if (token.isEmpty) return;

    await _firestore.collection('users').doc(uid).set({
      'fcmTokens': FieldValue.arrayUnion([token]),
      'updatedAt': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));
  }

  Future<void> removeFcmToken({
    required String uid,
    required String token,
  }) async {
    if (token.isEmpty) return;

    await _firestore.collection('users').doc(uid).set({
      'fcmTokens': FieldValue.arrayRemove([token]),
      'updatedAt': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));
  }

  Future<int> syncUnreadNotificationCount({required String uid}) async {
    final unreadSnapshot = await _firestore
        .collection('users')
        .doc(uid)
        .collection('notifications')
        .where('isRead', isEqualTo: false)
        .get();

    final unreadCount = unreadSnapshot.docs.length;

    await _firestore.collection('users').doc(uid).set({
      'unreadNotificationCount': unreadCount,
      'updatedAt': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));

    return unreadCount;
  }

  Future<void> unblockUser({
    required String uid,
    required String blockedUserId,
  }) async {
    final userRef = _firestore.collection('users').doc(uid);

    await _firestore.runTransaction((transaction) async {
      final snapshot = await transaction.get(userRef);
      if (!snapshot.exists) {
        throw Exception('유저 정보를 찾을 수 없습니다.');
      }

      transaction.update(userRef, {
        'blockedUserIds': FieldValue.arrayRemove([blockedUserId]),
        'updatedAt': FieldValue.serverTimestamp(),
      });
    });
  }

  /// 닉네임 중복 확인 (이미 해당 문서가 있으면 누군가 사용 중)
  Future<bool> isNicknameAvailable(String nickname) async {
    if (nickname.isEmpty) return false;
    final doc = await _firestore.collection('nicknames').doc(nickname).get();
    return !doc.exists;
  }

  Future<AppUser?> loadUserDocument({required String uid}) async {
    final snap = await _firestore
        .collection('users')
        .doc(uid)
        .get()
        .timeout(const Duration(seconds: 5), onTimeout: () => throw TimeoutException('loadUserDocument timeout'));
    if (!snap.exists) {
      return null;
    }

    final data = snap.data()!;
    return AppUser(
      id: uid,
      displayName: data['displayName'],
      email: data['email'],
      photoUrl: data['photoUrl'],
      parrots: (data['parrots'] as num?)?.toInt() ?? 0,
      crackers: (data['crackers'] as num?)?.toInt() ?? 0,
      unreadNotificationCount:
          (data['unreadNotificationCount'] as num?)?.toInt() ?? 0,
      blockedUserIds: (data['blockedUserIds'] as List<dynamic>?)
              ?.map((value) => value.toString())
              .where((value) => value.isNotEmpty)
              .toList() ??
          const [],
      createdAt: data['createdAt'] != null
          ? (data['createdAt'] as Timestamp).toDate()
          : null,
      updatedAt: data['updatedAt'] != null
          ? (data['updatedAt'] as Timestamp).toDate()
          : null,
      lastNicknameChangedAt: data['lastNicknameChangedAt'] != null
          ? (data['lastNicknameChangedAt'] as Timestamp).toDate()
          : null,
    );
  }

  Future<void> deleteUserDocument({required String uid}) async {
    await _firestore.collection('users').doc(uid).delete();
  }

  Future<AppUser?> loadUserDocumentByNickname(String nickname) async {
    if (nickname.isEmpty) return null;

    final nicknameSnap = await _firestore.collection('nicknames').doc(nickname).get();
    if (!nicknameSnap.exists) {
      return null;
    }

    final data = nicknameSnap.data();
    final uid = data?['uid'] as String?;
    if (uid == null || uid.isEmpty) {
      return null;
    }

    return loadUserDocument(uid: uid);
  }

  Future<AppUser?> loadUserDocumentByDisplayName(String displayName) async {
    if (displayName.isEmpty) return null;

    final snapshot = await _firestore
        .collection('users')
        .where('displayName', isEqualTo: displayName)
        .limit(1)
        .get();

    if (snapshot.docs.isEmpty) {
      return null;
    }

    final doc = snapshot.docs.first;
    final data = doc.data();
    return AppUser(
      id: doc.id,
      displayName: data['displayName'],
      email: data['email'],
      photoUrl: data['photoUrl'],
      parrots: (data['parrots'] as num?)?.toInt() ?? 0,
      crackers: (data['crackers'] as num?)?.toInt() ?? 0,
      unreadNotificationCount:
          (data['unreadNotificationCount'] as num?)?.toInt() ?? 0,
      blockedUserIds: (data['blockedUserIds'] as List<dynamic>?)
              ?.map((value) => value.toString())
              .where((value) => value.isNotEmpty)
              .toList() ??
          const [],
      createdAt: data['createdAt'] != null ? (data['createdAt'] as Timestamp).toDate() : null,
      updatedAt: data['updatedAt'] != null ? (data['updatedAt'] as Timestamp).toDate() : null,
      lastNicknameChangedAt: data['lastNicknameChangedAt'] != null
          ? (data['lastNicknameChangedAt'] as Timestamp).toDate()
          : null,
    );
  }

  Stream<AppUser?> watchUserDocument({required String uid}) {
    if (uid.isEmpty) {
      return Stream<AppUser?>.value(null);
    }

    return _firestore.collection('users').doc(uid).snapshots().map((snap) {
      if (!snap.exists) {
        return null;
      }

      final data = snap.data()!;
      return AppUser(
        id: uid,
        displayName: data['displayName'],
        email: data['email'],
        photoUrl: data['photoUrl'],
        parrots: (data['parrots'] as num?)?.toInt() ?? 0,
        crackers: (data['crackers'] as num?)?.toInt() ?? 0,
        unreadNotificationCount:
            (data['unreadNotificationCount'] as num?)?.toInt() ?? 0,
        blockedUserIds: (data['blockedUserIds'] as List<dynamic>?)
                ?.map((value) => value.toString())
                .where((value) => value.isNotEmpty)
                .toList() ??
            const [],
        createdAt: data['createdAt'] != null
            ? (data['createdAt'] as Timestamp).toDate()
            : null,
        updatedAt: data['updatedAt'] != null
            ? (data['updatedAt'] as Timestamp).toDate()
            : null,
        lastNicknameChangedAt: data['lastNicknameChangedAt'] != null
            ? (data['lastNicknameChangedAt'] as Timestamp).toDate()
            : null,
      );
    });
  }

}
