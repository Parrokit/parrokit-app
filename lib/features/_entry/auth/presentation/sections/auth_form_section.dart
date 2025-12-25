// ============================================================================
// lib/features/auth/presentation/sections/auth_form_section.dart
// ============================================================================
//
// [역할]
// 로그인/회원가입/비밀번호 재설정 폼을 표시하는 섹션 위젯.
// AuthScreen에서 비로그인 상태일 때 표시됨.
//
// [레이어]
// Presentation Layer > Sections
// - 화면 전용 빌드 위젯 (순수 재사용 widgets/와 구분)
// - 부모로부터 상태와 콜백을 주입받아 표시
//
// [특징]
// - StatelessWidget: 자체 상태 없음
// - 모든 상태는 AuthScreen에서 관리
// - 콜백을 통해 부모에게 이벤트 전달
// ============================================================================

import 'package:flutter/material.dart';
import '../../domain/auth_mode.dart';
import '../widgets/auth_tab.dart';

/// 로그인/회원가입/비밀번호 재설정 폼 섹션.
///
/// [AuthScreen]에서 비로그인 상태일 때 표시.
/// 탭 선택, 입력 필드, 제출 버튼을 포함.
class AuthFormSection extends StatelessWidget {
  // ─────────────────────────────────────────────────────────────────
  // 필수 파라미터 (부모에서 주입)
  // ─────────────────────────────────────────────────────────────────

  /// 현재 인증 모드 (로그인/회원가입/비밀번호 재설정)
  final AuthMode mode;

  /// 폼 유효성 검사용 GlobalKey
  final GlobalKey<FormState> formKey;

  /// 이메일 입력 컨트롤러
  final TextEditingController emailController;

  /// 비밀번호 입력 컨트롤러
  final TextEditingController passwordController;

  /// 비밀번호 확인 입력 컨트롤러
  final TextEditingController passwordConfirmController;

  /// 로딩 상태 (버튼 비활성화용)
  final bool isLoading;

  /// 제출 버튼 레이블
  final String primaryButtonLabel;

  /// 폼 제출 콜백
  final VoidCallback onSubmit;

  /// 모드 변경 콜백
  final ValueChanged<AuthMode> onModeChanged;

  const AuthFormSection({
    super.key,
    required this.mode,
    required this.formKey,
    required this.emailController,
    required this.passwordController,
    required this.passwordConfirmController,
    required this.isLoading,
    required this.primaryButtonLabel,
    required this.onSubmit,
    required this.onModeChanged,
  });

  // ─────────────────────────────────────────────────────────────────
  // 헬퍼 메서드
  // ─────────────────────────────────────────────────────────────────

  /// 비밀번호 재설정 모드인지 여부
  bool get _isReset => mode == AuthMode.resetPassword;

  /// 현재 모드에 따른 설명 텍스트
  String get _descriptionText {
    switch (mode) {
      case AuthMode.signIn:
        return '이메일과 비밀번호로 Parrokit에 로그인하세요.';
      case AuthMode.signUp:
        return '자주 사용하는 이메일로 Parrokit 계정을 만들어 보세요.';
      case AuthMode.resetPassword:
        return '가입하신 이메일 주소로 비밀번호 재설정 링크를 보내드립니다.';
    }
  }

  // ─────────────────────────────────────────────────────────────────
  // Build
  // ─────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // ─────────────────────────────────────────────────────────────
        // 탭 선택 (로그인/회원가입)
        // ─────────────────────────────────────────────────────────────
        Row(
          children: [
            AuthTab(
              label: '로그인',
              selected: mode == AuthMode.signIn,
              onTap: () => onModeChanged(AuthMode.signIn),
            ),
            const SizedBox(width: 12),
            AuthTab(
              label: '회원가입',
              selected: mode == AuthMode.signUp,
              onTap: () => onModeChanged(AuthMode.signUp),
            ),
          ],
        ),
        const SizedBox(height: 24),

        // ─────────────────────────────────────────────────────────────
        // 설명 텍스트
        // ─────────────────────────────────────────────────────────────
        Text(
          _descriptionText,
          style: theme.textTheme.bodyMedium?.copyWith(
            color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
          ),
        ),
        const SizedBox(height: 24),

        // ─────────────────────────────────────────────────────────────
        // 폼 (스크롤 가능)
        // ─────────────────────────────────────────────────────────────
        Expanded(
          child: SingleChildScrollView(
            child: Form(
              key: formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  _buildFormFields(theme),
                  if (mode == AuthMode.signIn) _buildForgotPassword(theme),
                  const SizedBox(height: 24),
                  _buildSubmitButton(theme),
                  if (mode == AuthMode.resetPassword) _buildBackToLogin(theme),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  // ─────────────────────────────────────────────────────────────────
  // 폼 필드 빌더
  // ─────────────────────────────────────────────────────────────────

  /// 이메일/비밀번호 입력 필드 컨테이너
  Widget _buildFormFields(ThemeData theme) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.3),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: theme.colorScheme.outlineVariant),
      ),
      child: Column(
        children: [
          // 이메일 입력
          TextFormField(
            controller: emailController,
            keyboardType: TextInputType.emailAddress,
            decoration: const InputDecoration(labelText: '이메일'),
            validator: (value) {
              if (value == null || value.trim().isEmpty) {
                return '이메일을 입력해주세요.';
              }
              if (!value.contains('@')) {
                return '올바른 이메일 형식이 아닙니다.';
              }
              return null;
            },
          ),

          // 비밀번호 입력 (비밀번호 재설정 모드에서는 숨김)
          if (!_isReset) ...[
            const SizedBox(height: 12),
            TextFormField(
              controller: passwordController,
              obscureText: true,
              decoration: const InputDecoration(labelText: '비밀번호'),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return '비밀번호를 입력해주세요.';
                }
                if (value.length < 6) {
                  return '비밀번호는 6자 이상이어야 합니다.';
                }
                return null;
              },
            ),
          ],

          // 비밀번호 확인 (회원가입 모드에서만 표시)
          if (mode == AuthMode.signUp) ...[
            const SizedBox(height: 12),
            TextFormField(
              controller: passwordConfirmController,
              obscureText: true,
              decoration: const InputDecoration(labelText: '비밀번호 확인'),
              validator: (value) {
                if (mode != AuthMode.signUp) return null;
                if (value == null || value.isEmpty) {
                  return '비밀번호를 다시 입력해주세요.';
                }
                if (value != passwordController.text) {
                  return '비밀번호가 일치하지 않습니다.';
                }
                return null;
              },
            ),
          ],
        ],
      ),
    );
  }

  /// "비밀번호를 잊으셨나요?" 버튼
  Widget _buildForgotPassword(ThemeData theme) {
    return Column(
      children: [
        const SizedBox(height: 12),
        Align(
          alignment: Alignment.centerRight,
          child: TextButton(
            onPressed:
                isLoading ? null : () => onModeChanged(AuthMode.resetPassword),
            child: const Text('비밀번호를 잊으셨나요?'),
          ),
        ),
      ],
    );
  }

  /// 제출 버튼 (로그인/회원가입/비밀번호 재설정)
  Widget _buildSubmitButton(ThemeData theme) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: isLoading ? null : onSubmit,
        child: isLoading
            ? const SizedBox(
                width: 18,
                height: 18,
                child: CircularProgressIndicator(strokeWidth: 2),
              )
            : Text(primaryButtonLabel),
      ),
    );
  }

  /// "로그인 화면으로 돌아가기" 버튼 (비밀번호 재설정 모드에서만)
  Widget _buildBackToLogin(ThemeData theme) {
    return Column(
      children: [
        const SizedBox(height: 16),
        Center(
          child: TextButton(
            onPressed: isLoading ? null : () => onModeChanged(AuthMode.signIn),
            child: const Text('로그인 화면으로 돌아가기'),
          ),
        ),
      ],
    );
  }
}
