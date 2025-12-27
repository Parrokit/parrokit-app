// ============================================================================
// lib/features/dashboard/presentation/sections/collections_section.dart
// ============================================================================
//
// [역할]
// 대시보드 모음집(작품) 섹션.
// 작품별 클립 모음을 그리드 형태로 표시.
//
// [레이어]
// Presentation Layer > Sections
// DashboardScreen에서만 사용하는 화면 전용 섹션.
// ============================================================================

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:parrokit/core/router/app_router.dart';
import 'package:parrokit/core/theme/app_colors.dart';
import '../widgets/section_header.dart';
import '../widgets/cards/collection_card.dart';
import '../widgets/cards/empty_card.dart';

/// 대시보드 모음집 섹션.
///
/// 작품별 클립 모음을 2행 가로 스크롤 그리드로 표시.
class CollectionsSection extends StatelessWidget {
  // ─────────────────────────────────────────────────────────────────
  // 파라미터
  // ─────────────────────────────────────────────────────────────────

  /// 모음집 리스트 (titleId, nameKo, nameJa, clipCount)
  final List<(int, String, String?, int)> collections;

  const CollectionsSection({
    super.key,
    required this.collections,
  });

  // ─────────────────────────────────────────────────────────────────
  // Build
  // ─────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    final cardBg = isDark ? AppColors.surfaceContainerDark : AppColors.surface;
    final subtle = isDark
        ? Colors.white.withValues(alpha: 0.08)
        : Colors.black.withValues(alpha: 0.06);
    final textPrimary =
        isDark ? AppColors.textPrimaryDark : AppColors.textPrimary;
    final textSecondary =
        isDark ? AppColors.textSecondaryDark : AppColors.textSecondary;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // 섹션 헤더
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 24, 20, 8),
          child: SectionHeader(
            title: '모음집',
            subtitle: '작품별 정리',
            textPrimary: textPrimary,
            textSecondary: textSecondary,
          ),
        ),

        // 그리드 또는 빈 상태
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: collections.isEmpty
              ? EmptyCard(
                  noun: '작품', subtle: subtle, textSecondary: textSecondary)
              : _buildGrid(context, cardBg, subtle, textPrimary, textSecondary),
        ),
      ],
    );
  }

  /// 2행 가로 스크롤 그리드
  Widget _buildGrid(
    BuildContext context,
    Color cardBg,
    Color subtle,
    Color textPrimary,
    Color textSecondary,
  ) {
    // 2개씩 묶어서 열로 구성
    final chunks = <List<(int, String, String?, int)>>[];
    for (var i = 0; i < collections.length; i += 2) {
      chunks.add(collections.skip(i).take(2).toList());
    }

    return SizedBox(
      height: collections.length <= 1 ? 140 : 280,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: chunks.length,
        separatorBuilder: (_, __) => const SizedBox(width: 12),
        itemBuilder: (context, colIdx) {
          final col = chunks[colIdx];
          return Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: col.map((item) {
              final (id, nameKo, nameJa, clipCount) = item;
              return CollectionCard(
                titleId: id,
                nameKo: nameKo,
                nameJa: nameJa,
                clipCount: clipCount,
                cardBg: cardBg,
                subtle: subtle,
                textPrimary: textPrimary,
                textSecondary: textSecondary,
                onTap: () => context.replaceNamed(
                  AppRoutes.library,
                  queryParameters: {'titleId': id.toString()},
                ),
              );
            }).toList(),
          );
        },
      ),
    );
  }
}
