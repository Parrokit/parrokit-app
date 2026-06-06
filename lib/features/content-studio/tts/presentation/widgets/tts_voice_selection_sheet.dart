import 'package:flutter/material.dart';
import 'package:parrokit/core/shared/theme/app_colors.dart';
import 'package:parrokit/core/shared/theme/app_radius.dart';
import 'package:parrokit/core/shared/theme/app_spacing.dart';
import 'package:parrokit/features/content-studio/tts/presentation/providers/tts_provider.dart';

class VoiceModelOption {
  final String originalName;
  final String engine;
  final String variant;
  final Map<String, dynamic> rawData;

  VoiceModelOption(this.originalName, this.engine, this.variant, this.rawData);
}

class TtsVoiceSelectionSheet extends StatefulWidget {
  const TtsVoiceSelectionSheet({super.key, required this.provider});

  final TtsProvider provider;

  @override
  State<TtsVoiceSelectionSheet> createState() => _TtsVoiceSelectionSheetState();
}

class _TtsVoiceSelectionSheetState extends State<TtsVoiceSelectionSheet> {
  final Map<String, List<VoiceModelOption>> _engineToVariants = {};
  String? _selectedEngine;

  @override
  void initState() {
    super.initState();
    _parseVoices();
    _initSelection();
  }

  @override
  void didUpdateWidget(covariant TtsVoiceSelectionSheet oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.provider.availableVoices != oldWidget.provider.availableVoices) {
      _parseVoices();
      _initSelection();
    }
  }

  void _parseVoices() {
    _engineToVariants.clear();
    for (final v in widget.provider.availableVoices) {
      final name = (v['name'] ?? '').toString();
      final parts = name.split('-');
      if (parts.length >= 2) {
        final variant = parts.last;
        final engine = parts[parts.length - 2];
        
        _engineToVariants.putIfAbsent(engine, () => []).add(
          VoiceModelOption(name, engine, variant, v)
        );
      } else {
        _engineToVariants.putIfAbsent('기타', () => []).add(
          VoiceModelOption(name, '기타', name, v)
        );
      }
    }
    
    // 알파벳 순으로 변형(Variant) 정렬
    for (final engine in _engineToVariants.keys) {
      _engineToVariants[engine]!.sort((a, b) => a.variant.compareTo(b.variant));
    }
  }

  void _initSelection() {
    final currentVoice = widget.provider.voiceId;
    if (currentVoice.isNotEmpty) {
      final parts = currentVoice.split('-');
      if (parts.length >= 2) {
        final engine = parts[parts.length - 2];
        if (_engineToVariants.containsKey(engine)) {
          _selectedEngine = engine;
        }
      }
    }
    
    if (_selectedEngine == null || !_engineToVariants.containsKey(_selectedEngine)) {
      if (_engineToVariants.isNotEmpty) {
        // 기본적으로 가장 항목이 많은 엔진을 선택하거나 첫 번째 선택
        _selectedEngine = _engineToVariants.keys.first;
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Container(
      constraints: BoxConstraints(
        maxHeight: MediaQuery.of(context).size.height * 0.85,
      ),
      decoration: BoxDecoration(
        color: isDark ? AppColors.surfaceDark : AppColors.surface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(AppRadius.lg)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: AppSpacing.sm),
          Center(
            child: Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: isDark ? Colors.grey.shade700 : Colors.grey.shade300,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          const SizedBox(height: AppSpacing.lg),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
            child: Text(
              '보이스 모델 선택',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          if (widget.provider.isLoadingVoices)
            const Expanded(child: Center(child: CircularProgressIndicator()))
          else if (_engineToVariants.isEmpty)
            Expanded(
              child: Center(
                child: Text(
                  '선택할 수 있는 보이스가 없습니다.',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondary,
                  ),
                ),
              ),
            )
          else ...[
            // 엔진 선택 영역
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
              child: Text(
                '엔진 (Engine)',
                style: theme.textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.w700,
                  color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondary,
                ),
              ),
            ),
            const SizedBox(height: AppSpacing.sm),
            SizedBox(
              height: 40,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
                itemCount: _engineToVariants.keys.length,
                separatorBuilder: (context, index) => const SizedBox(width: AppSpacing.sm),
                itemBuilder: (context, index) {
                  final engine = _engineToVariants.keys.elementAt(index);
                  final isSelected = _selectedEngine == engine;
                  return ChoiceChip(
                    label: Text(engine),
                    selected: isSelected,
                    onSelected: (selected) {
                      if (selected) {
                        setState(() => _selectedEngine = engine);
                      }
                    },
                    selectedColor: theme.colorScheme.primary.withValues(alpha: 0.15),
                    labelStyle: theme.textTheme.bodyMedium?.copyWith(
                      fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                      color: isSelected ? theme.colorScheme.primary : (isDark ? Colors.white : Colors.black),
                    ),
                    side: isSelected ? BorderSide(color: theme.colorScheme.primary) : null,
                  );
                },
              ),
            ),
            const SizedBox(height: AppSpacing.lg),
            // 변형(Variant) 선택 영역
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
              child: Text(
                '모델 (Variant)',
                style: theme.textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.w700,
                  color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondary,
                ),
              ),
            ),
            const SizedBox(height: AppSpacing.sm),
            Expanded(
              child: _selectedEngine == null
                  ? const SizedBox.shrink()
                  : ListView.builder(
                      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
                      itemCount: _engineToVariants[_selectedEngine!]!.length,
                      itemBuilder: (context, index) {
                        final option = _engineToVariants[_selectedEngine!]![index];
                        final isSelected = widget.provider.voiceId == option.originalName;
                        
                        // 성별이나 샘플링 레이트 등 추가 정보
                        final gender = option.rawData['ssmlGender'] ?? '';
                        final hz = option.rawData['naturalSampleRateHertz'] ?? '';
                        
                        return ListTile(
                          title: Text(
                            'Variant ${option.variant}',
                            style: theme.textTheme.bodyMedium?.copyWith(
                              fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                              color: isSelected ? theme.colorScheme.primary : null,
                            ),
                          ),
                          subtitle: Text(
                            '$gender ${hz != '' ? '• ${hz}Hz' : ''}',
                            style: theme.textTheme.labelSmall?.copyWith(
                              color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondary,
                            ),
                          ),
                          trailing: isSelected 
                            ? Icon(Icons.check_circle_rounded, color: theme.colorScheme.primary) 
                            : null,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(AppRadius.sm),
                          ),
                          onTap: () {
                            widget.provider.updateVoiceId(option.originalName);
                            Navigator.pop(context);
                          },
                        );
                      },
                    ),
            ),
          ],
          const SizedBox(height: AppSpacing.xl),
        ],
      ),
    );
  }
}
