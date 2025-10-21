// lib/data/prefs/onboarding_prefs.dart
import 'package:shared_preferences/shared_preferences.dart';

class OnboardingPrefs {
  static const _k = 'isOnboarded';

  static Future<bool> isOnboarded() async {
    final p = await SharedPreferences.getInstance();
    return p.getBool(_k) ?? false;
  }

  static Future<void> setOnboarded([bool value = true]) async {
    final p = await SharedPreferences.getInstance();
    await p.setBool(_k, value);
  }

  static Future<void> reset() async {
    final p = await SharedPreferences.getInstance();
    await p.remove(_k);
  }
}