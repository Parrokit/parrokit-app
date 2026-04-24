import 'package:flutter/material.dart';
import '../../domain/auth_mode.dart';

class AuthFormSection extends StatelessWidget {
  final AuthMode mode;
  final GlobalKey<FormState> formKey;
  final TextEditingController emailController;
  final TextEditingController passwordController;
  final TextEditingController passwordConfirmController;
  final bool isLoading;
  final bool isAutoLogin;
  final ValueChanged<bool?> onAutoLoginChanged;
  final String primaryButtonLabel;
  final VoidCallback onSubmit;
  final ValueChanged<AuthMode> onModeChanged;

  const AuthFormSection({
    super.key,
    required this.mode,
    required this.formKey,
    required this.emailController,
    required this.passwordController,
    required this.passwordConfirmController,
    required this.isLoading,
    required this.isAutoLogin,
    required this.onAutoLoginChanged,
    required this.primaryButtonLabel,
    required this.onSubmit,
    required this.onModeChanged,
  });

  bool get _isReset => mode == AuthMode.resetPassword;

  @override
  Widget build(BuildContext context) {
    if (mode == AuthMode.signIn) {
      return SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 48),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // 로고 영역
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Image.asset('assets/logos/pa_logo.png', width: 64, height: 64),
                const SizedBox(width: 8),
                const Text(
                  '패로킷',
                  style: TextStyle(
                    fontSize: 32,
                    fontWeight: FontWeight.w900,
                    letterSpacing: -1,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 64),
            // 입력 폼
            Form(
              key: formKey,
              child: _buildFormFields(context),
            ),
            const SizedBox(height: 16),
            // 자동 로그인
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                SizedBox(
                  width: 24,
                  height: 24,
                  child: Checkbox(
                    value: isAutoLogin,
                    onChanged: onAutoLoginChanged,
                    activeColor: const Color(0xFF0066FF),
                    shape: const CircleBorder(),
                  ),
                ),
                const SizedBox(width: 8),
                const Text(
                  '자동 로그인',
                  style: TextStyle(
                    color: Color(0xFF0066FF),
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 32),
            // 로그인 버튼
            _buildSubmitButton(),
            const SizedBox(height: 32),
            // 비밀번호 재설정 | 회원가입
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                GestureDetector(
                  onTap: () => onModeChanged(AuthMode.resetPassword),
                  child: const Text(
                    '비밀번호를 잊으셨나요?',
                    style: TextStyle(
                        color: Color(0xFF0066FF),
                        fontWeight: FontWeight.bold,
                        fontSize: 13),
                  ),
                ),
                const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 8),
                  child: Text('|', style: TextStyle(color: Colors.grey)),
                ),
                GestureDetector(
                  onTap: () => onModeChanged(AuthMode.signUp),
                  child: const Text(
                    '회원가입',
                    style: TextStyle(
                        color: Color(0xFF0066FF),
                        fontWeight: FontWeight.bold,
                        fontSize: 13),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 32),
            // 또는 구분선
            Row(
              children: [
                const Expanded(child: Divider()),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Text('또는',
                      style:
                          TextStyle(color: Colors.grey.shade500, fontSize: 14)),
                ),
                const Expanded(child: Divider()),
              ],
            ),
            const SizedBox(height: 32),
            // 소셜 로그인 아이콘
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _buildSocialIcon('assets/icons/google_icon.png'),
                const SizedBox(width: 32),
                _buildSocialIcon('assets/icons/kakao_icon.png'),
                const SizedBox(width: 32),
                _buildSocialIcon('assets/icons/naver_icon.png'),
                const SizedBox(width: 32),
                _buildSocialIcon('assets/icons/apple_icon.png'),
              ],
            ),
          ],
        ),
      );
    }

    // 회원가입 및 비밀번호 재설정 모드
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            _isReset ? '비밀번호 재설정' : '패로킷을 설치해주셔서 감사합니다.',
            style: const TextStyle(
                fontSize: 20, fontWeight: FontWeight.bold, letterSpacing: -0.5),
          ),
          const SizedBox(height: 8),
          Text(
            _isReset
                ? '가입하신 이메일 주소를 입력하시면 비밀번호 재설정 링크를 보내드립니다.'
                : '패로킷 회원가입을 위해 이메일과 비밀번호 등록을 진행해주세요.',
            style: TextStyle(
                fontSize: 14, color: Colors.grey.shade600, letterSpacing: -0.5),
          ),
          const SizedBox(height: 32),
          Form(
            key: formKey,
            child: _buildFormFields(context),
          ),
          const SizedBox(height: 48),
          _buildSubmitButton(),
        ],
      ),
    );
  }

  Widget _buildFormFields(BuildContext context) {
    // 포커스 상태에 따라 아이콘 색상을 변경하는 색상 리졸버
    final MaterialStateColor iconColor =
        MaterialStateColor.resolveWith((states) {
      if (states.contains(MaterialState.focused)) {
        return const Color(0xFF0066FF);
      }
      return Colors.grey.shade500;
    });

    return Column(
      children: [
        // 이메일
        TextFormField(
          controller: emailController,
          keyboardType: TextInputType.emailAddress,
          decoration: InputDecoration(
            labelText: '이메일',
            labelStyle: TextStyle(
                color: Colors.grey.shade500, fontWeight: FontWeight.w500),
            floatingLabelStyle: const TextStyle(
                color: Color(0xFF0066FF), fontWeight: FontWeight.bold),
            prefixIconColor: iconColor,
            prefixIcon: const Icon(Icons.person),
            enabledBorder: UnderlineInputBorder(
              borderSide: BorderSide(color: Colors.grey.shade400),
            ),
            focusedBorder: const UnderlineInputBorder(
              borderSide: BorderSide(color: Color(0xFF0066FF), width: 2),
            ),
          ),
          validator: (value) {
            if (value == null || value.trim().isEmpty) return '이메일을 입력해주세요.';
            if (!value.contains('@')) return '올바른 이메일 형식이 아닙니다.';
            return null;
          },
        ),
        if (!_isReset) ...[
          const SizedBox(height: 16),
          // 비밀번호
          TextFormField(
            controller: passwordController,
            obscureText: true,
            decoration: InputDecoration(
              labelText: '비밀번호',
              labelStyle: TextStyle(
                  color: Colors.grey.shade500, fontWeight: FontWeight.w500),
              floatingLabelStyle: const TextStyle(
                  color: Color(0xFF0066FF), fontWeight: FontWeight.bold),
              prefixIconColor: iconColor,
              prefixIcon: const Icon(Icons.lock),
              enabledBorder: UnderlineInputBorder(
                borderSide: BorderSide(color: Colors.grey.shade400),
              ),
              focusedBorder: const UnderlineInputBorder(
                borderSide: BorderSide(color: Color(0xFF0066FF), width: 2),
              ),
            ),
            validator: (value) {
              if (value == null || value.isEmpty) return '비밀번호를 입력해주세요.';
              if (value.length < 6) return '비밀번호는 6자 이상이어야 합니다.';
              return null;
            },
          ),
        ],
        if (mode == AuthMode.signUp) ...[
          const SizedBox(height: 16),
          // 비밀번호 확인
          TextFormField(
            controller: passwordConfirmController,
            obscureText: true,
            decoration: InputDecoration(
              labelText: '비밀번호 확인',
              labelStyle: TextStyle(
                  color: Colors.grey.shade500, fontWeight: FontWeight.w500),
              floatingLabelStyle: const TextStyle(
                  color: Color(0xFF0066FF), fontWeight: FontWeight.bold),
              prefixIconColor: iconColor,
              prefixIcon: const Icon(Icons.lock),
              enabledBorder: UnderlineInputBorder(
                borderSide: BorderSide(color: Colors.grey.shade400),
              ),
              focusedBorder: const UnderlineInputBorder(
                borderSide: BorderSide(color: Color(0xFF0066FF), width: 2),
              ),
            ),
            validator: (value) {
              if (mode != AuthMode.signUp) return null;
              if (value == null || value.isEmpty) return '비밀번호를 다시 입력해주세요.';
              if (value != passwordController.text) return '비밀번호가 일치하지 않습니다.';
              return null;
            },
          ),
        ],
      ],
    );
  }

  Widget _buildSubmitButton() {
    return SizedBox(
      width: double.infinity,
      height: 56,
      child: ElevatedButton(
        onPressed: isLoading ? null : onSubmit,
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFF0066FF), // 파란색
          foregroundColor: Colors.white,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(32),
          ),
        ),
        child: isLoading
            ? const SizedBox(
                width: 24,
                height: 24,
                child: CircularProgressIndicator(
                    color: Colors.white, strokeWidth: 2),
              )
            : Text(
                primaryButtonLabel,
                style:
                    const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
      ),
    );
  }

  Widget _buildSocialIcon(String assetPath) {
    return Container(
      width: 50,
      height: 50,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ClipOval(
        child: Image.asset(
          assetPath,
          fit: BoxFit.cover,
        ),
      ),
    );
  }
}
