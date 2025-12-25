// ============================================================================
// lib/features/intro/presentation/sections/intro_page_section.dart
// ============================================================================
//
// [역할]
// 온보딩 페이지 콘텐츠 섹션.
// 이미지들을 PageView로 표시.
//
// [레이어]
// Presentation Layer > Sections
// IntroScreen에서만 사용하는 화면 전용 섹션.
// ============================================================================

import 'package:flutter/material.dart';

/// 온보딩 페이지 콘텐츠 섹션.
///
/// 이미지 리스트를 PageView로 표시.
/// 스와이프 비활성화 (버튼으로만 이동).
class IntroPageSection extends StatelessWidget {
  final PageController controller;
  final List<String> images;
  final ValueChanged<int> onPageChanged;

  const IntroPageSection({
    super.key,
    required this.controller,
    required this.images,
    required this.onPageChanged,
  });

  @override
  Widget build(BuildContext context) {
    return PageView.builder(
      controller: controller,
      physics: const NeverScrollableScrollPhysics(),
      onPageChanged: onPageChanged,
      itemCount: images.length,
      itemBuilder: (context, index) =>
          _buildPage(context, images[index], index),
    );
  }

  /// 개별 페이지 빌드
  Widget _buildPage(BuildContext context, String imagePath, int index) {
    return LayoutBuilder(
      builder: (context, constraints) {
        // 하단 컨트롤 높이만큼 여유
        const bottomControlsHeight = 96.0;
        final availableHeight = constraints.maxHeight - bottomControlsHeight;

        return Align(
          alignment: const Alignment(0, -0.7), // 위로 당김
          child: ConstrainedBox(
            constraints: BoxConstraints(
              maxWidth: constraints.maxWidth * 0.94,
              maxHeight: availableHeight * 0.92,
            ),
            child: Image.asset(
              imagePath,
              fit: BoxFit.contain,
              gaplessPlayback: true,
              semanticLabel: '온보딩 이미지 ${index + 1}',
            ),
          ),
        );
      },
    );
  }
}
