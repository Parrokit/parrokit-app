// ============================================================================
// lib/features/more/presentation/sections/account_section.dart
// ============================================================================
//
// [역할]
// 계정 섹션 위젯.
// ============================================================================

import 'package:flutter/material.dart';
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
    final userProvider = context.watch<UserProvider>();
    final user = userProvider.currentUser;
    final t = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SectionTitle('계정'),
        const SizedBox(height: 10),
        CardContainer(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  CircleAvatar(
                    radius: 22,
                    child: Icon(
                      Icons.person_outline,
                      color: t.colorScheme.onPrimary,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          user?.displayName ?? user?.email ?? '게스트 사용자',
                          style: t.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        const SizedBox(height: 4),
                        FutureBuilder<bool>(
                          future:
                              context.read<UserProvider>().isEmailVerified(),
                          builder: (context, snapshot) {
                            final verified = snapshot.data ?? false;
                            final hasEmail = user?.email != null;
                            final verificationText = !hasEmail
                                ? '이메일 계정 없음'
                                : (verified ? '이메일 인증 완료' : '이메일 미인증');

                            return Text(
                              '코인 ${userProvider.coins}개 · $verificationText',
                              style: t.textTheme.bodySmall?.copyWith(
                                color: t.colorScheme.onSurfaceVariant,
                              ),
                            );
                          },
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              SizedBox(
                width: double.infinity,
                child: OutlinedButton.icon(
                  onPressed: () {
                    context.push('/auth');
                  },
                  icon: const Icon(Icons.manage_accounts_outlined),
                  label: Text(
                    user?.email == null ? '로그인 / 계정 만들기' : '계정 관리',
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
