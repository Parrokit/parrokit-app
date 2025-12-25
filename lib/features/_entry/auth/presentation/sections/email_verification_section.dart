// ============================================================================
// lib/features/auth/presentation/sections/email_verification_section.dart
// ============================================================================
//
// [역할]
// 이메일 인증 관련 버튼들을 표시하는 섹션 위젯.
// 인증 여부 확인, 인증 메일 재발송 기능 제공.
//
// [레이어]
// Presentation Layer > Sections
// - 화면 전용 빌드 위젯
// - LoggedInSection의 하위 컴포넌트
// - 이메일 미인증 상태에서만 표시됨
// ============================================================================

import 'package:flutter/material.dart';

/// 이메일 인증 섹션.
///
/// 이메일 인증이 완료되지 않은 사용자에게 표시:
/// - 인증 여부 확인 버튼
/// - 인증 메일 재발송 버튼
class EmailVerificationSection extends StatelessWidget {
  // ─────────────────────────────────────────────────────────────────
  // 필수 파라미터
  // ─────────────────────────────────────────────────────────────────

  /// 로딩 상태 (버튼 비활성화용)
  final bool isLoading;

  /// 인증 여부 확인 콜백
  final VoidCallback onCheckVerification;

  /// 인증 메일 재발송 콜백
  final VoidCallback onResendEmail;

  const EmailVerificationSection({
    super.key,
    required this.isLoading,
    required this.onCheckVerification,
    required this.onResendEmail,
  });

  // ─────────────────────────────────────────────────────────────────
  // Build
  // ─────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // 섹션 제목
        Text('이메일 인증', style: theme.textTheme.titleMedium),
        const SizedBox(height: 8),

        // 버튼 row (50:50 비율)
        Row(
          children: [
            // 인증 여부 확인 버튼
            Expanded(
              child: OutlinedButton(
                onPressed: isLoading ? null : onCheckVerification,
                child: const Text('인증 여부 확인'),
              ),
            ),
            const SizedBox(width: 8),

            // 인증 메일 재발송 버튼
            Expanded(
              child: OutlinedButton(
                onPressed: isLoading ? null : onResendEmail,
                child: const Text('인증 메일 재전송'),
              ),
            ),
          ],
        ),
      ],
    );
  }
}
