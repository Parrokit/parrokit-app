// ============================================================================
// lib/features/dashboard/presentation/widgets/gradient_icon.dart
// ============================================================================
//
// [역할]
// 그라데이션 아이콘 위젯. 파랑-민트 그라데이션이 적용된 블링블링 아이콘.
//
// [레이어]
// Presentation Layer > Widgets
// 순수 재사용 위젯 - HeaderSection에서 사용.
// ============================================================================

import 'package:flutter/material.dart';
import 'package:parrokit/core/shared/theme/app_colors.dart';

/// 그라데이션 아이콘 위젯.
///
/// [ShaderMask]를 사용해 아이콘에 그라데이션 효과 적용.
/// 파랑(#3B82F6) → 민트(#06B6D4) 그라데이션.
class GradientIcon extends StatelessWidget {
  const GradientIcon({super.key});

  @override
  Widget build(BuildContext context) {
    return ShaderMask(
      shaderCallback: (bounds) => LinearGradient(
        colors: [AppColors.gradientStart, AppColors.gradientEnd],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      ).createShader(bounds),
      child: const Icon(
        Icons.auto_awesome,
        size: 36,
        color: Colors.white,
      ),
    );
  }
}
