// ============================================================================
// lib/features/auth/presentation/widgets/coin_package_card.dart
// ============================================================================
//
// [역할]
// 코인 패키지를 카드 형태로 표시하는 위젯.
// 가격, 총 코인 수, 보너스 정보 표시.
//
// [레이어]
// Presentation Layer > Widgets
// - 순수 재사용 가능한 UI 컴포넌트
// - CoinStoreSection에서 사용
// ============================================================================

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../domain/coin_package.dart';

/// 코인 패키지 카드 위젯.
///
/// 단일 코인 패키지를 카드 형태로 표시:
/// - 가격 (₩1,000 형식)
/// - 총 코인 수 (기본 + 보너스)
/// - 보너스 뱃지
class CoinPackageCard extends StatelessWidget {
  // ─────────────────────────────────────────────────────────────────
  // 필수 파라미터
  // ─────────────────────────────────────────────────────────────────

  /// 표시할 코인 패키지
  final CoinPackage package;

  /// 카드 탭 콜백
  final VoidCallback? onTap;

  const CoinPackageCard({
    super.key,
    required this.package,
    this.onTap,
  });

  // ─────────────────────────────────────────────────────────────────
  // 헬퍼 메서드
  // ─────────────────────────────────────────────────────────────────

  /// 가격을 원화 형식으로 포맷 (₩1,000)
  String get _formattedPrice {
    final formatter = NumberFormat.currency(
      locale: 'ko_KR',
      symbol: '₩',
      decimalDigits: 0,
    );
    return formatter.format(package.price);
  }

  // ─────────────────────────────────────────────────────────────────
  // Build
  // ─────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(
          color: theme.colorScheme.outlineVariant,
        ),
      ),
      child: ListTile(
        onTap: onTap,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 8,
        ),

        // 가격 (메인 타이틀)
        title: Text(
          _formattedPrice,
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w700,
          ),
        ),

        // 코인 상세 (기본 + 보너스)
        subtitle: Text(
          '총 ${package.totalCoins}코인 (기본 ${package.coins} + 보너스 ${package.bonusCoins})',
          style: theme.textTheme.bodySmall?.copyWith(
            color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
          ),
        ),

        // 보너스 뱃지 + 화살표
        trailing: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(
              '+10% 보너스',
              style: theme.textTheme.labelSmall?.copyWith(
                color: theme.colorScheme.primary,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 2),
            Icon(
              Icons.chevron_right,
              size: 18,
              color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
            ),
          ],
        ),
      ),
    );
  }
}
