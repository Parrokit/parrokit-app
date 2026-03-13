// ============================================================================
// lib/features/more/presentation/sections/account_section.dart
// ============================================================================
//
// [역할]
// 계정 섹션 위젯. 계정 정보 + 코인 충전 + 로그아웃.
// ============================================================================

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:parrokit/features/_settings/more/presentation/widgets/editable_avatar.dart';
import 'package:provider/provider.dart';

import 'package:parrokit/core/config/app_config.dart';
import 'package:parrokit/core/provider/user_provider.dart';
import 'package:parrokit/core/services/daily_limit_service.dart';
import 'package:parrokit/core/theme/app_colors.dart';
import 'package:parrokit/core/utils/show_toast.dart';
import 'package:parrokit/features/_entry/auth/presentation/sections/email_verification_section.dart';
import 'package:parrokit/features/_settings/more/presentation/widgets/nickname_edit_dialog.dart';
import '../widgets/card_container.dart';
import '../widgets/section_title.dart';

/// 계정 섹션.
class AccountSection extends StatefulWidget {
  const AccountSection({super.key});

  @override
  State<AccountSection> createState() => _AccountSectionState();
}

class _AccountSectionState extends State<AccountSection> {
  int _dailyRemaining = AppConfig.sttDailyLimit;

  @override
  void initState() {
    super.initState();
    _loadDailyRemaining();
  }

  Future<void> _loadDailyRemaining() async {
    final remaining = await DailyLimitService.getRemaining(
      'stt',
      limit: AppConfig.sttDailyLimit,
    );
    if (mounted) setState(() => _dailyRemaining = remaining);
  }

  Future<void> _onLogout() async {
    final userProvider = context.read<UserProvider>();
    try {
      await userProvider.signOut();
      if (!mounted) return;
      showToast('로그아웃되었습니다.');
    } catch (e) {
      if (!mounted) return;
      showToast('로그아웃 중 오류가 발생했습니다: $e');
    }
  }

  Future<void> _checkEmailVerification() async {
    final userProvider = context.read<UserProvider>();
    try {
      await userProvider.reloadFirebaseUser();
      final verified = await userProvider.isEmailVerified();
      if (!mounted) return;
      showToast(verified ? '이메일 인증이 완료되었습니다.' : '아직 이메일 인증이 완료되지 않았습니다.');
    } catch (e) {
      if (!mounted) return;
      showToast('이메일 인증 상태 확인 중 오류가 발생했습니다: $e');
    }
  }

  Future<void> _resendVerificationEmail() async {
    final userProvider = context.read<UserProvider>();
    try {
      await userProvider.sendEmailVerification();
      if (!mounted) return;
      showToast('이메일 인증 메일을 다시 전송했습니다.');
    } catch (e) {
      if (!mounted) return;
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
          child: Column(
            children: [
              Row(
                children: [
                  EditableAvatar(photoUrl: user?.photoUrl, size: 56),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Text(
                              user?.displayName ?? user?.email ?? '-',
                              style: theme.textTheme.titleMedium?.copyWith(
                                fontWeight: FontWeight.w700,
                                fontSize: 18,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                            const SizedBox(width: 10),
                            GestureDetector(
                              onTap: () => showNicknameEditDialog(
                                  context, user?.displayName),
                              child: Icon(
                                Icons.edit_rounded,
                                size: 16,
                                color: cs.onSurface.withValues(alpha: 0.4),
                              ),
                            ),
                          ],
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
                            _StatusBadge(
                              icon: Icons.today_rounded,
                              label:
                                  '$_dailyRemaining/${AppConfig.sttDailyLimit}',
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
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                child: OutlinedButton.icon(
                  onPressed: userProvider.isLoading ? null : _onLogout,
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    side: BorderSide(color: cs.error.withValues(alpha: 0.6)),
                    foregroundColor: cs.error,
                  ),
                  icon: const Icon(Icons.logout_rounded, size: 18),
                  label: const Text('로그아웃'),
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
            onCheckVerification: _checkEmailVerification,
            onResendEmail: _resendVerificationEmail,
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
