// ============================================================================
// lib/features/dashboard/presentation/widgets/collection_card.dart
// ============================================================================
//
// [역할]
// 모음집(작품) 카드 위젯. 작품명, 클립 수를 카드로 표시.
//
// [레이어]
// Presentation Layer > Widgets
// 순수 재사용 위젯 - CollectionsSection에서 사용.
// ============================================================================

import 'package:flutter/material.dart';
import 'package:parrokit/core/theme/app_radius.dart';

/// 모음집 카드 위젯.
///
/// 작품명(한국어/일본어)과 클립 수를 표시.
class CollectionCard extends StatelessWidget {
  final int titleId;
  final String nameKo;
  final String? nameJa;
  final int clipCount;
  final Color cardBg;
  final Color subtle;
  final Color textPrimary;
  final Color textSecondary;
  final VoidCallback onTap;

  const CollectionCard({
    super.key,
    required this.titleId,
    required this.nameKo,
    required this.nameJa,
    required this.clipCount,
    required this.cardBg,
    required this.subtle,
    required this.textPrimary,
    required this.textSecondary,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 180,
      height: 130,
      child: InkWell(
        borderRadius: BorderRadius.circular(AppRadius.lg),
        onTap: onTap,
        child: Ink(
          decoration: BoxDecoration(
            color: cardBg,
            borderRadius: BorderRadius.circular(AppRadius.lg),
            border: Border.all(color: subtle),
          ),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(14, 12, 14, 12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 한국어 이름
                Text(
                  nameKo,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        fontWeight: FontWeight.w900,
                        color: textPrimary,
                      ),
                ),
                const SizedBox(height: 4),

                // 일본어 이름
                Text(
                  nameJa ?? '-',
                  style: Theme.of(context).textTheme.labelSmall?.copyWith(
                        fontWeight: FontWeight.w700,
                        color: textSecondary,
                      ),
                ),
                const Spacer(),

                // 클립 수
                Row(
                  children: [
                    const Icon(Icons.auto_awesome, size: 16),
                    const SizedBox(width: 6),
                    Text(
                      '클립 $clipCount',
                      style: Theme.of(context).textTheme.labelSmall?.copyWith(
                            fontWeight: FontWeight.w700,
                            color: textSecondary,
                          ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
