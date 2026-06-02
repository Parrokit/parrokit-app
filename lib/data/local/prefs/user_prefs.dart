// lib/data/local/prefs/user_prefs.dart

import 'package:shared_preferences/shared_preferences.dart';
import 'package:parrokit/data/models/user.dart';

/// 앱 로컬에 "현재 유저"의 최소 정보를 저장/로드하는 헬퍼.
///
/// 여기서는:
/// - userId
/// - displayName
/// - email
/// - parrots (패롯)
/// - crackers (크래커)
/// 정도만 다룹니다.
/// 실제 도메인 데이터는 Firestore 등에서 관리하고,
/// 이 클래스는 로그인/식별 및 UI 초기 로딩 속도 향상을 위한 로컬 캐시로 사용합니다.
class UserPrefs {
  static const _keyUserId = 'user.id';
  static const _keyDisplayName = 'user.displayName';
  static const _keyEmail = 'user.email';
  static const _keyPhotoUrl = 'user.photoUrl';
  static const _keyParrots = 'user.parrots';
  static const _keyCrackers = 'user.crackers';
  static const _keyUnreadNotificationCount = 'user.unreadNotificationCount';
  static const _keyBlockedUserIds = 'user.blockedUserIds';
  static const _keyLastNicknameChangedAt = 'user.lastNicknameChangedAt';

  final SharedPreferences _prefs;

  UserPrefs(this._prefs);

  /// 현재 로컬에 저장된 유저가 있다면 AppUser로 복원합니다.
  /// userId가 없으면 "로그인된 유저 없음"으로 간주하고 null을 반환합니다.
  AppUser? loadUser() {
    final id = _prefs.getString(_keyUserId);
    if (id == null || id.isEmpty) {
      return null;
    }

    final displayName = _prefs.getString(_keyDisplayName);
    final email = _prefs.getString(_keyEmail);
    final photoUrl = _prefs.getString(_keyPhotoUrl);
    final parrots = _prefs.getInt(_keyParrots) ?? 0;
    final crackers = _prefs.getInt(_keyCrackers) ?? 0;
    final unreadNotificationCount = _prefs.getInt(_keyUnreadNotificationCount) ?? 0;
    final blockedUserIds = _prefs.getStringList(_keyBlockedUserIds) ?? const [];
    
    final lastNicknameStr = _prefs.getString(_keyLastNicknameChangedAt);
    final lastNicknameChangedAt = lastNicknameStr != null ? DateTime.tryParse(lastNicknameStr) : null;

    return AppUser(
      id: id,
      displayName: displayName,
      email: email,
      photoUrl: photoUrl,
      parrots: parrots,
      crackers: crackers,
      unreadNotificationCount: unreadNotificationCount,
      blockedUserIds: blockedUserIds,
      lastNicknameChangedAt: lastNicknameChangedAt,
    );
  }

  /// 현재 유저 정보를 통째로 저장합니다.
  Future<void> saveUser(AppUser user) async {
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

    if (user.photoUrl != null) {
      await _prefs.setString(_keyPhotoUrl, user.photoUrl!);
    } else {
      await _prefs.remove(_keyPhotoUrl);
    }

    await _prefs.setInt(_keyParrots, user.parrots);
    await _prefs.setInt(_keyCrackers, user.crackers);
    await _prefs.setInt(_keyUnreadNotificationCount, user.unreadNotificationCount);
    await _prefs.setStringList(_keyBlockedUserIds, user.blockedUserIds);

    if (user.lastNicknameChangedAt != null) {
      await _prefs.setString(_keyLastNicknameChangedAt, user.lastNicknameChangedAt!.toIso8601String());
    } else {
      await _prefs.remove(_keyLastNicknameChangedAt);
    }
  }

  /// 로컬에 저장된 유저 정보를 모두 제거합니다.
  Future<void> clear() async {
    await Future.wait([
      _prefs.remove(_keyUserId),
      _prefs.remove(_keyDisplayName),
      _prefs.remove(_keyEmail),
      _prefs.remove(_keyPhotoUrl),
      _prefs.remove(_keyParrots),
      _prefs.remove(_keyCrackers),
      _prefs.remove(_keyUnreadNotificationCount),
      _prefs.remove(_keyBlockedUserIds),
      _prefs.remove(_keyLastNicknameChangedAt),
    ]);
  }
}
