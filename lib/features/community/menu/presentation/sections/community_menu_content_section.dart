import 'package:flutter/material.dart';
import 'package:parrokit/features/community/menu/domain/entities/community_menu_entry.dart';
import 'package:parrokit/features/community/menu/presentation/widgets/community_menu_labels.dart';
import 'package:parrokit/features/community/menu/presentation/widgets/community_menu_tile.dart';

class CommunityMenuSection extends StatelessWidget {
  const CommunityMenuSection({
    super.key,
    required this.section,
    this.addTopSpacing = false,
  });

  final CommunityMenuSectionEntry section;
  final bool addTopSpacing;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (addTopSpacing) const SizedBox(height: 18),
        CommunityMenuSectionTitle(title: section.title),
        ...List.generate(section.categories.length, (categoryIndex) {
          final category = section.categories[categoryIndex];

          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (category.title != null) ...[
                if (categoryIndex > 0) const SizedBox(height: 8),
                CommunityMenuCategoryLabel(title: category.title!),
              ],
              ...category.items.map((item) => CommunityMenuTile(item: item)),
            ],
          );
        }),
      ],
    );
  }
}
