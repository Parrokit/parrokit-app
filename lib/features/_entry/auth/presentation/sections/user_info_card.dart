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
import 'package:parrokit/data/models/user.dart';

/// 사용자 정보 카드 섹션.
///
/// 로그인된 사용자의 정보를 카드 형태로 표시:
/// - 프로필 아바타
/// - 이름/이메일
/// - 보유 코인 수
/// - 이메일 인증 뱃지
/// - 로그아웃 버튼
class UserInfoCard extends StatelessWidget {
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

  const UserInfoCard({
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

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        // 반투명 배경
        color: theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.3),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: theme.colorScheme.outlineVariant),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ─────────────────────────────────────────────────────────
          // 프로필 아바타
          // ─────────────────────────────────────────────────────────
          CircleAvatar(
            radius: 24,
            child: Icon(
              Icons.person_outline,
              color: theme.colorScheme.onPrimary,
            ),
          ),
          const SizedBox(width: 12),

          // ─────────────────────────────────────────────────────────
          // 사용자 정보 (이름, 이메일, 코인, 인증 뱃지)
          // ─────────────────────────────────────────────────────────
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 이름 또는 이메일
                Text(
                  user?.displayName ?? user?.email ?? '로그인된 사용자',
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 4),

                // 이메일 (있는 경우만)
                if (user?.email != null)
                  Text(
                    user!.email!,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
                    ),
                  ),
                const SizedBox(height: 4),

                // 보유 코인 수
                Text(
                  '코인 $coins개',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
                  ),
                ),
                const SizedBox(height: 6),

                // 이메일 인증 완료 뱃지
                if (isEmailVerified)
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.verified,
                        size: 16,
                        color: theme.colorScheme.primary,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        '이메일 인증됨',
                        style: theme.textTheme.labelSmall?.copyWith(
                          color: theme.colorScheme.primary,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
              ],
            ),
          ),
          const SizedBox(width: 8),

          // ─────────────────────────────────────────────────────────
          // 로그아웃 버튼
          // ─────────────────────────────────────────────────────────
          TextButton(
            onPressed: isLoading ? null : onLogout,
            style: TextButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              minimumSize: Size.zero,
              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
            ),
            child: Text(
              '로그아웃',
              style: theme.textTheme.labelSmall?.copyWith(
                color: theme.colorScheme.onSurface.withValues(alpha: 0.8),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
