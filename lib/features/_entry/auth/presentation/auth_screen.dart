// ============================================================================
// lib/features/auth/presentation/auth_screen.dart
// ============================================================================
//
// [역할]
// 이메일 기반 인증(로그인/회원가입/비밀번호 재설정)을 처리하는 메인 화면.
// 로그인 상태에 따라 다른 UI를 표시:
//   - 로그인 전: AuthFormSection (로그인/회원가입 폼)
//   - 로그인 후: LoggedInSection (계정 정보 + 코인 충전)
//
// [아키텍처]
// Presentation Layer - UI와 사용자 인터랙션만 담당.
// 비즈니스 로직은 UserProvider를 통해 처리.
//
// [주요 패턴]
// - async gap 전에 Provider 캡처: context.read를 await 전에 호출
// - mounted 체크: async 작업 후 위젯이 dispose되었는지 확인
// ============================================================================

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:parrokit/core/router/app_router.dart';
import 'package:parrokit/core/utils/show_toast.dart';
import 'package:parrokit/features/_settings/payment/domain/payment_args.dart';
import 'package:provider/provider.dart';
import 'package:parrokit/core/provider/user_provider.dart';

import '../domain/auth_mode.dart';
import '../domain/coin_package.dart';
import 'sections/auth_form_section.dart';
import 'sections/logged_in_section.dart';

/// 이메일 기반 인증을 처리하는 메인 화면.
///
/// 로그인 상태에 따라 다른 섹션을 표시:
/// - 비로그인: [AuthFormSection] - 로그인/회원가입/비밀번호 재설정 폼
/// - 로그인됨: [LoggedInSection] - 계정 정보, 이메일 인증, 코인 충전
class AuthScreen extends StatefulWidget {
  const AuthScreen({super.key});

  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> {
  // ─────────────────────────────────────────────────────────────────
  // 폼 컨트롤러 & 상태
  // ─────────────────────────────────────────────────────────────────

  /// 이메일 입력 필드 컨트롤러
  final _emailController = TextEditingController();

  /// 비밀번호 입력 필드 컨트롤러
  final _passwordController = TextEditingController();

  /// 비밀번호 확인 입력 필드 컨트롤러 (회원가입 시에만 사용)
  final _passwordConfirmController = TextEditingController();

  /// 폼 유효성 검사를 위한 GlobalKey
  final _formKey = GlobalKey<FormState>();

  /// 현재 인증 모드 (로그인/회원가입/비밀번호 재설정)
  AuthMode _mode = AuthMode.signIn;

  @override
  void dispose() {
    // 메모리 누수 방지를 위해 컨트롤러 정리
    _emailController.dispose();
    _passwordController.dispose();
    _passwordConfirmController.dispose();
    super.dispose();
  }

  // ─────────────────────────────────────────────────────────────────
  // Provider 접근 (watch: 리빌드 필요 / read: 일회성 접근)
  // ─────────────────────────────────────────────────────────────────

  /// UserProvider의 로딩 상태를 구독 (watch)
  /// 상태 변경 시 위젯 자동 리빌드
  bool get _isLoading => context.watch<UserProvider>().isLoading;

  /// UserProvider의 로그인 상태를 구독 (watch)
  /// 로그인/로그아웃 시 UI 자동 전환
  bool get _isLoggedIn => context.watch<UserProvider>().isLoggedIn;

  /// 현재 모드에 따른 제출 버튼 레이블
  String get _primaryButtonLabel {
    switch (_mode) {
      case AuthMode.signIn:
        return '로그인';
      case AuthMode.signUp:
        return '회원가입';
      case AuthMode.resetPassword:
        return '비밀번호 재설정 메일 보내기';
    }
  }

  // ─────────────────────────────────────────────────────────────────
  // Actions (비즈니스 로직 호출)
  // ─────────────────────────────────────────────────────────────────

  /// 폼 제출 처리 (로그인/회원가입/비밀번호 재설정)
  ///
  /// [패턴] async gap 전에 Provider 캡처
  /// - context.read를 await 전에 호출하여 userProvider 변수에 저장
  /// - async 작업 후에는 mounted 체크 필수
  Future<void> _onSubmit() async {
    // 폼 유효성 검사 실패 시 early return
    if (!_formKey.currentState!.validate()) return;

    final email = _emailController.text.trim();
    final password = _passwordController.text;

    // ✅ [중요] async gap 전에 Provider 캡처
    // await 후에 context.read를 호출하면 위젯이 dispose된 상태일 수 있음
    final userProvider = context.read<UserProvider>();

    try {
      // 모드별 인증 처리
      switch (_mode) {
        case AuthMode.signIn:
          await userProvider.signInWithEmail(email: email, password: password);
          break;
        case AuthMode.signUp:
          await userProvider.signUpWithEmail(email: email, password: password);
          break;
        case AuthMode.resetPassword:
          await userProvider.sendPasswordResetEmail(email);
          break;
      }

      // ✅ [중요] async 후 mounted 체크
      // 위젯이 dispose된 경우 context 접근 방지
      if (!mounted) return;

      // 성공 토스트 표시
      switch (_mode) {
        case AuthMode.signIn:
          showToast(context, '로그인에 성공했습니다.');
          break;
        case AuthMode.signUp:
          showToast(context, '회원가입이 완료되었습니다. 이메일로 전송된 인증 메일을 확인해 주세요.');
          break;
        case AuthMode.resetPassword:
          showToast(context, '비밀번호 재설정 메일을 전송했습니다.');
          break;
      }
    } on FirebaseAuthException catch (e) {
      // async 작업 중 에러 발생 시에도 mounted 체크
      if (!mounted) return;

      // 세션 만료 등 특수 에러 처리
      if (e.code == 'invalid-credential') {
        showToast(context, '세션이 만료되었어요. 다시 로그인해 주세요.',
            devMsg:
                '🔥 FirebaseAuthException: code=${e.code}, message=${e.message}');
        await userProvider.signOut();
        return;
      }
      showToast(context, '오류가 발생했습니다: ${e.message}');
    }
  }

  /// 이메일 인증 상태 확인
  ///
  /// Firebase에서 최신 유저 정보를 reload한 후 인증 상태 확인
  Future<void> _checkEmailVerification() async {
    // ✅ async gap 전에 Provider 캡처
    final userProvider = context.read<UserProvider>();

    try {
      // Firebase 유저 정보 새로고침 (인증 상태 업데이트)
      await userProvider.reloadFirebaseUser();
      final verified = await userProvider.isEmailVerified();

      if (!mounted) return;
      showToast(
          context, verified ? '이메일 인증이 완료되었습니다.' : '아직 이메일 인증이 완료되지 않았습니다.');
    } catch (e) {
      if (!mounted) return;
      showToast(context, '이메일 인증 상태 확인 중 오류가 발생했습니다: $e');
    }
  }

  /// 이메일 인증 메일 재발송
  Future<void> _resendVerificationEmail() async {
    // ✅ async gap 전에 Provider 캡처
    final userProvider = context.read<UserProvider>();

    try {
      await userProvider.sendEmailVerification();
      if (!mounted) return;
      showToast(context, '이메일 인증 메일을 다시 전송했습니다.');
    } catch (e) {
      if (!mounted) return;
      showToast(context, '인증 메일 재전송 중 오류가 발생했습니다: $e');
    }
  }

  /// 로그아웃 처리
  Future<void> _onLogout() async {
    // ✅ async gap 전에 Provider 캡처
    final userProvider = context.read<UserProvider>();

    try {
      await userProvider.signOut();
      if (!mounted) return;
      showToast(context, '로그아웃되었습니다.');
    } catch (e) {
      if (!mounted) return;
      showToast(context, '로그아웃 중 오류가 발생했습니다: $e');
    }
  }

  /// 인증 모드 전환 (로그인 ↔ 회원가입 ↔ 비밀번호 재설정)
  void _switchMode(AuthMode mode) {
    if (_mode == mode) return; // 같은 모드면 무시
    setState(() => _mode = mode);
  }

  /// 코인 패키지 선택 시 결제 화면으로 이동
  ///
  /// [pkg] 선택된 코인 패키지 정보
  void _onCoinPackageSelected(CoinPackage pkg) {
    // 현재 유저 정보 (이메일 등)
    final user = context.read<UserProvider>().currentUser;

    showToast(context,
        '₩${pkg.price} 결제로 코인 ${pkg.totalCoins}개를 충전할게요. (+${pkg.bonusCoins} 보너스)');

    // 결제 화면으로 이동 (PaymentArgs 전달)
    context.push(
      AppRoutes.paymentPath,
      extra: PaymentArgs(
        merchantUid: 'pay_${DateTime.now().millisecondsSinceEpoch}',
        amount: pkg.price,
        coins: pkg.totalCoins,
        productName: '코인 ${pkg.totalCoins}개',
        buyerEmail: user?.email ?? '',
      ),
    );
  }

  // ─────────────────────────────────────────────────────────────────
  // Build (UI 렌더링)
  // ─────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    // watch로 구독하여 상태 변경 시 자동 리빌드
    final userProvider = context.watch<UserProvider>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('계정'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.go(AppRoutes.morePath),
        ),
      ),
      body: SafeArea(
        child: Center(
          // 최대 너비 제한 (태블릿/웹 대응)
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 480),
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              // 로그인 상태에 따라 다른 섹션 표시
              child: _isLoggedIn
                  ? LoggedInSection(
                      user: userProvider.currentUser,
                      coins: userProvider.coins,
                      isEmailVerified:
                          FirebaseAuth.instance.currentUser?.emailVerified ??
                              false,
                      isLoading: _isLoading,
                      onLogout: _onLogout,
                      onCheckEmailVerification: _checkEmailVerification,
                      onResendVerificationEmail: _resendVerificationEmail,
                      onCoinPackageSelected: _onCoinPackageSelected,
                    )
                  : AuthFormSection(
                      mode: _mode,
                      formKey: _formKey,
                      emailController: _emailController,
                      passwordController: _passwordController,
                      passwordConfirmController: _passwordConfirmController,
                      isLoading: _isLoading,
                      primaryButtonLabel: _primaryButtonLabel,
                      onSubmit: _onSubmit,
                      onModeChanged: _switchMode,
                    ),
            ),
          ),
        ),
      ),
    );
  }
}
