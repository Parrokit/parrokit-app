// ============================================================================
// lib/data/local/prefs/intro_prefs.dart
// ============================================================================
//
// [역할]
// 인트로(앱 가이드) 시청 여부 저장소 래퍼.
// SharedPreferences를 사용하여 1회성 시청 여부 저장.
//
// [레이어]
// Data Layer > Local > Prefs
// ============================================================================

import 'package:shared_preferences/shared_preferences.dart';

/// 인트로 시청 여부 저장소 래퍼.
class IntroPrefs {
  static const _key = 'hasSeenIntro';

  /// 인트로를 봤는지 확인
  static Future<bool> hasSeen() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_key) ?? false;
  }

  /// 인트로 시청 완료 표시
  static Future<void> markAsSeen([bool value = true]) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_key, value);
  }

  /// 리셋 (테스트용)
  static Future<void> reset() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_key);
  }
}
