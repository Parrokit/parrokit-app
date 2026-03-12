// ============================================================================
// lib/features/intro/presentation/sections/intro_controls_section.dart
// ============================================================================
//
// [역할]
// 온보딩 하단 컨트롤 섹션.
// 페이지 인디케이터, 진행률, 건너뛰기/다음 버튼 표시.
//
// [레이어]
// Presentation Layer > Sections
// IntroScreen에서만 사용하는 화면 전용 섹션.
// ============================================================================

import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:parrokit/core/theme/app_spacing.dart';
import 'package:parrokit/core/theme/app_radius.dart';
import '../widgets/page_indicator.dart';

/// 온보딩 하단 컨트롤 섹션.
///
/// 글래스모피즘 스타일의 컨트롤 카드.
/// 인디케이터, 진행률, 네비게이션 버튼 포함.
class IntroControlsSection extends StatelessWidget {
  final int currentIndex;
  final int totalCount;
  final bool isLastPage;
  final VoidCallback onNext;
  final VoidCallback onSkip;

  const IntroControlsSection({
    super.key,
    required this.currentIndex,
    required this.totalCount,
    required this.isLastPage,
    required this.onNext,
    required this.onSkip,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return ClipRRect(
      borderRadius: BorderRadius.circular(AppRadius.lg),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 8, sigmaY: 8),
        child: Container(
          padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.md, vertical: AppSpacing.sm),
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.06),
            border: Border.all(color: Colors.white.withValues(alpha: 0.12)),
            borderRadius: BorderRadius.circular(AppRadius.lg),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // 페이지 인디케이터
              PageIndicator(
                currentIndex: currentIndex,
                totalCount: totalCount,
              ),

              // 진행률 텍스트
              Text(
                '${currentIndex + 1} / $totalCount',
                style: theme.textTheme.labelMedium?.copyWith(
                  color: Colors.white70,
                  letterSpacing: 0.4,
                ),
              ),
              const SizedBox(height: 4),

              // 버튼 행
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // 건너뛰기
                  TextButton(
                    style: TextButton.styleFrom(
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(
                        horizontal: AppSpacing.md,
                        vertical: AppSpacing.sm,
                      ),
                    ),
                    onPressed: onSkip,
                    child: const Text('건너뛰기'),
                  ),

                  // 다음 / 시작하기
                  TextButton(
                    style: TextButton.styleFrom(
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(
                        horizontal: AppSpacing.md,
                        vertical: AppSpacing.sm,
                      ),
                    ),
                    onPressed: onNext,
                    child: Text(isLastPage ? '시작하기' : '다음'),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
