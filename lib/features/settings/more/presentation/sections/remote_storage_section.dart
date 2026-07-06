// ============================================================================
// lib/features/settings/more/presentation/sections/remote_storage_section.dart
// ============================================================================
//
// [역할]
// 서버와 개인 Cloud의 원격 저장 상태를 보여주는 섹션.
// ============================================================================

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:parrokit/core/shared/theme/app_spacing.dart';
import 'package:parrokit/core/state/provider/clip_provider.dart';
import '../widgets/card_container.dart';
import '../widgets/nav_tile.dart';
import '../widgets/section_title.dart';

class RemoteStorageSection extends StatelessWidget {
  const RemoteStorageSection({super.key});

  String _formatBytes(int bytes) {
    if (bytes <= 0) return '0 B';
    const units = ['B', 'KB', 'MB', 'GB'];
    var value = bytes.toDouble();
    var unitIndex = 0;
    while (value >= 1024 && unitIndex < units.length - 1) {
      value /= 1024;
      unitIndex++;
    }
    return '${value.toStringAsFixed(value >= 10 || unitIndex == 0 ? 0 : 1)} ${units[unitIndex]}';
  }

  Widget _buildRemoteCard(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String subtitle,
    required String trailingText,
    required Color iconColor,
    required bool enabled,
  }) {
    final cs = Theme.of(context).colorScheme;

    return NavTile(
      icon: icon,
      title: title,
      subtitle: subtitle,
      showArrow: false,
      trailing: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        decoration: BoxDecoration(
          color: enabled
              ? iconColor.withValues(alpha: 0.12)
              : cs.surfaceContainerHighest,
          borderRadius: BorderRadius.circular(999),
        ),
        child: Text(
          trailingText,
          style: Theme.of(context).textTheme.labelMedium?.copyWith(
                color: enabled ? iconColor : cs.onSurfaceVariant,
                fontWeight: FontWeight.w700,
              ),
        ),
      ),
      onTap: null,
    );
  }

  @override
  Widget build(BuildContext context) {
    final clipProvider = context.watch<ClipProvider>();
    final used = clipProvider.serverStorageUsedBytes;
    final total = ClipProvider.serverStorageQuotaBytes;
    final progress = total == 0 ? 0.0 : (used / total).clamp(0.0, 1.0);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SectionTitle('원격 저장소'),
        const SizedBox(height: 10),
        CardContainer(
          child: Column(
            children: [
              _buildRemoteCard(
                context,
                icon: Icons.cloud_queue_rounded,
                title: '서버',
                subtitle: '앱 서버에 저장된 파일과 메타데이터를 보여줍니다.',
                trailingText: '${_formatBytes(used)} / ${_formatBytes(total)}',
                iconColor: Theme.of(context).colorScheme.secondary,
                enabled: true,
              ),
              const SizedBox(height: AppSpacing.sm),
              LinearProgressIndicator(
                value: progress,
                minHeight: 8,
                backgroundColor:
                    Theme.of(context).colorScheme.surfaceContainerHigh,
                valueColor: AlwaysStoppedAnimation<Color>(
                  Theme.of(context).colorScheme.secondary,
                ),
              ),
              const SizedBox(height: AppSpacing.md),
              _buildRemoteCard(
                context,
                icon: Icons.drive_folder_upload_rounded,
                title: 'Google Drive',
                subtitle: '클립을 개인 Drive에 저장하는 연결 슬롯입니다.',
                trailingText: '연결 슬롯',
                iconColor: Theme.of(context).colorScheme.primary,
                enabled: false,
              ),
            ],
          ),
        ),
      ],
    );
  }
}
