// ============================================================================
// lib/features/more/presentation/sections/account_section.dart
// ============================================================================
//
// [역할]
// 계정 섹션 위젯. 계정 정보 + 코인 충전 + 로그아웃.
// ============================================================================

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:parrokit/core/router/app_routes.dart';
import 'package:parrokit/core/provider/user_provider.dart';
import 'package:parrokit/core/theme/app_colors.dart';
import 'package:parrokit/core/utils/show_toast.dart';
import 'email_verification_section.dart';
import '../widgets/card_container.dart';
import '../widgets/section_title.dart';

/// 계정 섹션.
class AccountSection extends StatelessWidget {
  const AccountSection({super.key});

  Future<void> _checkEmailVerification(BuildContext context) async {
    final userProvider = context.read<UserProvider>();
    try {
      await userProvider.reloadFirebaseUser();
      final verified = await userProvider.isEmailVerified();
      if (!context.mounted) return;
      showToast(verified ? '이메일 인증이 완료되었습니다.' : '아직 이메일 인증이 완료되지 않았습니다.');
    } catch (e) {
      if (!context.mounted) return;
      showToast('이메일 인증 상태 확인 중 오류가 발생했습니다: $e');
    }
  }

  Future<void> _resendVerificationEmail(BuildContext context) async {
    final userProvider = context.read<UserProvider>();
    try {
      await userProvider.sendEmailVerification();
      if (!context.mounted) return;
      showToast('인증 메일을 전송했습니다. 메일이 보이지 않는다면 스팸 메일함도 확인해 주세요.');
    } catch (e) {
      if (!context.mounted) return;
      showToast('인증 메일 재전송 중 오류가 발생했습니다: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    final userProvider = context.watch<UserProvider>();
    final user = userProvider.currentUser;
    final isDark = theme.brightness == Brightness.dark;
    final isEmailVerified =
        FirebaseAuth.instance.currentUser?.emailVerified ?? false;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SectionTitle('계정'),
        const SizedBox(height: 10),

        // ── 계정 카드
        CardContainer(
          padding: const EdgeInsets.all(20),
          gradient: isDark
              ? AppColors.accountCardGradientDark
              : AppColors.accountCardGradient,
          child: Stack(
            children: [
              Row(
                children: [
                  CircleAvatar(
                    radius: 28,
                    backgroundColor: cs.surfaceContainerHighest,
                    backgroundImage: user?.photoUrl != null
                        ? NetworkImage(user!.photoUrl!)
                        : null,
                    child: user?.photoUrl == null
                        ? const Icon(Icons.person, size: 30)
                        : null,
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          user?.displayName ?? user?.email ?? '-',
                          style: theme.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w700,
                            fontSize: 18,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 8),
                        Wrap(
                          spacing: 8,
                          runSpacing: 8,
                          children: [
                            if (user?.email != null && !isEmailVerified)
                              _StatusBadge(
                                icon: Icons.error_outline_rounded,
                                label: '이메일 미인증',
                                color: cs.error,
                                backgroundColor:
                                    cs.error.withValues(alpha: 0.1),
                              )
                            else if (user?.email != null)
                              _StatusBadge(
                                icon: Icons.verified_rounded,
                                label: '인증됨',
                                color: Colors.blue,
                                backgroundColor:
                                    cs.primary.withValues(alpha: 0.1),
                              ),
                            _StatusBadge(
                              icon: Icons.monetization_on_rounded,
                              label: '${userProvider.coins} 코인',
                              color: cs.primary,
                              backgroundColor:
                                  cs.primary.withValues(alpha: 0.1),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              // 프로필 통합 편집 버튼 (우측 상단)
              Positioned(
                top: -8,
                right: -8,
                child: IconButton(
                  icon: Icon(
                    Icons.edit_rounded,
                    size: 20,
                    color: cs.onSurface.withValues(alpha: 0.6),
                  ),
                  onPressed: () => context.push(AppRoutes.profileEdit),
                ),
              ),
            ],
          ),
        ),

        // ── 이메일 미인증 경고
        if (user?.email != null && !isEmailVerified) ...[
          const SizedBox(height: 12),
          EmailVerificationSection(
            isLoading: userProvider.isLoading,
            onCheckVerification: () => _checkEmailVerification(context),
            onResendEmail: () => _resendVerificationEmail(context),
          ),
        ],
      ],
    );
  }
}

class _StatusBadge extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final Color backgroundColor;

  const _StatusBadge({
    required this.icon,
    required this.label,
    required this.color,
    required this.backgroundColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: color),
          const SizedBox(width: 4),
          Text(
            label,
            style: Theme.of(context).textTheme.labelSmall?.copyWith(
                  fontWeight: FontWeight.w600,
                  color: color,
                ),
          ),
        ],
      ),
    );
  }
}
