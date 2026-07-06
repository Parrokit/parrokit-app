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
import '../widgets/section_title.dart';

class RemoteStorageSection extends StatefulWidget {
  const RemoteStorageSection({super.key});

  @override
  State<RemoteStorageSection> createState() => _RemoteStorageSectionState();
}

class _RemoteStorageSectionState extends State<RemoteStorageSection> {
  bool _isExpanded = true;

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

  Widget _buildToggle(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 0),
      child: Material(
        color: cs.surfaceContainerHighest.withValues(alpha: 0.35),
        borderRadius: BorderRadius.circular(16),
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: () => setState(() => _isExpanded = !_isExpanded),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            child: Row(
              children: [
                Icon(Icons.tune_rounded, size: 18, color: cs.primary),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    '저장 용량',
                    style: Theme.of(context).textTheme.labelLarge?.copyWith(
                          fontWeight: FontWeight.w800,
                          color: cs.onSurface,
                        ),
                  ),
                ),
                Text(
                  _isExpanded ? '접기' : '펼치기',
                  style: Theme.of(context).textTheme.labelMedium?.copyWith(
                        color: cs.onSurfaceVariant,
                        fontWeight: FontWeight.w600,
                      ),
                ),
                const SizedBox(width: 4),
                Icon(
                  _isExpanded
                      ? Icons.keyboard_arrow_up_rounded
                      : Icons.keyboard_arrow_down_rounded,
                  color: cs.onSurfaceVariant,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildUsageCard(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String subtitle,
    required String usageText,
    required Color color,
    double? progress,
  }) {
    final cs = Theme.of(context).colorScheme;

    return Container(
      padding: const EdgeInsets.fromLTRB(14, 12, 14, 12),
      decoration: BoxDecoration(
        color: cs.surfaceContainerHighest.withValues(alpha: 0.45),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: cs.outlineVariant.withValues(alpha: 0.35),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 18, color: color),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  title,
                  style: Theme.of(context).textTheme.labelLarge?.copyWith(
                        fontWeight: FontWeight.w800,
                        color: cs.onSurface,
                      ),
                ),
              ),
              Text(
                usageText,
                style: Theme.of(context).textTheme.labelMedium?.copyWith(
                      color: cs.onSurfaceVariant,
                      fontWeight: FontWeight.w600,
                    ),
              ),
            ],
          ),
          if (progress != null) ...[
            const SizedBox(height: 10),
            ClipRRect(
              borderRadius: BorderRadius.circular(999),
              child: LinearProgressIndicator(
                value: progress.clamp(0.0, 1.0),
                minHeight: 10,
                backgroundColor: cs.surfaceContainerHigh,
                valueColor: AlwaysStoppedAnimation<Color>(color),
              ),
            ),
          ],
          const SizedBox(height: 8),
          Text(
            subtitle,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: cs.onSurfaceVariant,
                ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final clipProvider = context.watch<ClipProvider>();
    final localUsed = clipProvider.localStorageUsedBytes;
    final serverUsed = clipProvider.serverStorageUsedBytes;
    final serverTotal = ClipProvider.serverStorageQuotaBytes;
    final serverProgress =
        serverTotal == 0 ? 0.0 : (serverUsed / serverTotal).clamp(0.0, 1.0);
    final cloudUsed = clipProvider.cloudStorageUsedBytes;
    final cloudQuota = clipProvider.cloudStorageQuotaBytes;
    final hasCloudQuota = cloudQuota != null && cloudQuota > 0;
    final cloudProgress =
        hasCloudQuota ? (cloudUsed / cloudQuota).clamp(0.0, 1.0) : null;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SectionTitle('원격 저장소'),
        const SizedBox(height: 10),
        _buildToggle(context),
        if (_isExpanded) ...[
          const SizedBox(height: 10),
          CardContainer(
            child: Column(
              children: [
                _buildUsageCard(
                  context,
                  icon: Icons.phone_android_rounded,
                  title: '로컬',
                  subtitle: '이 기기에 남아 있어 오프라인에서도 바로 열 수 있는 파일입니다.',
                  usageText: _formatBytes(localUsed),
                  color: Theme.of(context).colorScheme.tertiary,
                ),
                const SizedBox(height: AppSpacing.sm),
                _buildUsageCard(
                  context,
                  icon: Icons.cloud_queue_rounded,
                  title: '서버',
                  subtitle: '앱 서버에 저장된 파일과 메타데이터를 보여줍니다.',
                  usageText:
                      '${_formatBytes(serverUsed)} / ${_formatBytes(serverTotal)}',
                  color: Theme.of(context).colorScheme.secondary,
                  progress: serverProgress,
                ),
                const SizedBox(height: AppSpacing.sm),
                _buildUsageCard(
                  context,
                  icon: Icons.drive_folder_upload_rounded,
                  title: 'Google Drive',
                  subtitle: hasCloudQuota
                      ? '개인 Drive에 저장된 클립 용량입니다.'
                      : '개인 Drive에 저장된 클립 용량입니다. Drive 상한은 아직 가져오지 못했어요.',
                  usageText: hasCloudQuota
                      ? '${_formatBytes(cloudUsed)} / ${_formatBytes(cloudQuota)}'
                      : _formatBytes(cloudUsed),
                  color: Theme.of(context).colorScheme.primary,
                  progress: cloudProgress,
                ),
              ],
            ),
          ),
        ],
      ],
    );
  }
}
