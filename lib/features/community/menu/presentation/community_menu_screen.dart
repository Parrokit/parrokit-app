import 'package:flutter/material.dart';
import 'package:parrokit/features/community/menu/presentation/community_menu_config.dart';
import 'package:parrokit/features/community/menu/presentation/community_menu_section.dart';

class CommunityMenuScreen extends StatelessWidget {
  const CommunityMenuScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final sections = buildCommunityMenuSections();

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
          children: [
            Row(
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
            const SizedBox(height: 6),
            const Divider(height: 1, color: Color(0xFFEDEDED)),
            const SizedBox(height: 12),
            ...List.generate(
              sections.length,
              (index) => CommunityMenuSection(
                section: sections[index],
                addTopSpacing: index > 0,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
