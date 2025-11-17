// lib/data/local/prefs/user_prefs.dart

// lib/data/local/prefs/user_prefs.dart

import 'package:shared_preferences/shared_preferences.dart';
import 'package:parrokit/data/models/clip_item.dart';
import 'package:parrokit/data/models/user.dart';

/// 앱 로컬에 "현재 유저"의 최소 정보를 저장/로드하는 헬퍼.
///
/// 여기서는:
/// - userId
/// - displayName
/// - email
/// - coins
/// 정도만 다룹니다.
/// 실제 도메인(클립, 에피소드, 결제 내역 등)은 drift / 서버 쪽에서 관리하고,
/// 이 클래스는 로그인/식별 및 코인 표시를 위한 가벼운 설정 저장용으로 사용합니다.
class UserPrefs {
  static const _keyUserId = 'user.id';
  static const _keyDisplayName = 'user.displayName';
  static const _keyEmail = 'user.email';
  static const _keyCoins = 'user.coins';

  final SharedPreferences _prefs;

  UserPrefs(this._prefs);

  /// 현재 로컬에 저장된 유저가 있다면 PaUser로 복원합니다.
  /// userId가 없으면 "로그인된 유저 없음"으로 간주하고 null을 반환합니다.
  PaUser? loadUser() {
    final id = _prefs.getString(_keyUserId);
    if (id == null || id.isEmpty) {
      return null;
    }

    final displayName = _prefs.getString(_keyDisplayName);
    final email = _prefs.getString(_keyEmail);
    final coins = _prefs.getInt(_keyCoins) ?? 0;

    return PaUser(
      id: id,
      displayName: displayName,
      email: email,
      coins: coins,
    );
  }

  /// 현재 유저 정보를 통째로 저장합니다.
  Future<void> saveUser(PaUser user) async {
    await _prefs.setString(_keyUserId, user.id);
    if (user.displayName != null) {
      await _prefs.setString(_keyDisplayName, user.displayName!);
    } else {
      await _prefs.remove(_keyDisplayName);
    }

    if (user.email != null) {
      await _prefs.setString(_keyEmail, user.email!);
    } else {
      await _prefs.remove(_keyEmail);
    }

    await _prefs.setInt(_keyCoins, user.coins);
  }

  /// 유저의 코인 값만 갱신합니다.
  Future<void> setCoins(int coins) async {
    await _prefs.setInt(_keyCoins, coins);
  }

  /// 코인을 delta 만큼 증감시킵니다. (음수도 허용)
  /// 현재 저장된 코인이 없다면 0을 기준으로 더합니다.
  Future<int> addCoins(int delta) async {
    final current = _prefs.getInt(_keyCoins) ?? 0;
    final updated = current + delta;
    await _prefs.setInt(_keyCoins, updated);
    return updated;
  }

  /// 로컬에 저장된 유저 정보를 모두 제거합니다.
  Future<void> clear() async {
    await Future.wait([
      _prefs.remove(_keyUserId),
      _prefs.remove(_keyDisplayName),
      _prefs.remove(_keyEmail),
      _prefs.remove(_keyCoins),
    ]);
  }
}