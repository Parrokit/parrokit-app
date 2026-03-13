// ============================================================================
// lib/features/more/presentation/sections/account_section.dart
// ============================================================================
//
// [역할]
// 계정 섹션 위젯. 계정 정보 + 코인 충전 + 로그아웃.
// ============================================================================

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:provider/provider.dart';

import 'package:parrokit/core/config/app_config.dart';
import 'package:parrokit/core/provider/user_provider.dart';
import 'package:parrokit/core/services/ad_service.dart';
import 'package:parrokit/core/services/daily_limit_service.dart';
import 'package:parrokit/core/theme/app_colors.dart';
import 'package:parrokit/core/utils/show_toast.dart';
import 'package:parrokit/features/_entry/auth/presentation/sections/email_verification_section.dart';
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
    AdService().loadRewardedAd();
    _loadDailyRemaining();
  }

  Future<void> _loadDailyRemaining() async {
    final remaining = await DailyLimitService.getRemaining(
      'stt',
      limit: AppConfig.sttDailyLimit,
    );
    if (mounted) setState(() => _dailyRemaining = remaining);
  }

  Future<void> _onWatchAd() async {
    AdService().showRewardedAd(
      onRewarded: (coins) {
        if (!mounted) return;
        if (coins < 0) {
          showToast('광고가 아직 준비 중이에요. 잠시 후 다시 시도해 주세요.');
          return;
        }
        context.read<UserProvider>().addCoins(coins);
        showToast('코인 $coins개를 받았어요!');
        _loadDailyRemaining();
      },
    );
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
                  Container(
                    width: 56,
                    height: 56,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: cs.surfaceContainerHighest,
                      border: Border.all(color: cs.outlineVariant, width: 1),
                    ),
                    child: ClipOval(child: _buildAvatar(user?.photoUrl, cs)),
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
                        ),
                        const SizedBox(height: 8),
                        Wrap(
                          spacing: 8,
                          runSpacing: 8,
                          children: [
                            _StatusBadge(
                              icon: Icons.monetization_on_rounded,
                              label: '${userProvider.coins} 코인',
                              color: cs.primary,
                              backgroundColor:
                                  cs.primary.withValues(alpha: 0.1),
                            ),
                            _StatusBadge(
                              icon: Icons.today_rounded,
                              label: '오늘 $_dailyRemaining/${AppConfig.sttDailyLimit}',
                              color: cs.secondary,
                              backgroundColor:
                                  cs.secondary.withValues(alpha: 0.1),
                            ),
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
                                    Colors.blue.withValues(alpha: 0.1),
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

        // ── 광고 보고 코인 받기
        const SizedBox(height: 20),
        _AdRewardSection(onWatchAd: _onWatchAd),
      ],
    );
  }

  Widget _buildAvatar(String? photoUrl, ColorScheme cs) {
    if (photoUrl == null) {
      return Center(
        child:
            Icon(Icons.person_outline, size: 30, color: cs.onSurfaceVariant),
      );
    }
    return SvgPicture.network(
      photoUrl,
      fit: BoxFit.cover,
      width: 56,
      height: 56,
      placeholderBuilder: (_) =>
          const Center(child: CircularProgressIndicator(strokeWidth: 2)),
    );
  }
}

class _AdRewardSection extends StatelessWidget {
  final VoidCallback onWatchAd;

  const _AdRewardSection({required this.onWatchAd});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '코인 받기',
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          '광고를 시청하면 코인 ${AdService.rewardCoins}개를 받을 수 있어요. 코인이 있으면 하루 제한 없이 자막 생성을 사용할 수 있어요.',
          style: theme.textTheme.bodySmall?.copyWith(
            color: cs.onSurface.withValues(alpha: 0.7),
          ),
        ),
        const SizedBox(height: 12),
        SizedBox(
          width: double.infinity,
          child: OutlinedButton.icon(
            onPressed: onWatchAd,
            icon: const Icon(Icons.play_circle_outline_rounded, size: 18),
            label: Text('광고 보고 코인 ${AdService.rewardCoins}개 받기'),
          ),
        ),
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
