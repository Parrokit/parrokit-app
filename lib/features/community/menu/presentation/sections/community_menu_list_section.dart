import 'package:flutter/material.dart';
import 'package:parrokit/features/community/menu/domain/entities/community_menu_entry.dart';
import 'package:parrokit/features/community/menu/presentation/sections/community_menu_content_section.dart';

class CommunityMenuListSection extends StatelessWidget {
  const CommunityMenuListSection({
    super.key,
    required this.sections,
  });

  final List<CommunityMenuSectionEntry> sections;

  @override
  Widget build(BuildContext context) {
    return SliverPadding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
      sliver: SliverList(
        delegate: SliverChildBuilderDelegate(
          (context, index) => CommunityMenuSection(
            section: sections[index],
            addTopSpacing: index > 0,
          ),
          childCount: sections.length,
        ),
      ),
    );
  }
}
