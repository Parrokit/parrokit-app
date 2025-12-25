// ============================================================================
// lib/features/intro/presentation/widgets/gradient_scrim.dart
// ============================================================================
//
// [역할]
// 그라데이션 스크림 위젯. 상하단에 그라데이션 오버레이 표시.
// 콘텐츠 가독성 향상을 위해 사용.
//
// [레이어]
// Presentation Layer > Widgets
// 순수 재사용 위젯.
// ============================================================================

import 'package:flutter/material.dart';

/// 상하단 그라데이션 스크림 위젯.
///
/// 검은 배경에서 콘텐츠 가독성을 위해 사용.
/// 상단/하단에 그라데이션 오버레이 표시.
class GradientScrim extends StatelessWidget {
  final double topHeight;
  final double bottomHeight;

  const GradientScrim({
    super.key,
    this.topHeight = 120,
    this.bottomHeight = 160,
  });

  @override
  Widget build(BuildContext context) {
    return Positioned.fill(
      child: IgnorePointer(
        child: Column(
          children: [
            // 상단 그라데이션
            Container(
              height: topHeight,
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [Colors.black87, Colors.transparent],
                ),
              ),
            ),
            const Spacer(),
            // 하단 그라데이션
            Container(
              height: bottomHeight,
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.bottomCenter,
                  end: Alignment.topCenter,
                  colors: [Colors.black87, Colors.transparent],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
