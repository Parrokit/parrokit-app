import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:parrokit/data/local/pa_database.dart';
import 'package:parrokit/core/router/pa_router.dart';
import 'package:parrokit/features/dashboard/index.dart';

class RandomSubtitleList extends StatelessWidget {
  const RandomSubtitleList({
    super.key,
    required this.segments,
    this.loading = false,
    this.skeletonCount = 3,
    this.onRetry,
  });

  /// 무작위로 뽑힌 자막 세그먼트 리스트
  final List<Segment> segments;

  /// 로딩 중이면 skeleton 타일을 그립니다.
  final bool loading;

  /// 로딩 스켈레톤 개수
  final int skeletonCount;

  /// 비었을 때 ‘다시 시도’ 콜백 (선택)
  final VoidCallback? onRetry;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    final isDark = theme.brightness == Brightness.dark;

    final cardBg = isDark ? const Color(0xFF15181C) : Colors.white;
    final textPrimary = isDark ? Colors.white : const Color(0xFF111418);
    final textSecondary =
    isDark ? Colors.white.withOpacity(.7) : const Color(0xFF556070);
    final subtle =
    isDark ? Colors.white.withOpacity(.08) : Colors.black.withOpacity(.06);

    // 1) 로딩 중: 스켈레톤 렌더
    if (loading) {
      return SliverList(
        delegate: SliverChildBuilderDelegate(
              (context, i) => Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
            child: ActivityTile.skeleton(cardBg: cardBg, subtle: subtle),
          ),
          childCount: skeletonCount,
        ),
      );
    }

    // 2) 데이터 없음: 맛깔나는 Empty State
    if (segments.isEmpty) {
      return SliverToBoxAdapter(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 8, 20, 8),
          child: EmptyCard(
            noun: '자막', // 👉 "아직 등록된 자막이 없어요"
          ),
        ),
      );
    }

    // 3) 데이터 있음: 리스트 렌더
    return SliverList(
      delegate: SliverChildBuilderDelegate(
            (context, i) {
          final seg = segments[i];
          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
            child: ActivityTile(
              title: seg.original,
              subtitleWidget: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (seg.pron != null && seg.pron.isNotEmpty)
                    Text(
                      seg.pron,
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                        color: cs.primary,
                      ),
                    ),
                  if (seg.trans != null && seg.trans!.isNotEmpty)
                    Text(
                      seg.trans,
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                        color: cs.tertiary,
                      ),
                    ),
                ],
              ),
              time: '', // 필요하면 구간 mm:ss 표시 로직 연결
              cardBg: cardBg,
              subtle: subtle,
              textPrimary: textPrimary,
              textSecondary: textSecondary,
              onTap: () => context.pushNamed(
                PaRoutes.clipsPlay,
                queryParameters: {'clipId': seg.clipId.toString()},
              ),
            ),
          );
        },
        childCount: segments.length,
      ),
    );
  }
}
class EmptyCard extends StatelessWidget {
  const EmptyCard({
    super.key,
    required this.noun,   // 예: '작품', '자막', '클립'
  });

  final String noun;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final cardBg = isDark ? const Color(0xFF15181C) : Colors.transparent;
    final subtle =
    isDark ? Colors.white.withOpacity(.08) : Colors.black.withOpacity(.06);
    final textSecondary =
    isDark ? Colors.white.withOpacity(.7) : const Color(0xFF556070);

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