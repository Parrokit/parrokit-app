// lib/services/auth_service.dart

import 'package:parrokit/data/local/prefs/user_prefs.dart';
import 'package:parrokit/data/models/user.dart';

/// 앱 전역에서 사용하는 인증/유저 관련 진입점.
///
/// 현재 버전:
/// - 외부 인증(Firebase/Auth 서버) 없이 "게스트 유저"를 생성/복원하는 역할만 담당.
/// - UserPrefs 를 통해 로컬에 최소 정보(userId, displayName, email, coins)를 저장/로드.
///
/// 이후 확장:
/// - Firebase Auth 연동
/// - 이메일/소셜 로그인
/// - 서버와의 코인 동기화
/// 등을 이 서비스 안으로 흡수하면, UI나 Provider 쪽 코드는 그대로 둘 수 있습니다.
class AuthService {
  final UserPrefs _userPrefs;

  const AuthService(this._userPrefs);

  /// 현재 로컬에 저장된 유저를 반환합니다.
  /// 저장된 유저가 없으면 null을 반환합니다.
  Future<PaUser?> getCurrentUser() async {
    return _userPrefs.loadUser();
  }

  /// 게스트 유저로 로그인합니다.
  ///
  /// - 이미 로컬에 유저가 있으면 그대로 반환.
  /// - 없으면 새 guest 유저를 만들고 저장한 뒤 반환.
  Future<PaUser> signInAsGuest() async {
    final existing = _userPrefs.loadUser();
    if (existing != null) {
      return existing;
    }

    final now = DateTime.now();
    final newUser = PaUser(
      id: 'guest-${now.millisecondsSinceEpoch}',
      displayName: null,
      email: null,
      coins: 0,
      createdAt: now,
      updatedAt: now,
    );

    await _userPrefs.saveUser(newUser);
    return newUser;
  }

  /// 유저 정보를 저장(업데이트)합니다.
  /// 예: 서버에서 프로필/코인 값을 받아온 경우 등에 사용.
  Future<void> saveUser(PaUser user) async {
    final updated = user.copyWith(updatedAt: DateTime.now());
    await _userPrefs.saveUser(updated);
  }

  /// 코인을 delta 만큼 증감시키고, 갱신된 유저를 반환합니다.
  /// - delta는 음수도 허용됩니다.
  /// - 유저가 없으면 null을 반환합니다.
  Future<PaUser?> addCoins(int delta) async {
    final current = _userPrefs.loadUser();
    if (current == null) {
      return null;
    }

    final updated = current
        .addCoins(delta)
        .copyWith(updatedAt: DateTime.now());

    await _userPrefs.saveUser(updated);
    return updated;
  }

  /// 로그아웃/유저 초기화.
  /// 로컬에 저장된 유저 정보를 모두 삭제합니다.
  Future<void> signOut() async {
    await _userPrefs.clear();
  }
}
