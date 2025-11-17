// lib/mvp/auth/auth_screen.dart

import 'package:flutter/material.dart';
import 'package:parrokit/utils/show_toast.dart';
import 'package:provider/provider.dart';
import 'package:parrokit/provider/user_provider.dart';

enum _AuthMode {
  signIn,
  signUp,
  resetPassword,
}

/// 이메일 기반 인증을 처리하는 기본 화면.
///
/// 기능:
/// - 이메일 + 비밀번호 회원가입
/// - 이메일 + 비밀번호 로그인
/// - 비밀번호 재설정 메일 전송
/// - 이메일 인증 여부 확인 / 인증 메일 재전송
///
/// 실제 라우팅은 pa_router.dart 에서 이 스크린을 등록해 사용하면 됩니다.
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

  _AuthMode _mode = _AuthMode.signIn;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _passwordConfirmController.dispose();
    super.dispose();
  }

  UserProvider _userProvider(BuildContext context) =>
      context.read<UserProvider>();

  bool get _isLoading => context.watch<UserProvider>().isLoading;

  bool get _isLoggedIn => context.watch<UserProvider>().isLoggedIn;

  Future<void> _onSubmit() async {
    if (!_formKey.currentState!.validate()) return;

    final email = _emailController.text.trim();
    final password = _passwordController.text;

    try {
      switch (_mode) {
        case _AuthMode.signIn:
          await _userProvider(context).signInWithEmail(
            email: email,
            password: password,
          );
          _showToast('로그인에 성공했습니다.');
          break;
        case _AuthMode.signUp:
          await _userProvider(context).signUpWithEmail(
            email: email,
            password: password,
          );
          _showToast('회원가입이 완료되었습니다. 이메일로 전송된 인증 메일을 확인해 주세요.');
          break;
        case _AuthMode.resetPassword:
          await _userProvider(context).sendPasswordResetEmail(email);
          _showToast('비밀번호 재설정 메일을 전송했습니다.');
          break;
      }
    } catch (e) {
      _showToast('오류가 발생했습니다: $e');
    }
  }

  Future<void> _checkEmailVerification() async {
    try {
      await _userProvider(context).reloadFirebaseUser();
      final verified = await _userProvider(context).isEmailVerified();
      if (verified) {
        _showToast('이메일 인증이 완료되었습니다.');
      } else {
        _showToast('아직 이메일 인증이 완료되지 않았습니다.');
      }
    } catch (e) {
      _showToast('이메일 인증 상태 확인 중 오류가 발생했습니다: $e');
    }
  }

  Future<void> _resendVerificationEmail() async {
    try {
      await _userProvider(context).sendEmailVerification();
      if(!mounted) return;
      _showToast('이메일 인증 메일을 다시 전송했습니다.');
    } catch (e) {
      _showToast('인증 메일 재전송 중 오류가 발생했습니다: $e');
    }
  }

  Future<void> _onLogout() async {
    try {
      await _userProvider(context).signOut();
      _showToast('로그아웃되었습니다.');
    } catch (e) {
      _showToast('로그아웃 중 오류가 발생했습니다: $e');
    }
  }

  void _switchMode(_AuthMode mode) {
    if (_mode == mode) return;
    setState(() {
      _mode = mode;
    });
  }

  void _showToast(String message) {
    if (!mounted) return;
    showToast(context, message);
  }

  String get _primaryButtonLabel {
    switch (_mode) {
      case _AuthMode.signIn:
        return '로그인';
      case _AuthMode.signUp:
        return '회원가입';
      case _AuthMode.resetPassword:
        return '비밀번호 재설정 메일 보내기';
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('계정'),
      ),
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 480),
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: _isLoggedIn
                  ? _buildLoggedInView(theme)
                  : _buildAuthForm(theme),
            ),
          ),
        ),
      ),
    );
  }

  /// 이미 로그인된 상태에서 보여줄 화면
  Widget _buildLoggedInView(ThemeData theme) {
    final userProvider = context.watch<UserProvider>();
    final user = userProvider.currentUser;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '내 계정',
          style: theme.textTheme.headlineSmall?.copyWith(
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          '현재 로그인된 계정 정보를 확인하고, 이메일 인증과 로그아웃을 관리할 수 있어요.',
          style: theme.textTheme.bodyMedium?.copyWith(
            color: theme.colorScheme.onSurface.withOpacity(0.7),
          ),
        ),
        const SizedBox(height: 24),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: theme.colorScheme.surfaceVariant.withOpacity(0.3),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: theme.colorScheme.outlineVariant,
            ),
          ),
          child: Row(
            children: [
              CircleAvatar(
                radius: 24,
                child: Icon(
                  Icons.person_outline,
                  color: theme.colorScheme.onPrimary,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      user?.displayName ??
                          user?.email ??
                          '로그인된 사용자',
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 4),
                    if (user?.email != null)
                      Text(
                        user!.email!,
                        style: theme.textTheme.bodySmall?.copyWith(
                          color:
                              theme.colorScheme.onSurface.withOpacity(0.7),
                        ),
                      ),
                    const SizedBox(height: 4),
                    Text(
                      '코인 ${userProvider.coins}개',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color:
                            theme.colorScheme.onSurface.withOpacity(0.7),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 24),
        if (user?.email != null) ...[
          Align(
            alignment: Alignment.centerLeft,
            child: Text(
              '이메일 인증',
              style: theme.textTheme.titleMedium,
            ),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: _isLoading ? null : _checkEmailVerification,
                  child: const Text('인증 여부 확인'),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: OutlinedButton(
                  onPressed:
                      _isLoading ? null : _resendVerificationEmail,
                  child: const Text('인증 메일 재전송'),
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
        ],
        const Spacer(),
        SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: _isLoading ? null : _onLogout,
            child: _isLoading
                ? const SizedBox(
                    width: 18,
                    height: 18,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                    ),
                  )
                : const Text('로그아웃'),
          ),
        ),
        const SizedBox(height: 8),
      ],
    );
  }

  /// 로그인/회원가입/비밀번호 재설정을 위한 폼 화면
  Widget _buildAuthForm(ThemeData theme) {
    final isReset = _mode == _AuthMode.resetPassword;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // 탭처럼 보이는 로그인/회원가입 모드 전환
        Row(
          children: [
            _AuthTab(
              label: '로그인',
              selected: _mode == _AuthMode.signIn,
              onTap: () => _switchMode(_AuthMode.signIn),
            ),
            const SizedBox(width: 12),
            _AuthTab(
              label: '회원가입',
              selected: _mode == _AuthMode.signUp,
              onTap: () => _switchMode(_AuthMode.signUp),
            ),
          ],
        ),
        const SizedBox(height: 24),
        Text(
          _mode == _AuthMode.signIn
              ? '이메일과 비밀번호로 Parrokit에 로그인하세요.'
              : _mode == _AuthMode.signUp
                  ? '자주 사용하는 이메일로 Parrokit 계정을 만들어 보세요.'
                  : '가입하신 이메일 주소로 비밀번호 재설정 링크를 보내드립니다.',
          style: theme.textTheme.bodyMedium?.copyWith(
            color: theme.colorScheme.onSurface.withOpacity(0.7),
          ),
        ),
        const SizedBox(height: 24),
        Expanded(
          child: SingleChildScrollView(
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color:
                          theme.colorScheme.surfaceVariant.withOpacity(0.3),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: theme.colorScheme.outlineVariant,
                      ),
                    ),
                    child: Column(
                      children: [
                        TextFormField(
                          controller: _emailController,
                          keyboardType: TextInputType.emailAddress,
                          decoration: const InputDecoration(
                            labelText: '이메일',
                          ),
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
                        if (!isReset) ...[
                          const SizedBox(height: 12),
                          TextFormField(
                            controller: _passwordController,
                            obscureText: true,
                            decoration: const InputDecoration(
                              labelText: '비밀번호',
                            ),
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
                        if (_mode == _AuthMode.signUp) ...[
                          const SizedBox(height: 12),
                          TextFormField(
                            controller: _passwordConfirmController,
                            obscureText: true,
                            decoration: const InputDecoration(
                              labelText: '비밀번호 확인',
                            ),
                            validator: (value) {
                              if (_mode != _AuthMode.signUp) {
                                return null;
                              }
                              if (value == null || value.isEmpty) {
                                return '비밀번호를 다시 입력해주세요.';
                              }
                              if (value != _passwordController.text) {
                                return '비밀번호가 일치하지 않습니다.';
                              }
                              return null;
                            },
                          ),
                        ],
                      ],
                    ),
                  ),
                  if (_mode == _AuthMode.signIn) ...[
                    const SizedBox(height: 12),
                    Align(
                      alignment: Alignment.centerRight,
                      child: TextButton(
                        onPressed: _isLoading
                            ? null
                            : () => _switchMode(_AuthMode.resetPassword),
                        child: const Text('비밀번호를 잊으셨나요?'),
                      ),
                    ),
                  ],
                  const SizedBox(height: 24),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: _isLoading ? null : _onSubmit,
                      child: _isLoading
                          ? const SizedBox(
                              width: 18,
                              height: 18,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                              ),
                            )
                          : Text(_primaryButtonLabel),
                    ),
                  ),
                  if (_mode == _AuthMode.resetPassword) ...[
                    const SizedBox(height: 16),
                    Center(
                      child: TextButton(
                        onPressed: _isLoading
                            ? null
                            : () => _switchMode(_AuthMode.signIn),
                        child: const Text('로그인 화면으로 돌아가기'),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _AuthTab extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;

  const _AuthTab({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final baseStyle = theme.textTheme.titleMedium;

    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 160),
        padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 4),
        decoration: BoxDecoration(
          border: Border(
            bottom: BorderSide(
              color: selected
                  ? theme.colorScheme.primary
                  : Colors.transparent,
              width: 2,
            ),
          ),
        ),
        child: Text(
          label,
          style: baseStyle?.copyWith(
            fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
            color: selected
                ? theme.colorScheme.primary
                : theme.colorScheme.onSurface.withOpacity(0.6),
          ),
        ),
      ),
    );
  }
}