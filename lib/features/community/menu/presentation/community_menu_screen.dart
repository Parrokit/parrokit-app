import 'package:flutter/material.dart';
import 'package:parrokit/features/community/menu/data/factories/community_menu_section_factory.dart';
import 'package:parrokit/features/community/menu/presentation/sections/community_menu_header_section.dart';
import 'package:parrokit/features/community/menu/presentation/sections/community_menu_list_section.dart';

class CommunityMenuScreen extends StatelessWidget {
  const CommunityMenuScreen({super.key});

  @override
  Widget build(BuildContext context) {
    const factory = CommunityMenuSectionFactory();
    final sections = factory.build();
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      backgroundColor: colorScheme.surface,
      body: SafeArea(
        child: CustomScrollView(
          slivers: [
            const CommunityMenuHeaderSection(),
            CommunityMenuListSection(sections: sections),
          ],
        ),
      ),
    );
  }
}
