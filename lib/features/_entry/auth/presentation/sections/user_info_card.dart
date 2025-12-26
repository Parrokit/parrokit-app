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
import 'package:flutter_svg/flutter_svg.dart';
import 'package:provider/provider.dart';
import 'package:parrokit/core/provider/user_provider.dart';
import 'package:parrokit/core/theme/app_spacing.dart';
import 'package:parrokit/core/theme/app_radius.dart';
import 'package:parrokit/data/models/user.dart';
import '../../presentation/widgets/avatar_selection_sheet.dart';

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
    final cs = theme.colorScheme;

    return Container(
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        // 반투명 배경
        color: cs.surfaceContainerHighest.withValues(alpha: 0.3),
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
              GestureDetector(
                onTap: () {
                  showModalBottomSheet(
                    context: context,
                    builder: (context) => const AvatarSelectionSheet(),
                    showDragHandle: true,
                  );
                },
                child: Stack(
                  children: [
                    Container(
                      width: 72,
                      height: 72,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: cs.surfaceContainerHighest,
                        border: Border.all(
                          color: cs.outlineVariant,
                          width: 1,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.05),
                            blurRadius: 10,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: ClipOval(
                        child: _buildAvatar(user?.photoUrl, cs),
                      ),
                    ),
                    Positioned(
                      right: 0,
                      bottom: 0,
                      child: Container(
                        padding: const EdgeInsets.all(4),
                        decoration: BoxDecoration(
                          color: cs.primary,
                          shape: BoxShape.circle,
                          border: Border.all(color: cs.surface, width: 2),
                        ),
                        child: Icon(
                          Icons.edit_rounded,
                          size: 12,
                          color: cs.onPrimary,
                        ),
                      ),
                    ),
                  ],
                ),
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
                            onTap: () => _showEditNicknameDialog(
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
                            foregroundColor: cs.error,
                            backgroundColor:
                                cs.errorContainer.withValues(alpha: 0.1),
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
              _StatusBadge(
                icon: Icons.monetization_on_rounded,
                label: '$coins 코인',
                color: cs.primary,
                backgroundColor: cs.primary.withValues(alpha: 0.1),
              ),
              // Verification Badge
              if (isEmailVerified)
                _StatusBadge(
                  icon: Icons.verified_rounded,
                  label: '인증됨',
                  color: Colors.blue,
                  backgroundColor: Colors.blue.withValues(alpha: 0.1),
                )
              else
                _StatusBadge(
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

  Widget _buildAvatar(String? photoUrl, ColorScheme cs) {
    if (photoUrl == null) {
      return Center(
        child: Icon(
          Icons.person_outline,
          size: 40,
          color: cs.onSurfaceVariant,
        ),
      );
    }

    return SvgPicture.network(
      photoUrl,
      fit: BoxFit.cover,
      width: 72,
      height: 72,
      placeholderBuilder: (context) => const Center(
        child: CircularProgressIndicator(strokeWidth: 2),
      ),
    );
  }

  void _showEditNicknameDialog(BuildContext context, String? currentName) {
    final controller = TextEditingController(text: currentName);
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('닉네임 변경'),
        content: TextField(
          controller: controller,
          decoration: const InputDecoration(
            hintText: '닉네임을 입력하세요',
            filled: true,
          ),
          autofocus: true,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('취소'),
          ),
          TextButton(
            onPressed: () {
              final newName = controller.text.trim();
              if (newName.isNotEmpty) {
                context.read<UserProvider>().updateDisplayName(newName);
              } else if (currentName != null) {
                // 이름 삭제 (null)
                context.read<UserProvider>().updateDisplayName(null);
              }
              Navigator.pop(context);
            },
            child: const Text('저장'),
          ),
        ],
      ),
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
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(AppRadius.sm),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: color),
          const SizedBox(width: 6),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: color,
            ),
          ),
        ],
      ),
    );
  }
}
