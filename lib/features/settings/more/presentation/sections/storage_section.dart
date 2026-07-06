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
  static const int _minBytes = 256 * 1024 * 1024;
  static const int _maxBytes = 5 * 1024 * 1024 * 1024;
  static const int _stepBytes = 128 * 1024 * 1024;

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

  int _snapToStep(double value) {
    final clamped = value.round().clamp(_minBytes, _maxBytes);
    final snapped = ((_stepBytes / 2 + clamped) ~/ _stepBytes) * _stepBytes;
    return snapped.clamp(_minBytes, _maxBytes);
  }

  Future<void> _saveValue(int value) async {
    AppConfig.localKeepSpaceBytes = value;
    await AppConfig.saveToPrefs();
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
                '더 크게 잡으면 인터넷이 없을 때도 더 빨리 열 수 있고, 작게 잡으면 기기 공간을 더 아낄 수 있어요.',
                style: theme.textTheme.bodySmall?.copyWith(
                  color: cs.onSurfaceVariant,
                  height: 1.45,
                ),
              ),
              const SizedBox(height: AppSpacing.md),
              Row(
                children: [
                  Text(
                    _formatSize(_minBytes),
                    style: theme.textTheme.labelMedium?.copyWith(
                      color: cs.onSurfaceVariant,
                    ),
                  ),
                  Expanded(
                    child: Slider(
                      value: _localKeepSpaceBytes
                          .clamp(_minBytes, _maxBytes)
                          .toDouble(),
                      min: _minBytes.toDouble(),
                      max: _maxBytes.toDouble(),
                      divisions: ((_maxBytes - _minBytes) ~/ _stepBytes)
                          .clamp(1, 100)
                          .toInt(),
                      label: _formatSize(_localKeepSpaceBytes),
                      onChanged: (value) {
                        setState(() {
                          _localKeepSpaceBytes = _snapToStep(value);
                        });
                      },
                      onChangeEnd: (value) async {
                        final snapped = _snapToStep(value);
                        setState(() => _localKeepSpaceBytes = snapped);
                        await _saveValue(snapped);
                      },
                    ),
                  ),
                  Text(
                    _formatSize(_maxBytes),
                    style: theme.textTheme.labelMedium?.copyWith(
                      color: cs.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 4),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    '현재 설정',
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
            ],
          ),
        ),
      ],
    );
  }
}
