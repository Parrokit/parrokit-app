// ============================================================================
// lib/features/dashboard/presentation/widgets/empty_card.dart
// ============================================================================
//
// [역할]
// 빈 상태 카드 위젯. 데이터가 없을 때 표시.
//
// [레이어]
// Presentation Layer > Widgets
// 순수 재사용 위젯 - 여러 섹션에서 공통 사용.
// ============================================================================

import 'package:flutter/material.dart';

/// 빈 상태 카드 위젯.
///
/// [noun]으로 "아직 등록된 {noun}이 없어요" 메시지 표시.
class EmptyCard extends StatelessWidget {
  final String noun;
  final Color subtle;
  final Color textSecondary;

  const EmptyCard({
    super.key,
    required this.noun,
    required this.subtle,
    required this.textSecondary,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final cardBg = isDark ? const Color(0xFF15181C) : Colors.transparent;

    return Container(
      height: 160,
      decoration: BoxDecoration(
        color: cardBg,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: subtle, width: 1),
      ),
      child: Center(
        child: Text(
          '아직 등록된 $noun이 없어요',
          style: TextStyle(
            color: textSecondary,
            fontSize: 14,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }
}
