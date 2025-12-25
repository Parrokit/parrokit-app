// lib/services/firebase_user_service.dart

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:parrokit/data/models/user.dart';

class FirebaseUserService {
  final FirebaseFirestore _firestore;

  FirebaseUserService({FirebaseFirestore? firestore})
      : _firestore = firestore ?? FirebaseFirestore.instance;

  Future<void> initUserDocument({
    required String uid,
    required String email,
  }) async {
    final docRef = _firestore.collection('users').doc(uid);

    await docRef.set({
      'email': email,
      'createdAt': FieldValue.serverTimestamp(),
      'coins': 0,
      'isPremium': false,
      'lastPurchaseAt': null,
    }, SetOptions(merge: true)); // 이미 있으면 덮어쓰지 않고 병합
  }

  Future<Map<String, dynamic>?> getUserMeta(String uid) async {
    final snap = await _firestore.collection('users').doc(uid).get();
    return snap.data();
  }

  Future<void> updateUserCoins({
    required String uid,
    required int coins,
  }) async {
    await _firestore.collection('users').doc(uid).update({
      'coins': coins,
      'lastPurchaseAt': FieldValue.serverTimestamp(),
    });
  }

  Future<PaUser?> loadUserDocument({required String uid}) async {
    final snap = await _firestore.collection('users').doc(uid).get();
    if (!snap.exists) {
      return null;
    }

    final data = snap.data()!;
    return PaUser(
      id: uid,
      displayName: data['displayName'],
      email: data['email'],
      coins: data['coins'] ?? 0,
      createdAt: (data['createdAt'] as Timestamp?)?.toDate(),
      updatedAt: DateTime.now(),
    );
  }
}