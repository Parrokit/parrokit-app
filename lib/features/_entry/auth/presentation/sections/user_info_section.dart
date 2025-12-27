// ============================================================================
// lib/features/auth/presentation/sections/user_info_card.dart
// ============================================================================
//
// [역할]
// 사용자 정보를 카드 형태로 표시하는 섹션 위젯.
// 프로필, 이메일, 코인 수, 이메일 인증 상태 표시.
//
// [레이어]
// Presentation Layer > Sections
// - 화면 전용 빌드 위젯
// - LoggedInSection의 하위 컴포넌트
// ============================================================================

import 'package:flutter/material.dart';
import 'package:parrokit/core/theme/app_colors.dart';
import 'package:parrokit/core/theme/app_spacing.dart';
import 'package:parrokit/core/theme/app_radius.dart';
import 'package:parrokit/data/models/user.dart';
import '../../presentation/widgets/editable_avatar.dart';
import '../../presentation/widgets/status_badge.dart';
import '../../presentation/widgets/nickname_edit_dialog.dart';

/// 사용자 정보 카드 섹션.
///
/// 로그인된 사용자의 정보를 카드 형태로 표시:
/// - 프로필 아바타
/// - 이름/이메일
/// - 보유 코인 수
/// - 이메일 인증 뱃지
/// - 로그아웃 버튼
class UserInfoSection extends StatelessWidget {
  // ─────────────────────────────────────────────────────────────────
  // 필수 파라미터
  // ─────────────────────────────────────────────────────────────────

  /// 현재 로그인한 사용자 정보
  final PaUser? user;

  /// 보유 코인 수
  final int coins;

  /// 이메일 인증 완료 여부
  final bool isEmailVerified;

  /// 로딩 상태 (로그아웃 버튼 비활성화용)
  final bool isLoading;

  /// 로그아웃 콜백
  final VoidCallback onLogout;

  const UserInfoSection({
    super.key,
    required this.user,
    required this.coins,
    required this.isEmailVerified,
    required this.isLoading,
    required this.onLogout,
  });

  // ─────────────────────────────────────────────────────────────────
  // Build
  // ─────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    final isDark = theme.brightness == Brightness.dark;

    return Container(
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        gradient: isDark
            ? AppColors.accountCardGradientDark
            : AppColors.accountCardGradient,
        borderRadius: BorderRadius.circular(AppRadius.lg),
        border: Border.all(color: cs.outlineVariant),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ─────────────────────────────────────────────────────────
              // 프리미엄 프로필 아바타
              // ─────────────────────────────────────────────────────────
              // ─────────────────────────────────────────────────────────
              // 프리미엄 프로필 아바타
              // ─────────────────────────────────────────────────────────
              EditableAvatar(
                photoUrl: user?.photoUrl,
                size: 72,
              ),
              const SizedBox(width: 16),

              // ─────────────────────────────────────────────────────────
              // 사용자 정보 (이름, 이메일) + 로그아웃
              // ─────────────────────────────────────────────────────────
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: GestureDetector(
                            onTap: () => showNicknameEditDialog(
                                context, user?.displayName),
                            child: Row(
                              children: [
                                Flexible(
                                  child: Text(
                                    user?.displayName ??
                                        user?.email ??
                                        '로그인된 사용자',
                                    style:
                                        theme.textTheme.titleMedium?.copyWith(
                                      fontWeight: FontWeight.w700,
                                      fontSize: 18,
                                    ),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Icon(
                                  Icons.edit_rounded,
                                  size: 16,
                                  color: cs.onSurfaceVariant
                                      .withValues(alpha: 0.5),
                                ),
                              ],
                            ),
                          ),
                        ),
                        // 로그아웃 버튼 (아이콘 스타일)
                        IconButton(
                          onPressed: isLoading ? null : onLogout,
                          icon: const Icon(Icons.logout_rounded, size: 20),
                          tooltip: '로그아웃',
                          style: IconButton.styleFrom(
                            foregroundColor: cs.primary,
                            padding: const EdgeInsets.all(8),
                            minimumSize: Size.zero,
                            tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                          ),
                        ),
                      ],
                    ),
                    if (user?.email != null) ...[
                      const SizedBox(height: 2),
                      Text(
                        user!.email!,
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: cs.onSurface.withValues(alpha: 0.6),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // ─────────────────────────────────────────────────────────
          // 상태 배지 (코인, 인증)
          // ─────────────────────────────────────────────────────────
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              // Coin Badge
              StatusBadge(
                icon: Icons.monetization_on_rounded,
                label: '$coins 코인',
                color: cs.primary,
                backgroundColor: cs.primary.withValues(alpha: 0.1),
              ),
              // Verification Badge
              if (isEmailVerified)
                StatusBadge(
                  icon: Icons.verified_rounded,
                  label: '인증됨',
                  color: Colors.blue,
                  backgroundColor: Colors.blue.withValues(alpha: 0.1),
                )
              else
                StatusBadge(
                  icon: Icons.error_outline_rounded,
                  label: '미인증',
                  color: cs.error,
                  backgroundColor: cs.error.withValues(alpha: 0.1),
                ),
            ],
          ),
        ],
      ),
    );
  }
}
