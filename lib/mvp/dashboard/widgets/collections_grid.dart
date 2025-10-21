import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:parrokit/pa_router.dart';

class CollectionsGrid extends StatelessWidget {
  const CollectionsGrid({
    super.key,
    required this.collections,
    required this.cardBg,
    required this.subtle,
    required this.textPrimary,
    required this.textSecondary,
  });

  final List<(int, String, String?, int)> collections;
  final Color cardBg;
  final Color subtle;
  final Color textPrimary;
  final Color textSecondary;

  @override
  Widget build(BuildContext context) {
    if (collections.isEmpty) {
      return SliverToBoxAdapter(
        child: _emptyCard(),
      );
    }

    // 👉 2행 구조: 2개씩 묶어서 하나의 열로
    final chunks = <List<(int, String, String?, int)>>[];
    for (var i = 0; i < collections.length; i += 2) {
      chunks.add(collections.skip(i).take(2).toList());
    }

    return SliverToBoxAdapter(
      child: SizedBox(
        height: collections.length <= 1 ? 140 : 280,
        child: ListView.separated(
          scrollDirection: Axis.horizontal,
          // ✅ 횡스크롤
          itemCount: chunks.length,
          separatorBuilder: (_, __) => const SizedBox(width: 12),
          itemBuilder: (context, colIdx) {
            final col = chunks[colIdx];
            return Column(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: col.map((item) {
                final (id, nameKo, nameJa, clipCount) = item;
                return SizedBox(
                  width: 180,
                  height: 130,
                  child: InkWell(
                    borderRadius: BorderRadius.circular(16),
                    onTap: () => context.replaceNamed(
                      PaRoutes.library,
                      queryParameters: {'titleId': id.toString()},
                    ),
                    child: Ink(
                      decoration: BoxDecoration(
                        color: cardBg,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: subtle),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.fromLTRB(14, 12, 14, 12),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(nameKo,
                                style: TextStyle(
                                    fontWeight: FontWeight.w900,
                                    color: textPrimary)),
                            const SizedBox(height: 4),
                            Text(
                              nameJa ?? "-",
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w700,
                                color: textSecondary,
                              ),
                            ),
                            const Spacer(),
                            Row(
                              children: [
                                const Icon(Icons.auto_awesome, size: 16),
                                const SizedBox(width: 6),
                                Text(
                                  '클립 $clipCount',
                                  style: TextStyle(
                                    fontSize: 12,
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
              }).toList(),
            );
          },
        ),
      ),
    );
  }

  Widget _emptyCard() {
    return Container(
      height: 160,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: subtle),
      ),
      child: const Center(
        child: Text("아직 등록된 작품이 없어요"),
      ),
    );
  }
}
