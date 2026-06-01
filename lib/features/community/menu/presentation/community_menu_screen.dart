import 'package:flutter/material.dart';
import 'package:parrokit/features/community/menu/presentation/community_menu_config.dart';
import 'package:parrokit/features/community/menu/presentation/community_menu_section.dart';
import 'package:parrokit/core/theme/app_colors.dart';

class CommunityMenuScreen extends StatelessWidget {
  const CommunityMenuScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final sections = buildCommunityMenuSections();

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: CustomScrollView(
          slivers: [
            SliverAppBar(
              pinned: true,
              backgroundColor: Colors.white,
              surfaceTintColor: Colors.white,
              elevation: 0,
              scrolledUnderElevation: 0,
              automaticallyImplyLeading: false,
              titleSpacing: 0,
              title: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Row(
                  children: [
                    const Expanded(
                      child: Text(
                        '커뮤니티 메뉴',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w800,
                          color: Colors.black,
                        ),
                      ),
                    ),
                    IconButton(
                      onPressed: () => Navigator.of(context).pop(),
                      icon: const Icon(Icons.close, size: 24, color: Colors.black),
                      tooltip: '닫기',
                    ),
                  ],
                ),
              ),
              bottom: const PreferredSize(
                preferredSize: Size.fromHeight(1),
                child: Divider(height: 1, color: AppColors.disabled),
              ),
            ),
            SliverPadding(
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
            ),
          ],
        ),
      ),
    );
  }
}
