// lib/services/auth_repository.dart (지금은 한 파일 안에 두고, 나중에 분리해도 됨)

// firebase_auth accessed via FirebaseAuthService
import 'package:parrokit/data/local/prefs/user_prefs.dart';
import 'package:parrokit/data/models/user.dart';
import 'package:parrokit/core/services/firebase/firebase_auth_service.dart';
import 'package:parrokit/core/services/firebase/firebase_user_service.dart';
import 'package:parrokit/core/services/sso/google_sso_service.dart';
import 'package:parrokit/core/services/sso/kakao_sso_service.dart';

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
  final GoogleSsoService _googleSsoService;
  final KakaoSsoService _kakaoSsoService;
  
  UserRepository(
    this._userPrefs,
    this._authService,
    this._firebaseUserService, {
    GoogleSsoService? googleSsoService,
    KakaoSsoService? kakaoSsoService,
  })  : _googleSsoService = googleSsoService ?? GoogleSsoService(),
        _kakaoSsoService = kakaoSsoService ?? KakaoSsoService();

  /// 현재 로컬에 저장된 유저를 반환합니다.
  /// 저장된 유저가 없으면 null을 반환합니다.
  /// 현재 로그인된 Firebase 유저 + Firestore 유저 문서를 기준으로
  /// 최신 PaUser 를 만들어서 반환합니다.
  /// - 로그인 안 되어 있으면 null
  /// - Firestore 문서가 없으면 최소한 Auth 정보 + 로컬 캐시로 구성
  Future<PaUser?> getCurrentUser() async {
    // 1. Firebase Auth 에 현재 로그인된 유저가 있는지 확인
    final fbUser = _authService.currentUser;
    if (fbUser == null) {
      // 로그인 자체가 안 되어 있으면 null
      return null;
    }

    // 2. Firestore 기준 유저 문서 조회 (timeout 시 로컬 캐시로 폴백)
    PaUser? serverUser;
    try {
      serverUser = await _firebaseUserService.loadUserDocument(uid: fbUser.uid);
    } catch (_) {
      serverUser = null;
    }

    // 3. 로컬 캐시(SharedPreferences)에 저장된 유저 (폴백용)
    final localUser = _userPrefs.loadUser();

    // 4. 최종적으로 앱에서 쓸 PaUser 조합
    final user = PaUser(
      id: fbUser.uid,
      displayName: fbUser.displayName ??
          serverUser?.displayName ??
          localUser?.displayName,
      email: fbUser.email ?? serverUser?.email ?? localUser?.email,
      photoUrl: fbUser.photoURL ?? serverUser?.photoUrl ?? localUser?.photoUrl,
      coins: serverUser?.coins ?? localUser?.coins ?? 0,
      createdAt: serverUser?.createdAt ?? localUser?.createdAt,
      updatedAt: DateTime.now(),
    );

    // 5. 최신 상태를 로컬에도 다시 캐싱
    await _userPrefs.saveUser(user);

    return user;
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

    // 1) 서버(Firestore) 기준으로 유저 문서를 먼저 조회
    // FirebaseUserService 쪽에 uid로 유저 문서를 로드하는 메서드가 있다고 가정합니다.
    // 예: Future<PaUser?> loadUserDocument({required String uid});
    final serverUser =
        await _firebaseUserService.loadUserDocument(uid: fbUser.uid);

    // 2) 로컬에 저장된 유저는 캐시/폴백 용도로만 사용
    final existingLocal = _userPrefs.loadUser();

    final user = PaUser(
      id: fbUser.uid,
      displayName: fbUser.displayName ??
          serverUser?.displayName ??
          existingLocal?.displayName,
      email: fbUser.email ?? serverUser?.email ?? existingLocal?.email,
      photoUrl:
          fbUser.photoURL ?? serverUser?.photoUrl ?? existingLocal?.photoUrl,
      coins: serverUser?.coins ?? existingLocal?.coins ?? 0,
      createdAt: serverUser?.createdAt ?? existingLocal?.createdAt,
      updatedAt: DateTime.now(),
    );

    await _userPrefs.saveUser(user);
    return user;
  }

  /// Google 계정으로 로그인 (또는 회원가입)을 수행합니다.
  Future<PaUser?> signInWithGoogle() async {
    // 1. Google OAuth 인증 얻기
    final googleCred = await _googleSsoService.getCredential();
    if (googleCred == null) {
      // 사용자가 취소함
      return null;
    }

    // 2. 파이어베이스에 해당 정보로 로그인
    final cred = await _authService.signInWithCredential(googleCred);

    final fbUser = cred.user;
    if (fbUser == null) {
      throw StateError('FirebaseAuth: user is null after signInWithGoogle');
    }

    // 3) 서버(Firestore) 기준으로 유저 문서를 먼저 조회
    PaUser? serverUser;
    try {
      serverUser = await _firebaseUserService.loadUserDocument(uid: fbUser.uid);
    } catch (_) {
      serverUser = null;
    }

    // 문서가 없으면 초기화 (회원가입의 경우)
    if (serverUser == null) {
      await _firebaseUserService.initUserDocument(
        uid: fbUser.uid,
        email: fbUser.email ?? '',
      );
    }

    // 4) 로컬 캐시 조회
    final existingLocal = _userPrefs.loadUser();

    final user = PaUser(
      id: fbUser.uid,
      displayName: fbUser.displayName ??
          serverUser?.displayName ??
          existingLocal?.displayName,
      email: fbUser.email ?? serverUser?.email ?? existingLocal?.email,
      photoUrl:
          fbUser.photoURL ?? serverUser?.photoUrl ?? existingLocal?.photoUrl,
      coins: serverUser?.coins ?? existingLocal?.coins ?? 0,
      createdAt: serverUser?.createdAt ?? existingLocal?.createdAt ?? DateTime.now(),
      updatedAt: DateTime.now(),
    );

    await _userPrefs.saveUser(user);
    return user;
  }

  /// Kakao 계정으로 로그인 (또는 회원가입)을 수행합니다.
  Future<PaUser?> signInWithKakao() async {
    // 1. Kakao OAuth 인증 얻기
    final kakaoCred = await _kakaoSsoService.getCredential();
    if (kakaoCred == null) {
      // 사용자가 취소함
      return null;
    }

    // 2. 파이어베이스에 해당 정보로 로그인
    final cred = await _authService.signInWithCredential(kakaoCred);

    final fbUser = cred.user;
    if (fbUser == null) {
      throw StateError('FirebaseAuth: user is null after signInWithKakao');
    }

    // 3) 서버(Firestore) 기준으로 유저 문서를 먼저 조회
    PaUser? serverUser;
    try {
      serverUser = await _firebaseUserService.loadUserDocument(uid: fbUser.uid);
    } catch (_) {
      serverUser = null;
    }

    // 문서가 없으면 초기화 (회원가입의 경우)
    if (serverUser == null) {
      await _firebaseUserService.initUserDocument(
        uid: fbUser.uid,
        email: fbUser.email ?? '',
      );
    }

    // 4) 로컬 캐시 조회
    final existingLocal = _userPrefs.loadUser();

    final user = PaUser(
      id: fbUser.uid,
      displayName: fbUser.displayName ??
          serverUser?.displayName ??
          existingLocal?.displayName,
      email: fbUser.email ?? serverUser?.email ?? existingLocal?.email,
      photoUrl:
          fbUser.photoURL ?? serverUser?.photoUrl ?? existingLocal?.photoUrl,
      coins: serverUser?.coins ?? existingLocal?.coins ?? 0,
      createdAt: serverUser?.createdAt ?? existingLocal?.createdAt ?? DateTime.now(),
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
    await _authService.reloadCurrentUser();
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

    // 서버의 유저 문서를 먼저 조회해서 coins 등을 동기화
    final serverUser =
        await _firebaseUserService.loadUserDocument(uid: refreshed.uid);

    final existingLocal = _userPrefs.loadUser();
    final user = PaUser(
      id: refreshed.uid,
      displayName: refreshed.displayName ??
          serverUser?.displayName ??
          existingLocal?.displayName,
      email: refreshed.email ?? serverUser?.email ?? existingLocal?.email,
      photoUrl:
          refreshed.photoURL ?? serverUser?.photoUrl ?? existingLocal?.photoUrl,
      coins: serverUser?.coins ?? existingLocal?.coins ?? 0,
      createdAt: serverUser?.createdAt ?? existingLocal?.createdAt,
      updatedAt: DateTime.now(),
    );

    await _userPrefs.saveUser(user);
    return user;
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

    final updated = current.addCoins(delta).copyWith(updatedAt: DateTime.now());

    // 1) 로컬 저장
    await _userPrefs.saveUser(updated);

    // 2) Firestore 갱신 (예시 코드)
    await _firebaseUserService.updateUserCoins(
      uid: updated.id,
      coins: updated.coins,
    );

    return updated;
  }

  /// 프로필 이미지를 업데이트합니다.
  /// - Firebase Auth 업데이트 (updatePhotoURL)
  /// - Firestore 업데이트 (photoUrl 필드)
  /// - 로컬 캐시 업데이트
  Future<void> updatePhotoUrl(String? photoUrl) async {
    // 1. Firebase Auth 업데이트
    await _authService.updatePhotoUrl(photoUrl);

    // 2. Firestore 업데이트
    final user = _authService.currentUser;
    if (user != null) {
      await _firebaseUserService.updateUserPhoto(
        uid: user.uid,
        photoUrl: photoUrl,
      );
    }

    // 3. 로컬 캐시 업데이트
    // getCurrentUser()는 Firebase 인증 유저만 반환하므로,
    // 게스트 유저(로컬 전용)인 경우 _userPrefs.loadUser()로 조회해야 함.
    final current = await getCurrentUser() ?? _userPrefs.loadUser();
    if (current != null) {
      final updated = current.copyWith(
        photoUrl: photoUrl,
        clearPhotoUrl: photoUrl == null,
        updatedAt: DateTime.now(),
      );
      await _userPrefs.saveUser(updated);
    }
  }

  /// 닉네임(DisplayName)을 업데이트합니다.
  Future<void> updateDisplayName(String? displayName) async {
    // 1. Firebase Auth 업데이트
    await _authService.updateDisplayName(displayName);

    // 2. Firestore 업데이트
    final user = _authService.currentUser;
    if (user != null) {
      await _firebaseUserService.updateUserDisplayName(
        uid: user.uid,
        displayName: displayName,
      );
    }

    // 3. 로컬 캐시 업데이트
    final current = await getCurrentUser() ?? _userPrefs.loadUser();
    if (current != null) {
      final updated = current.copyWith(
        displayName: displayName,
        clearDisplayName: displayName == null,
        updatedAt: DateTime.now(),
      );
      await _userPrefs.saveUser(updated);
    }
  }

  /// 로그아웃/유저 초기화.
  /// - Kakao SDK 에서 로그아웃
  /// - Google SDK 에서 로그아웃
  /// - Firebase 에서 로그아웃
  /// - 로컬에 저장된 유저 정보를 모두 삭제합니다.
  Future<void> signOut() async {
    await _kakaoSsoService.signOut();
    await _googleSsoService.signOut();
    await _authService.signOut();
    await _userPrefs.clear();
  }

  /// 회원탈퇴.
  /// - Firestore 유저 문서 삭제
  /// - Firebase Auth 계정 삭제
  /// - 로컬 캐시 삭제
  Future<void> deleteAccount() async {
    final uid = _authService.currentUser?.uid;
    if (uid != null) {
      await _firebaseUserService.deleteUserDocument(uid: uid);
    }
    await _authService.deleteAccount();
    await _userPrefs.clear();
  }
}
