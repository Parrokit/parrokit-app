// ============================================================================
// lib/core/services/daily_limit_service.dart
// ============================================================================
//
// [역할]
// 기능별 하루 사용 횟수 제한 추적.
//
// [저장 위치]
// - 사용량: Firestore users/{uid}/dailyLimits.{feature}
// - 기기 잠금: Firestore devices/{deviceId} → 오늘 이 기기에서 처음 사용한 계정을 기록
//
// [멀티 계정 악용 방지]
// 오늘 이 기기에서 이미 다른 계정이 데일리를 사용했으면 consume을 차단합니다.
// 기기를 바꾼 정상 사용자는 새 기기에서 데일리를 그대로 받습니다.
//
// [구조]
// users/{uid}/dailyLimits: { stt: { date: "2026-03-14", count: 3 } }
// devices/{deviceId}: { date: "2026-03-14", userId: "uid" }
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
import 'device_id_service.dart';

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

  static Future<DocumentReference<Map<String, dynamic>>> _deviceRef() async {
    final deviceId = await DeviceIdService.getDeviceId();
    return FirebaseFirestore.instance.collection('devices').doc(deviceId);
  }

  /// 오늘 이 기기에서 현재 계정이 아닌 다른 계정이 데일리를 사용했으면 true.
  static Future<bool> _isDeviceLockedToOtherUser() async {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) return false;
    try {
      final ref = await _deviceRef();
      final snap = await ref.get();
      if (!snap.exists) return false;
      final data = snap.data()!;
      if (data['date'] != _todayString()) return false;
      return data['userId'] != uid;
    } catch (_) {
      return false;
    }
  }

  /// 기기 잠금 레코드를 오늘 날짜 + 현재 uid로 갱신합니다.
  static Future<void> _recordDeviceClaim() async {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) return;
    try {
      final ref = await _deviceRef();
      await ref.set({'date': _todayString(), 'userId': uid});
    } catch (e) {
      // ignore: avoid_print
      print('[DailyLimitService] _recordDeviceClaim failed: $e');
    }
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
  /// 오늘 다른 계정이 이 기기에서 사용했으면 0을 반환합니다.
  static Future<int> getRemaining(String feature, {required int limit}) async {
    if (await _isDeviceLockedToOtherUser()) return 0;
    final used = await getUsed(feature);
    return (limit - used).clamp(0, limit);
  }

  /// 사용 가능하면 카운트를 1 증가시키고 true를 반환합니다.
  /// 이미 [limit]에 도달했거나 오늘 다른 계정이 이 기기에서 사용했으면 false를 반환합니다.
  static Future<bool> consume(String feature, {required int limit}) async {
    return consumeN(feature, n: 1, limit: limit);
  }

  /// [n]회를 한 번에 소비합니다.
  /// 소비 후 합계가 [limit]을 초과하지 않으면 true, 초과하면 false를 반환합니다.
  /// 오늘 다른 계정이 이 기기에서 데일리를 사용했으면 false를 반환합니다.
  static Future<bool> consumeN(
    String feature, {
    required int n,
    required int limit,
  }) async {
    if (n <= 0) return true;
    final ref = _userRef();
    if (ref == null) return false;

    // 기기 잠금 체크: 오늘 다른 계정이 이미 사용했으면 차단
    if (await _isDeviceLockedToOtherUser()) return false;

    final today = _todayString();

    final success = await FirebaseFirestore.instance.runTransaction<bool>((tx) async {
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

    // 첫 소비 성공 시 기기에 오늘 날짜 + uid 기록
    if (success) await _recordDeviceClaim();
    return success;
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
