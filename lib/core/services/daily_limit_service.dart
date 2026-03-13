// ============================================================================
// lib/core/services/daily_limit_service.dart
// ============================================================================
//
// [역할]
// 기능별 하루 사용 횟수 제한 추적.
// Firestore users/{uid} 문서의 dailyLimits 맵 필드에 저장.
// 구조: dailyLimits: { stt: { date: "2026-03-14", count: 3 } }
//
// [사용법]
// final ok = await DailyLimitService.consume('stt', limit: 3);
// if (!ok) { /* 제한 초과 처리 */ }
//
// [레이어]
// Core Layer > Services
// ============================================================================

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class DailyLimitService {
  static String _todayString() {
    final now = DateTime.now();
    return '${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}';
  }

  static DocumentReference<Map<String, dynamic>>? _userRef() {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) return null;
    return FirebaseFirestore.instance.collection('users').doc(uid);
  }

  /// 오늘 [feature] 기능을 사용한 횟수를 반환합니다.
  static Future<int> getUsed(String feature) async {
    final ref = _userRef();
    if (ref == null) return 0;
    final snap = await ref.get();
    if (!snap.exists) return 0;
    final entry = (snap.data()!['dailyLimits'] as Map<String, dynamic>?)?[feature] as Map<String, dynamic>?;
    if (entry == null || entry['date'] != _todayString()) return 0;
    return (entry['count'] as int? ?? 0);
  }

  /// 오늘 [feature] 기능의 남은 횟수를 반환합니다.
  static Future<int> getRemaining(String feature, {required int limit}) async {
    final used = await getUsed(feature);
    return (limit - used).clamp(0, limit);
  }

  /// 사용 가능하면 카운트를 1 증가시키고 true를 반환합니다.
  /// 이미 [limit]에 도달했으면 false를 반환합니다.
  static Future<bool> consume(String feature, {required int limit}) async {
    return consumeN(feature, n: 1, limit: limit);
  }

  /// [n]회를 한 번에 소비합니다.
  /// 소비 후 합계가 [limit]을 초과하지 않으면 true, 초과하면 false를 반환합니다.
  static Future<bool> consumeN(
    String feature, {
    required int n,
    required int limit,
  }) async {
    if (n <= 0) return true;
    final ref = _userRef();
    if (ref == null) return false;
    final today = _todayString();

    return FirebaseFirestore.instance.runTransaction<bool>((tx) async {
      final snap = await tx.get(ref);
      int count = 0;
      if (snap.exists) {
        final entry = (snap.data()!['dailyLimits'] as Map<String, dynamic>?)?[feature] as Map<String, dynamic>?;
        if (entry != null && entry['date'] == today) {
          count = entry['count'] as int? ?? 0;
        }
      }
      if (count + n > limit) return false;
      tx.update(ref, {
        'dailyLimits.$feature': {'date': today, 'count': count + n},
      });
      return true;
    });
  }

  /// 테스트/디버그용: 특정 기능의 오늘 사용량을 초기화합니다.
  static Future<void> reset(String feature) async {
    final ref = _userRef();
    if (ref == null) return;
    await ref.update({
      'dailyLimits.$feature': FieldValue.delete(),
    });
  }
}
