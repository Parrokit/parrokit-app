// ============================================================================
// lib/core/services/daily_limit_service.dart
// ============================================================================
//
// [역할]
// 기능별 하루 사용 횟수 제한 추적.
// SharedPreferences에 날짜+카운트를 저장하고, 자정마다 자동 초기화.
//
// [사용법]
// final ok = await DailyLimitService.consume('stt', limit: 3);
// if (!ok) { /* 제한 초과 처리 */ }
//
// [레이어]
// Core Layer > Services
// ============================================================================

import 'package:shared_preferences/shared_preferences.dart';

class DailyLimitService {
  static String _dateKey(String feature) => 'daily_${feature}_date';
  static String _countKey(String feature) => 'daily_${feature}_count';

  static String _todayString() {
    final now = DateTime.now();
    return '${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}';
  }

  /// 오늘 [feature] 기능을 사용한 횟수를 반환합니다.
  static Future<int> getUsed(String feature) async {
    final prefs = await SharedPreferences.getInstance();
    final storedDate = prefs.getString(_dateKey(feature)) ?? '';
    if (storedDate != _todayString()) return 0;
    return prefs.getInt(_countKey(feature)) ?? 0;
  }

  /// 오늘 [feature] 기능의 남은 횟수를 반환합니다.
  static Future<int> getRemaining(String feature, {required int limit}) async {
    final used = await getUsed(feature);
    return (limit - used).clamp(0, limit);
  }

  /// 사용 가능하면 카운트를 1 증가시키고 true를 반환합니다.
  /// 이미 [limit]에 도달했으면 false를 반환합니다.
  static Future<bool> consume(String feature, {required int limit}) async {
    final prefs = await SharedPreferences.getInstance();
    final today = _todayString();
    final storedDate = prefs.getString(_dateKey(feature)) ?? '';

    int count;
    if (storedDate != today) {
      // 날짜가 바뀌었으면 초기화
      count = 0;
      await prefs.setString(_dateKey(feature), today);
    } else {
      count = prefs.getInt(_countKey(feature)) ?? 0;
    }

    if (count >= limit) return false;

    await prefs.setInt(_countKey(feature), count + 1);
    return true;
  }

  /// 테스트/디버그용: 특정 기능의 오늘 사용량을 초기화합니다.
  static Future<void> reset(String feature) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_dateKey(feature));
    await prefs.remove(_countKey(feature));
  }
}
