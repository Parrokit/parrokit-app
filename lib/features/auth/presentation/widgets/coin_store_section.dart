// ============================================================================
// lib/features/auth/presentation/widgets/coin_store_section.dart
// ============================================================================
//
// [역할]
// 코인 충전 섹션 위젯.
// 코인 패키지 목록을 표시하고 선택 기능 제공.
//
// [레이어]
// Presentation Layer > Widgets
// - 순수 재사용 가능한 UI 컴포넌트
// - LoggedInSection에서 사용
//
// [구성]
// - 섹션 헤더 (제목 + 설명)
// - CoinPackageCard 리스트
// ============================================================================

import 'package:flutter/material.dart';
import '../../domain/coin_package.dart';
import 'coin_package_card.dart';

/// 코인 충전 섹션 위젯.
///
/// 사전 정의된 코인 패키지들을 카드 리스트로 표시.
/// 패키지 선택 시 콜백을 통해 부모에게 알림.
class CoinStoreSection extends StatelessWidget {
  // ─────────────────────────────────────────────────────────────────
  // 파라미터
  // ─────────────────────────────────────────────────────────────────

  /// 코인 패키지 선택 콜백
  final ValueChanged<CoinPackage>? onPackageSelected;

  const CoinStoreSection({
    super.key,
    this.onPackageSelected,
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
        // ─────────────────────────────────────────────────────────────
        // 섹션 헤더
        // ─────────────────────────────────────────────────────────────
        Text(
          '코인 충전',
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          '1,000원 단위로 결제하고, 각 결제마다 10% 보너스 코인이 추가로 지급돼요.',
          style: theme.textTheme.bodySmall?.copyWith(
            color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
          ),
        ),
        const SizedBox(height: 16),

        // ─────────────────────────────────────────────────────────────
        // 코인 패키지 카드 리스트
        // ─────────────────────────────────────────────────────────────
        Column(
          children: CoinPackage.packages
              .map(
                (pkg) => Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: CoinPackageCard(
                    package: pkg,
                    onTap: () => onPackageSelected?.call(pkg),
                  ),
                ),
              )
              .toList(),
        ),
      ],
    );
  }
}
