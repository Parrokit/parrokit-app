// ============================================================================
// lib/features/_content/shorts/data/shorts_ad_repository.dart
// ============================================================================
//
// [역할]
// 쇼츠 광고 카운트 데이터 관리.
// SharedPreferences를 이용해 스와이프 횟수 저장 및 로드.
//
// [레이어]
// Data Layer > Repository
//
// ============================================================================

import 'package:shared_preferences/shared_preferences.dart';

class ShortsAdRepository {
  static const String _keyAdvanceCount = 'ad_advance_count';
  static const String _keyLastAdTime = 'ad_last_shown_time';

  /// 저장된 스와이프 카운트를 불러옵니다.
  ///
  /// 앱 재실행 시 이전에 누적된 스와이프 횟수를 복원하여,
  /// 광고 노출 주기를 유지하는 데 사용됩니다.
  Future<int> loadCount() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt(_keyAdvanceCount) ?? 0;
  }

  /// 스와이프 카운트를 로컬 저장소에 저장합니다.
  ///
  /// [count]: 현재 누적된 스와이프 횟수 (0 ~ threshold-1)
  /// 데이터 유실을 방지하기 위해 매 변경 시마다 비동기로 저장합니다.
  Future<void> saveCount(int count) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_keyAdvanceCount, count);
  }

  /// 스와이프 카운트를 초기화합니다.
  ///
  /// 개발 편의성 또는 광고 로직 리셋이 필요할 때 사용됩니다.
  Future<void> clearCount() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_keyAdvanceCount);
  }

  /// 마지막으로 광고가 노출된 시각(ms)을 불러옵니다.
  Future<int?> loadLastAdTime() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt(_keyLastAdTime);
  }

  /// 마지막으로 광고가 노출된 시각을 저장합니다.
  Future<void> saveLastAdTime(int millisecondsSinceEpoch) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_keyLastAdTime, millisecondsSinceEpoch);
  }
}
