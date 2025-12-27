// ============================================================================
// lib/features/more/presentation/sections/backup_section.dart
// ============================================================================
//
// [역할]
// 백업 섹션 위젯.
// ============================================================================

import 'package:flutter/material.dart';

import 'package:parrokit/core/services/backup_service.dart';
import '../widgets/card_container.dart';
import '../widgets/hairline_divider.dart';
import '../widgets/tiles/nav_tile.dart';
import '../widgets/section_title.dart';

/// 백업 섹션.
class BackupSection extends StatelessWidget {
  const BackupSection({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SectionTitle('백업'),
        const SizedBox(height: 10),
        CardContainer(
          child: Column(
            children: [
              NavTile(
                icon: Icons.privacy_tip_outlined,
                title: '불러오기',
                onTap: () async => await BackupService.instance.restoreBackup(),
              ),
              const HairlineDivider(),
              NavTile(
                icon: Icons.mail_outline,
                title: '저장하기',
                onTap: () async => await BackupService.instance.createBackup(),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
