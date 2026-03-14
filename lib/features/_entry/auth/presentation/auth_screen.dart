// ============================================================================
// lib/features/auth/presentation/auth_screen.dart
// ============================================================================
//
// [역할]
// 이메일 기반 인증(로그인/회원가입/비밀번호 재설정) 화면.
// 비로그인 상태에서만 진입 (라우터 가드에 의해 보장).
// ============================================================================

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:parrokit/core/theme/app_spacing.dart';
import 'package:parrokit/core/utils/show_toast.dart';
import 'package:provider/provider.dart';
import 'package:parrokit/core/provider/user_provider.dart';

import '../domain/auth_mode.dart';
import 'sections/auth_form_section.dart';

/// 로그인/회원가입/비밀번호 재설정 화면.
class AuthScreen extends StatefulWidget {
  const AuthScreen({super.key});

  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _passwordConfirmController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  AuthMode _mode = AuthMode.signIn;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _passwordConfirmController.dispose();
    super.dispose();
  }

  bool get _isLoading => context.watch<UserProvider>().isLoading;

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

  Future<void> _onSubmit() async {
    if (!_formKey.currentState!.validate()) return;

    final email = _emailController.text.trim();
    final password = _passwordController.text;
    final userProvider = context.read<UserProvider>();

    try {
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

      if (!mounted) return;

      switch (_mode) {
        case AuthMode.signIn:
          showToast('로그인에 성공했습니다.');
          break;
        case AuthMode.signUp:
          showToast('회원가입이 완료되었습니다. 이메일로 전송된 인증 메일을 확인해 주세요.');
          break;
        case AuthMode.resetPassword:
          showToast('비밀번호 재설정 메일을 전송했습니다.');
          break;
      }
    } on FirebaseAuthException catch (e) {
      if (!mounted) return;
      switch (e.code) {
        case 'invalid-credential':
        case 'wrong-password':
          showToast('이메일 또는 비밀번호가 올바르지 않아요.');
        case 'user-not-found':
          showToast('등록되지 않은 이메일이에요.');
        case 'email-already-in-use':
          showToast('이미 사용 중인 이메일이에요.');
        case 'weak-password':
          showToast('비밀번호는 6자 이상이어야 해요.');
        case 'invalid-email':
          showToast('이메일 형식이 올바르지 않아요.');
        case 'too-many-requests':
          showToast('요청이 너무 많아요. 잠시 후 다시 시도해 주세요.');
        default:
          showToast('오류가 발생했습니다: ${e.message}');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 480),
            child: Padding(
              padding: const EdgeInsets.all(AppSpacing.lg),
              child: AuthFormSection(
                mode: _mode,
                formKey: _formKey,
                emailController: _emailController,
                passwordController: _passwordController,
                passwordConfirmController: _passwordConfirmController,
                isLoading: _isLoading,
                primaryButtonLabel: _primaryButtonLabel,
                onSubmit: _onSubmit,
                onModeChanged: (mode) => setState(() => _mode = mode),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
