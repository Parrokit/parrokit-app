import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AdProvider extends ChangeNotifier {
  static const _keyAdvanceCount = 'ad_advance_count';
  static const int threshold = 10;

  SharedPreferences? _prefs;
  int _count = 0;
  bool _premium = false;

  AdProvider({required bool initialPremium}) {
    _premium = initialPremium;
    _loadPrefs();
  }

  Future<void> _loadPrefs() async {
    _prefs = await SharedPreferences.getInstance();
    final raw = _prefs!.getInt(_keyAdvanceCount) ?? 0;
    _count = _norm(raw);
    notifyListeners();
  }

  static int _norm(int v) => ((v % threshold) + threshold) % threshold;

  bool get premium => _premium;
  set premium(bool value) {
    if (_premium != value) {
      _premium = value;
      notifyListeners();
    }
  }

  int get count => _count; // ✅ getter도 변경

  /// 앞으로 n칸 이동 → 광고 노출 타이밍인지 여부 반환
  bool incrementBy(int delta) {
    if (delta <= 0 || _premium) return false;
    _count = _norm(_count + delta);
    _prefs?.setInt(_keyAdvanceCount, _count);
    notifyListeners();
    return _count == 0;
  }

  void reset() {
    _count = 0;
    _prefs?.remove(_keyAdvanceCount);
    notifyListeners();
  }
}