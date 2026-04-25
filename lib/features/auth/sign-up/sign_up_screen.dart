import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:parrokit/core/utils/show_toast.dart';
import 'package:provider/provider.dart';
import 'package:parrokit/core/provider/user_provider.dart';

class SignUpScreen extends StatefulWidget {
  const SignUpScreen({super.key});

  @override
  State<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _passwordConfirmController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _passwordConfirmController.dispose();
    super.dispose();
  }

  bool get _isLoading => context.watch<UserProvider>().isLoading;

  Future<void> _onSubmit() async {
    if (!_formKey.currentState!.validate()) return;

    final email = _emailController.text.trim();
    final password = _passwordController.text;
    final userProvider = context.read<UserProvider>();

    try {
      await userProvider.signUpWithEmail(email: email, password: password);
      if (!mounted) return;
      showToast('회원가입이 완료되었습니다. 이메일로 전송된 인증 메일을 확인해 주세요.');
      context.pop(); // Go back to sign in
    } on FirebaseAuthException catch (e) {
      if (!mounted) return;
      switch (e.code) {
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
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        scrolledUnderElevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: Colors.black),
          onPressed: () => context.pop(),
        ),
        title: const Text(
          '회원가입',
          style: TextStyle(
            color: Colors.black,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
      ),
      body: SafeArea(
        child: Align(
          alignment: Alignment.topCenter,
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 480),
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const Text(
                    '패로킷을 설치해주셔서 감사합니다.',
                    style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        letterSpacing: -0.5),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '패로킷 회원가입을 위해 이메일과 비밀번호 등록을 진행해주세요.',
                    style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey.shade600,
                        letterSpacing: -0.5),
                  ),
                  const SizedBox(height: 32),
                  Form(
                    key: _formKey,
                    child: _buildFormFields(),
                  ),
                  const SizedBox(height: 48),
                  _buildSubmitButton(),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildFormFields() {
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
          controller: _emailController,
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
        const SizedBox(height: 16),
        // 비밀번호
        TextFormField(
          controller: _passwordController,
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
        const SizedBox(height: 16),
        // 비밀번호 확인
        TextFormField(
          controller: _passwordConfirmController,
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
            if (value == null || value.isEmpty) return '비밀번호를 다시 입력해주세요.';
            if (value != _passwordController.text) return '비밀번호가 일치하지 않습니다.';
            return null;
          },
        ),
      ],
    );
  }

  Widget _buildSubmitButton() {
    return SizedBox(
      width: double.infinity,
      height: 56,
      child: ElevatedButton(
        onPressed: _isLoading ? null : _onSubmit,
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFF0066FF), // 파란색
          foregroundColor: Colors.white,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(32),
          ),
        ),
        child: _isLoading
            ? const SizedBox(
                width: 24,
                height: 24,
                child: CircularProgressIndicator(
                    color: Colors.white, strokeWidth: 2),
              )
            : const Text(
                '회원가입',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
      ),
    );
  }
}
