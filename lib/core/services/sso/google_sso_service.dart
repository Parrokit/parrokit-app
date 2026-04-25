import 'package:firebase_auth/firebase_auth.dart' as fb;
import 'package:google_sign_in/google_sign_in.dart';

/// Google SSO(싱글 사인온) 연동을 전담하는 서비스.
/// - Google SDK를 이용해 인증을 진행하고 Firebase 연동에 필요한 Credential을 반환합니다.
class GoogleSsoService {
  final GoogleSignIn _googleSignIn;

  GoogleSsoService({GoogleSignIn? googleSignIn})
      : _googleSignIn = googleSignIn ?? GoogleSignIn();

  /// Google 로그인을 수행하고 Firebase용 OAuthCredential을 반환합니다.
  /// 사용자가 로그인을 취소하면 null을 반환합니다.
  Future<fb.OAuthCredential?> getCredential() async {
    // 1. Google 로그인 흐름 시작
    final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
    if (googleUser == null) {
      // 사용자가 로그인을 취소함
      return null;
    }

    // 2. 인증 정보 요청
    final GoogleSignInAuthentication googleAuth =
        await googleUser.authentication;

    // 3. Firebase 인증 정보(Credential) 생성 후 반환
    return fb.GoogleAuthProvider.credential(
      accessToken: googleAuth.accessToken,
      idToken: googleAuth.idToken,
    );
  }

  /// Google 계정 로그아웃
  Future<void> signOut() async {
    await _googleSignIn.signOut();
  }
}
