// ============================================================================
// lib/features/intro/presentation/widgets/page_indicator.dart
// ============================================================================
//
// [역할]
// 페이지 인디케이터 위젯. 현재 페이지 위치를 점으로 표시.
//
// [레이어]
// Presentation Layer > Widgets
// 순수 재사용 위젯.
// ============================================================================

import 'package:flutter/material.dart';

/// 페이지 인디케이터 위젯.
///
/// 현재 페이지 위치를 애니메이션 점으로 표시.
/// 활성 점은 더 길게 표시.
class PageIndicator extends StatelessWidget {
  final int currentIndex;
  final int totalCount;
  final Color activeColor;
  final Color inactiveColor;

  const PageIndicator({
    super.key,
    required this.currentIndex,
    required this.totalCount,
    this.activeColor = Colors.white,
    this.inactiveColor = Colors.white30,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(totalCount, (i) {
        final isActive = i == currentIndex;
        return AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          margin: const EdgeInsets.symmetric(horizontal: 3, vertical: 6),
          height: 6,
          width: isActive ? 18 : 6,
          decoration: BoxDecoration(
            color: isActive ? activeColor : inactiveColor,
            borderRadius: BorderRadius.circular(10),
          ),
        );
      }),
    );
  }
}
