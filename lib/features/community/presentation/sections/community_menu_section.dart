import 'package:flutter/material.dart';
import '../models/community_menu_item.dart';
import '../widgets/community_menu_labels.dart';
import '../widgets/community_menu_tile.dart';

class CommunityMenuSection extends StatelessWidget {
  const CommunityMenuSection({
    super.key,
    required this.section,
    this.addTopSpacing = false,
  });

  final CommunityMenuSectionItem section;
  final bool addTopSpacing;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        if (addTopSpacing) const SizedBox(height: 18),
        CommunityMenuSectionTitle(title: section.title),
        ...List.generate(section.categories.length, (categoryIndex) {
          final category = section.categories[categoryIndex];

          return Column(
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
