import 'dart:convert';
import 'package:crypto/crypto.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:sign_in_with_apple/sign_in_with_apple.dart';

class AppleSsoService {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  /// 임의의 nonce 문자열(재생 공격 방지용)을 생성합니다.
  String _generateNonce([int length = 32]) {
    const charset = '0123456789ABCDEFGHIJKLMNOPQRSTUVXYZabcdefghijklmnopqrstuvwxyz-._';
    final random = List.generate(length, (_) => charset[DateTime.now().microsecondsSinceEpoch % charset.length]).join();
    return random;
  }

  /// 문자열을 SHA-256으로 해싱합니다.
  String _sha256ofString(String input) {
    final bytes = utf8.encode(input);
    final digest = sha256.convert(bytes);
    return digest.toString();
  }

  /// Apple 로그인을 수행하고 Firebase UserCredential을 반환합니다.
  Future<UserCredential?> getCredentialAndSignIn() async {
    try {
      final rawNonce = _generateNonce();
      final hashedNonce = _sha256ofString(rawNonce);

      // 1. Apple 로그인 시도 (네이티브 화면 호출)
      final AuthorizationCredentialAppleID appleCredential = await SignInWithApple.getAppleIDCredential(
        scopes: [
          AppleIDAuthorizationScopes.email,
          AppleIDAuthorizationScopes.fullName,
        ],
        nonce: hashedNonce,
      );

      // 2. ID Token 확인
      final idToken = appleCredential.identityToken;
      if (idToken == null) {
        throw Exception("Apple Sign In failed: ID Token is null");
      }

      // 3. Firebase용 OAuthCredential 생성
      final AuthCredential credential = OAuthProvider('apple.com').credential(
        idToken: idToken,
        rawNonce: rawNonce,
        accessToken: appleCredential.authorizationCode, // Firebase에서 일부 기능에 사용할 수 있음
      );

      // 4. Firebase 로그인 수행
      final UserCredential userCredential = await _auth.signInWithCredential(credential);

      // (선택) 처음 가입 시 이름 업데이트
      if (appleCredential.givenName != null || appleCredential.familyName != null) {
        final name = "${appleCredential.familyName ?? ''} ${appleCredential.givenName ?? ''}".trim();
        if (name.isNotEmpty && userCredential.user?.displayName == null) {
          await userCredential.user?.updateDisplayName(name);
        }
      }

      return userCredential;
    } catch (e) {
      debugPrint("Apple SSO Error: $e");
      return null;
    }
  }
}
