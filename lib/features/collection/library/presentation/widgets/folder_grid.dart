import 'package:flutter/material.dart';
import 'package:parrokit/core/shared/theme/app_spacing.dart';
import 'folder_card.dart';

class FolderGrid extends StatelessWidget {
  const FolderGrid({
    super.key,
    required this.sectionTitle,
    required this.items,
    required this.onTap,
    this.deleteMode = false,
  });

  final String sectionTitle;
  final List<String> items;
  final ValueChanged<int> onTap;
  final bool deleteMode;

  @override
  Widget build(BuildContext context) {
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
        if (items.isEmpty)
          const SliverFillRemaining(
            child: Center(child: Text('아직 등록된 컬렉션이 없어요.')),
          )
        else
        SliverPadding(
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
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
                deleteMode: deleteMode,
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
