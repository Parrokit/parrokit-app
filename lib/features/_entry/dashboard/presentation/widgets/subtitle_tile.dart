// ============================================================================
// lib/features/dashboard/presentation/widgets/subtitle_tile.dart
// ============================================================================
//
// [역할]
// 자막 타일 위젯. 랜덤 자막 리스트에서 각 세그먼트를 표시.
//
// [레이어]
// Presentation Layer > Widgets
// 순수 재사용 위젯 - RandomSubtitleSection에서 사용.
// ============================================================================

import 'package:flutter/material.dart';

/// 자막 타일 위젯.
///
/// 원문, 발음, 번역을 카드 형태로 표시.
/// 스켈레톤 로딩 상태도 지원.
class SubtitleTile extends StatelessWidget {
  final String original;
  final String? pron;
  final String? trans;
  final Color cardBg;
  final Color subtle;
  final Color textPrimary;
  final Color primaryColor;
  final Color tertiaryColor;
  final VoidCallback onTap;

  const SubtitleTile({
    super.key,
    required this.original,
    required this.pron,
    required this.trans,
    required this.cardBg,
    required this.subtle,
    required this.textPrimary,
    required this.primaryColor,
    required this.tertiaryColor,
    required this.onTap,
  });

  /// 스켈레톤 로딩 상태
  factory SubtitleTile.skeleton({
    required Color cardBg,
    required Color subtle,
  }) {
    return _SubtitleTileSkeleton(cardBg: cardBg, subtle: subtle);
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: cardBg,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: subtle),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 원문
            Text(
              original,
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w700,
                color: textPrimary,
              ),
            ),

            // 발음
            if (pron != null && pron!.isNotEmpty) ...[
              const SizedBox(height: 4),
              Text(
                pron!,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  color: primaryColor,
                ),
              ),
            ],

            // 번역
            if (trans != null && trans!.isNotEmpty) ...[
              const SizedBox(height: 2),
              Text(
                trans!,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  color: tertiaryColor,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

/// 스켈레톤 타일 (private)
class _SubtitleTileSkeleton extends SubtitleTile {
  _SubtitleTileSkeleton({
    required super.cardBg,
    required super.subtle,
  }) : super(
          original: '',
          pron: null,
          trans: null,
          textPrimary: Colors.transparent,
          primaryColor: Colors.transparent,
          tertiaryColor: Colors.transparent,
          onTap: () {},
        );

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 80,
      decoration: BoxDecoration(
        color: cardBg,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: subtle),
      ),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 200,
              height: 16,
              decoration: BoxDecoration(
                color: subtle,
                borderRadius: BorderRadius.circular(4),
              ),
            ),
            const SizedBox(height: 8),
            Container(
              width: 120,
              height: 12,
              decoration: BoxDecoration(
                color: subtle,
                borderRadius: BorderRadius.circular(4),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
