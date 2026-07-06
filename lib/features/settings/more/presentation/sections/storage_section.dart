// ============================================================================
// lib/features/settings/more/presentation/sections/storage_section.dart
// ============================================================================
//
// [역할]
// 기기 안에 남겨둘 저장 공간을 조절하는 섹션.
// ============================================================================

import 'package:flutter/material.dart';
import 'package:parrokit/core/app/config/app_config.dart';
import 'package:parrokit/core/shared/theme/app_spacing.dart';
import '../widgets/card_container.dart';
import '../widgets/section_title.dart';

class StorageSection extends StatefulWidget {
  const StorageSection({super.key});

  @override
  State<StorageSection> createState() => _StorageSectionState();
}

class _StorageSectionState extends State<StorageSection> {
  late int _localKeepSpaceBytes;

  @override
  void initState() {
    super.initState();
    _localKeepSpaceBytes = AppConfig.localKeepSpaceBytes;
  }

  String _formatSize(int bytes) {
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

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SectionTitle('저장 공간'),
        const SizedBox(height: 10),
        CardContainer(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '기기 안에 남겨둘 공간',
                style: theme.textTheme.bodyLarge?.copyWith(
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                '자주 보는 동영상은 기기에 남겨 두면 더 빨리 열 수 있어요. 공간이 부족하면 앱이 더 보수적으로 정리합니다.',
                style: theme.textTheme.bodySmall?.copyWith(
                  color: cs.onSurfaceVariant,
                  height: 1.45,
                ),
              ),
              const SizedBox(height: AppSpacing.md),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    '현재 기준',
                    style: theme.textTheme.labelMedium?.copyWith(
                      color: cs.onSurfaceVariant,
                    ),
                  ),
                  Text(
                    _formatSize(_localKeepSpaceBytes),
                    style: theme.textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.w800,
                      color: cs.primary,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                '현재 ${_formatSize(_localKeepSpaceBytes)}를 기기 보관 기준으로 사용합니다.',
                style: theme.textTheme.bodySmall?.copyWith(
                  color: cs.onSurfaceVariant,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
