// ============================================================================
// lib/features/settings/more/presentation/sections/storage_section.dart
// ============================================================================
//
// [역할]
// 기기 안에 남겨둘 저장 공간을 조절하는 섹션.
// ============================================================================

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:parrokit/core/app/config/app_config.dart';
import 'package:parrokit/core/app/router/app_router.dart';
import 'package:parrokit/core/shared/theme/app_spacing.dart';
import 'package:parrokit/core/state/provider/clip_provider.dart';
import 'package:parrokit/features/collection/library/presentation/widgets/clip_list_view.dart';
import 'package:provider/provider.dart';
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

  Future<void> _showKeepSpaceManager(BuildContext context) async {
    final provider = context.read<ClipProvider>();
    final localItemsFuture = provider.fetchClipItemsByStorageMode('local');

    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      backgroundColor: Colors.transparent,
      builder: (sheetContext) {
        final theme = Theme.of(sheetContext);
        return DraggableScrollableSheet(
          initialChildSize: 0.9,
          minChildSize: 0.6,
          maxChildSize: 0.95,
          builder: (context, scrollController) {
            return Container(
              decoration: BoxDecoration(
                color: theme.colorScheme.surface,
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(24),
                ),
              ),
              child: SafeArea(
                top: false,
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(16, 10, 16, 16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Center(
                        child: Container(
                          width: 42,
                          height: 4,
                          decoration: BoxDecoration(
                            color: theme.colorScheme.outlineVariant,
                            borderRadius: BorderRadius.circular(999),
                          ),
                        ),
                      ),
                      const SizedBox(height: 12),
                      Text(
                        '기기 안에 남겨둘 항목 관리',
                        style: theme.textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        '자주 보는 동영상은 이 기기에 남겨 두면 바로 열 수 있어요. 공간이 부족하면 직접 옮기거나 정리할 수 있습니다.',
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: theme.colorScheme.onSurfaceVariant,
                          height: 1.4,
                        ),
                      ),
                      const SizedBox(height: 12),
                      Expanded(
                        child: FutureBuilder(
                          future: localItemsFuture,
                          builder: (context, snapshot) {
                            if (snapshot.connectionState ==
                                ConnectionState.waiting) {
                              return const Center(
                                child: CircularProgressIndicator(),
                              );
                            }
                            if (snapshot.hasError) {
                              return Center(
                                child: Text(
                                  '기기 보관 목록을 불러오지 못했어요.',
                                  style: theme.textTheme.bodyMedium,
                                ),
                              );
                            }

                            final items = snapshot.data ?? const [];
                            if (items.isEmpty) {
                              return Center(
                                child: Text(
                                  '기기에 남아 있는 동영상이 없습니다.',
                                  style: theme.textTheme.bodyMedium,
                                ),
                              );
                            }

                            return ClipListView(
                              items: items,
                              onOpen: (item) {
                                context.pushNamed(
                                  AppRoutes.clipsPlay,
                                  queryParameters: {
                                    'clipId': '${item.clip.id}',
                                  },
                                );
                              },
                            );
                          },
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        );
      },
    );
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
        GestureDetector(
          onTap: () => _showKeepSpaceManager(context),
          child: CardContainer(
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
                  '자주 보는 동영상은 기기에 남겨 두고, 공간이 부족하면 직접 줄일 수 있어요.',
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
        ),
      ],
    );
  }
}
