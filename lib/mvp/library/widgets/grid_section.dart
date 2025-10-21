import 'package:flutter/material.dart';
import 'folder_card.dart';

class GridSection extends StatelessWidget {
  const GridSection({
    required this.sectionTitle,
    required this.items,
    required this.onTap,
  });

  final String sectionTitle;
  final List<String> items;
  final ValueChanged<int> onTap;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return CustomScrollView(
      slivers: [
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(12, 0, 12, 8),
            child: Text(sectionTitle,
                style: Theme.of(context)
                    .textTheme
                    .titleMedium
                    ?.copyWith(fontWeight: FontWeight.w800)),
          ),
        ),
        SliverPadding(
          padding: const EdgeInsets.symmetric(horizontal: 12),
          sliver: SliverGrid(
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 3,
              mainAxisSpacing: 8,
              crossAxisSpacing: 8,
              childAspectRatio: 1,
            ),
            delegate: SliverChildBuilderDelegate(
                  (ctx, i) => FolderCard(
                name: items[i],
                onTap: () => onTap(i),
              ),
              childCount: items.length,
            ),
          ),
        ),
        const SliverToBoxAdapter(child: SizedBox(height: 24)),
      ],
    );
  }
}
