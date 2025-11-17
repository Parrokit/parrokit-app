// lib/services/auth_repository.dart (지금은 한 파일 안에 두고, 나중에 분리해도 됨)

import 'package:firebase_auth/firebase_auth.dart' as fb;
import 'package:parrokit/data/local/prefs/user_prefs.dart';
import 'package:parrokit/data/models/user.dart';
import 'package:parrokit/services/firebase_auth_service.dart';
import 'package:parrokit/services/firebase_user_service.dart';


/// 앱 도메인 기준의 인증/유저 레포지토리.
///
/// 책임:
/// - FirebaseAuthService 를 이용해 이메일 회원가입/로그인 수행
/// - UserPrefs 를 통해 로컬에 PaUser 저장/로드
/// - 코인/게스트 유저/이메일 인증 상태 등 **앱에서 쓰는 유저 상태 관리**
class UserRepository {
  final UserPrefs _userPrefs;
  final FirebaseAuthService _authService;
  final FirebaseUserService _firebaseUserService;
  const UserRepository(
      this._userPrefs,
      this._authService,
      this._firebaseUserService,
      );

  /// 현재 로컬에 저장된 유저를 반환합니다.
  /// 저장된 유저가 없으면 null을 반환합니다.
  Future<PaUser?> getCurrentUser() async {
    return _userPrefs.loadUser();
  }

  /// 이메일 + 비밀번호로 회원가입을 수행합니다.
  /// - Firebase Auth 에 사용자 생성
  /// - 생성된 사용자 정보를 기반으로 PaUser 생성
  /// - 로컬(UserPrefs)에 저장
  /// - 필요시 이메일 인증 메일 발송
  Future<PaUser> signUpWithEmail({
    required String email,
    required String password,
    bool sendEmailVerification = true,
  }) async {
    final cred = await _authService.signUpWithEmail(
      email: email,
      password: password,
    );

    final fbUser = cred.user;
    if (fbUser == null) {
      throw StateError('FirebaseAuth: user is null after signUp');
    }

    await _firebaseUserService.initUserDocument(
      uid: fbUser.uid,
      email: fbUser.email ?? email,
    );

    if (sendEmailVerification && !fbUser.emailVerified) {
      await fbUser.sendEmailVerification();
    }

    final now = DateTime.now();
    final user = PaUser(
      id: fbUser.uid,
      displayName: fbUser.displayName,
      email: fbUser.email,
      coins: 0, // 코인은 이후 Firestore 연동 시 확장
      createdAt: now,
      updatedAt: now,
    );

    await _userPrefs.saveUser(user);
    return user;
  }

  /// 이메일 + 비밀번호로 로그인합니다.
  /// - Firebase Auth 에 로그인 요청
  /// - 로그인된 Firebase User 로부터 PaUser 를 구성
  /// - 로컬(UserPrefs)에 저장
  Future<PaUser> signInWithEmail({
    required String email,
    required String password,
  }) async {
    final cred = await _authService.signInWithEmail(
      email: email,
      password: password,
    );

    final fbUser = cred.user;
    if (fbUser == null) {
      throw StateError('FirebaseAuth: user is null after signIn');
    }

    // 기존에 로컬에 저장된 유저가 있다면 coins 를 이어받도록 시도
    final existingLocal = await _userPrefs.loadUser();

    final user = PaUser(
      id: fbUser.uid,
      displayName: fbUser.displayName,
      email: fbUser.email,
      coins: existingLocal?.coins ?? 0,
      createdAt: existingLocal?.createdAt,
      updatedAt: DateTime.now(),
    );

    await _userPrefs.saveUser(user);
    return user;
  }

  /// 비밀번호 재설정 이메일을 전송합니다.
  Future<void> sendPasswordResetEmail(String email) async {
    await _authService.sendPasswordResetEmail(email);
  }

  /// 현재 로그인된 Firebase 유저 기준으로 이메일 인증 여부를 반환합니다.
  Future<bool> isEmailVerified() async {
    final fbUser = _authService.currentUser;
    return fbUser?.emailVerified ?? false;
  }

  /// 현재 로그인된 Firebase 유저에게 이메일 인증 메일을 다시 보냅니다.
  Future<void> sendEmailVerification() async {
    final fbUser = _authService.currentUser;
    if (fbUser != null && !fbUser.emailVerified) {
      await fbUser.sendEmailVerification();
    }
  }

  /// Firebase 에서 현재 유저 정보를 새로고침하고,
  /// 그 결과를 기반으로 PaUser 를 갱신합니다.
  /// (예: 이메일 인증을 완료하고 앱으로 돌아온 경우)
  Future<PaUser?> reloadFirebaseUser() async {
    final fbUser = _authService.currentUser;
    if (fbUser == null) {
      return null;
    }

    await _authService.reloadCurrentUser();
    final refreshed = _authService.currentUser;
    if (refreshed == null) {
      return null;
    }

    final existingLocal = await _userPrefs.loadUser();
    final user = PaUser(
      id: refreshed.uid,
      displayName: refreshed.displayName ?? existingLocal?.displayName,
      email: refreshed.email ?? existingLocal?.email,
      coins: existingLocal?.coins ?? 0,
      createdAt: existingLocal?.createdAt,
      updatedAt: DateTime.now(),
    );

    await _userPrefs.saveUser(user);
    return user;
  }

  /// 게스트 유저로 로그인합니다.
  /// - 이미 로컬에 유저가 있으면 그대로 반환.
  /// - 없으면 새 guest 유저를 만들고 저장한 뒤 반환.
  Future<PaUser> signInAsGuest() async {
    final existing = await _userPrefs.loadUser();
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
    final current = await _userPrefs.loadUser();
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
  /// - Firebase 에서 로그아웃
  /// - 로컬에 저장된 유저 정보를 모두 삭제합니다.
  Future<void> signOut() async {
    await _authService.signOut();
    await _userPrefs.clear();
  }
}