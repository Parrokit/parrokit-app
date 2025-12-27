// ============================================================================
// lib/features/more/presentation/sections/account_section.dart
// ============================================================================
//
// [역할]
// 계정 섹션 위젯.
// ============================================================================

import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import 'package:parrokit/core/provider/user_provider.dart';
import '../widgets/card_container.dart';
import '../widgets/section_title.dart';

/// 계정 섹션.
class AccountSection extends StatelessWidget {
  const AccountSection({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final t = theme; // Alias used in build
    final cs = theme.colorScheme;
    final userProvider = context.watch<UserProvider>();
    final user = userProvider.currentUser;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SectionTitle('계정'),
        const SizedBox(height: 10),
        CardContainer(
          padding: const EdgeInsets.all(20),
          child: Column(
            children: [
              Row(
                children: [
                  // Premium Avatar
                  Container(
                    width: 56,
                    height: 56,
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
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          user?.displayName ?? user?.email ?? '게스트 사용자',
                          style: t.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w700,
                            fontSize: 18,
                          ),
                        ),
                        const SizedBox(height: 8),
                        // Status Badges
                        FutureBuilder<bool>(
                          future:
                              context.read<UserProvider>().isEmailVerified(),
                          builder: (context, snapshot) {
                            final verified = snapshot.data ?? false;
                            final hasEmail = user?.email != null;

                            return Wrap(
                              spacing: 8,
                              runSpacing: 8,
                              children: [
                                // Coin Badge
                                _StatusBadge(
                                  icon: Icons.monetization_on_rounded,
                                  label: '${userProvider.coins} 코인',
                                  color: cs.primary,
                                  backgroundColor:
                                      cs.primary.withValues(alpha: 0.1),
                                ),
                                // Verification Badge
                                if (!hasEmail)
                                  _StatusBadge(
                                    icon: Icons.no_accounts_rounded,
                                    label: '이메일 없음',
                                    color: cs.error,
                                    backgroundColor:
                                        cs.error.withValues(alpha: 0.1),
                                  )
                                else if (verified)
                                  _StatusBadge(
                                    icon: Icons.verified_rounded,
                                    label: '인증됨',
                                    color: Colors.blue,
                                    backgroundColor:
                                        Colors.blue.withValues(alpha: 0.1),
                                  )
                                else
                                  _StatusBadge(
                                    icon: Icons.error_outline_rounded,
                                    label: '미인증',
                                    color: cs.error,
                                    backgroundColor:
                                        cs.error.withValues(alpha: 0.1),
                                  ),
                              ],
                            );
                          },
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                child: FilledButton.tonalIcon(
                  onPressed: () {
                    context.push('/auth');
                  },
                  style: FilledButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    backgroundColor: cs.surfaceContainerHighest,
                    foregroundColor: cs.onSurface,
                  ),
                  icon: const Icon(Icons.manage_accounts_rounded, size: 20),
                  label: Text(
                    user?.email == null ? '로그인 / 계정 만들기' : '계정 관리',
                    style: Theme.of(context)
                        .textTheme
                        .bodyMedium
                        ?.copyWith(fontWeight: FontWeight.w600),
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildAvatar(String? photoUrl, ColorScheme cs) {
    if (photoUrl == null) {
      return Center(
        child: Icon(
          Icons.person_outline,
          size: 30,
          color: cs.onSurfaceVariant,
        ),
      );
    }

    return SvgPicture.network(
      photoUrl,
      fit: BoxFit.cover,
      width: 56,
      height: 56,
      placeholderBuilder: (context) => const Center(
        child: CircularProgressIndicator(strokeWidth: 2),
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
