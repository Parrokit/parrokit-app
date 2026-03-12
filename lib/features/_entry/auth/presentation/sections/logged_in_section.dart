// ============================================================================
// lib/features/auth/presentation/sections/logged_in_section.dart
// ============================================================================
//
// [역할]
// 로그인된 상태에서 표시하는 섹션 위젯.
// 계정 정보, 이메일 인증, 코인 충전 기능 포함.
//
// [레이어]
// Presentation Layer > Sections
// - 화면 전용 빌드 위젯 (순수 재사용 widgets/와 구분)
// - 하위 섹션 위젯들을 조합하여 구성
//
// [구성 요소]
// - UserInfoCard: 사용자 정보 카드
// - EmailVerificationSection: 이메일 인증 버튼들
// - CoinStoreSection: 코인 충전 패키지 목록
// ============================================================================

import 'package:flutter/material.dart';
import 'package:parrokit/data/models/user.dart';
import '../../domain/coin_package.dart';
import 'coin_store_section.dart';
import 'user_info_section.dart';
import 'email_verification_section.dart';

/// 로그인된 상태에서 표시하는 섹션.
///
/// [AuthScreen]에서 로그인 상태일 때 표시.
/// 계정 정보 확인, 이메일 인증, 코인 충전 기능 제공.
class LoggedInSection extends StatelessWidget {
  // ─────────────────────────────────────────────────────────────────
  // 필수 파라미터 (부모에서 주입)
  // ─────────────────────────────────────────────────────────────────

  /// 현재 로그인한 사용자 정보
  final PaUser? user;

  /// 사용자 보유 코인 수
  final int coins;

  /// 이메일 인증 완료 여부
  final bool isEmailVerified;

  /// 로딩 상태 (버튼 비활성화용)
  final bool isLoading;

  /// 로그아웃 콜백
  final VoidCallback onLogout;

  /// 이메일 인증 확인 콜백
  final VoidCallback onCheckEmailVerification;

  /// 인증 메일 재발송 콜백
  final VoidCallback onResendVerificationEmail;

  /// 코인 패키지 선택 콜백
  final ValueChanged<CoinPackage> onCoinPackageSelected;

  const LoggedInSection({
    super.key,
    required this.user,
    required this.coins,
    required this.isEmailVerified,
    required this.isLoading,
    required this.onLogout,
    required this.onCheckEmailVerification,
    required this.onResendVerificationEmail,
    required this.onCoinPackageSelected,
  });

  // ─────────────────────────────────────────────────────────────────
  // Build
  // ─────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Expanded(
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // ─────────────────────────────────────────────────────
                // 헤더 (제목 + 설명)
                // ─────────────────────────────────────────────────────
                Text(
                  '내 계정',
                  style: theme.textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  '현재 로그인된 계정 정보를 확인하고, 이메일 인증과 로그아웃을 관리할 수 있어요.',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
                  ),
                ),
                const SizedBox(height: 24),

                // ─────────────────────────────────────────────────────
                // 사용자 정보 카드
                // ─────────────────────────────────────────────────────
                UserInfoSection(
                  user: user,
                  coins: coins,
                  isEmailVerified: isEmailVerified,
                  isLoading: isLoading,
                  onLogout: onLogout,
                ),
                const SizedBox(height: 24),

                // ─────────────────────────────────────────────────────
                // 이메일 인증 섹션 (미인증 시에만 표시)
                // ─────────────────────────────────────────────────────
                if (user?.email != null && !isEmailVerified) ...[
                  EmailVerificationSection(
                    isLoading: isLoading,
                    onCheckVerification: onCheckEmailVerification,
                    onResendEmail: onResendVerificationEmail,
                  ),
                  const SizedBox(height: 24),
                ],

                // ─────────────────────────────────────────────────────
                // 코인 충전 섹션
                // ─────────────────────────────────────────────────────
                CoinStoreSection(
                  onPackageSelected: onCoinPackageSelected,
                ),
                const SizedBox(height: 24),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
