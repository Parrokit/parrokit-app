import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:just_audio/just_audio.dart';
import 'dart:async';
import 'package:google_mlkit_language_id/google_mlkit_language_id.dart';

import 'package:parrokit/core/shared/utils/app_logger.dart';

import 'package:parrokit/core/shared/theme/app_colors.dart';
import 'package:parrokit/core/shared/theme/app_radius.dart';
import 'package:parrokit/core/shared/theme/app_spacing.dart';
import 'package:parrokit/features/content-studio/tts/domain/repositories/tts_generation_repository.dart';
import 'package:parrokit/features/content-studio/tts/presentation/tts_provider.dart';
import 'package:parrokit/features/content-studio/tts/domain/models/tts_language.dart';

class TtsScreen extends StatelessWidget {
  const TtsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const _TtsScreenContent();
  }
}

class _TtsScreenContent extends StatefulWidget {
  const _TtsScreenContent();

  @override
  State<_TtsScreenContent> createState() => _TtsScreenContentState();
}

class _TtsScreenContentState extends State<_TtsScreenContent> {
  late final TextEditingController _textController;
  Timer? _debounce;
  final _languageIdentifier = LanguageIdentifier(confidenceThreshold: 0.5);

  @override
  void initState() {
    super.initState();
    _textController = TextEditingController();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        context.read<TtsProvider>().fetchAvailableVoices();
      }
    });
  }

  @override
  void dispose() {
    _debounce?.cancel();
    _languageIdentifier.close();
    _textController.dispose();
    super.dispose();
  }

  void _onTextChanged(String text, TtsProvider provider) {
    provider.updateText(text);

    if (_debounce?.isActive ?? false) _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 500), () async {
      if (text.trim().isNotEmpty) {
        try {
          AppLogger.d('[TTS][LanguageDetection] attempt text="$text"');
          final languageCode = await _languageIdentifier.identifyLanguage(text);
          AppLogger.d('[TTS][LanguageDetection] identified code=$languageCode');
          
          if (languageCode != 'und') {
            final ttsLang = getLanguageByMlKitCode(languageCode);
            AppLogger.d('[TTS][LanguageDetection] mapped ttsLang=${ttsLang?.ttsCode} displayName=${ttsLang?.displayName}');
            
            if (ttsLang != null && mounted) {
              AppLogger.d('[TTS][LanguageDetection] update provider prevLanguage=${provider.language} newLanguage=${ttsLang.ttsCode}');
              if (provider.language != ttsLang.ttsCode) {
                provider.updateLanguage(ttsLang.ttsCode);
                provider.fetchAvailableVoices();
              }
            }
          }
        } catch (e) {
          AppLogger.e('[TTS][LanguageDetection] failed', error: e);
        }
      }
    });
  }

  void _showLanguageSelectionSheet(BuildContext context, TtsProvider provider) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => _LanguageSelectionSheet(provider: provider),
    );
  }

  void _showVoiceSelectionSheet(BuildContext context, TtsProvider provider) {
    if (provider.availableVoices.isEmpty) {
      provider.fetchAvailableVoices();
    }
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => _VoiceSelectionSheet(provider: provider),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final mutedText =
        isDark ? AppColors.textSecondaryDark : AppColors.textSecondary;
    final provider = context.watch<TtsProvider>();

    if (_textController.text != provider.text) {
      _textController.value = _textController.value.copyWith(
        text: provider.text,
        selection: TextSelection.collapsed(offset: provider.text.length),
      );
    }

    return Scaffold(
      backgroundColor: theme.colorScheme.surface,
      body: SafeArea(
        top: false,
        child: ListView(
          padding: const EdgeInsets.fromLTRB(
            AppSpacing.lg,
            AppSpacing.lg,
            AppSpacing.lg,
            24,
          ),
          children: [
            _StudioHero(
              icon: Icons.graphic_eq_rounded,
              title: '텍스트를 자연스러운 음성으로',
              description: '스크립트와 보이스 톤을 정하면 학습 클립용 음성 파일을 만들 수 있습니다.',
            ),
            const SizedBox(height: AppSpacing.sectionGap),
            _Panel(
              title: '스크립트',
              trailing: Text(
                '${provider.text.length} / 240',
                style: theme.textTheme.labelMedium?.copyWith(
                  color: mutedText,
                ),
              ),
              child: TextField(
                controller: _textController,
                minLines: 7,
                maxLines: 10,
                maxLength: 240,
                onChanged: (val) => _onTextChanged(val, provider),
                decoration: const InputDecoration(
                  hintText: '예: 오늘 배울 표현은 “Could you give me a hand?” 입니다.',
                  alignLabelWithHint: true,
                  counterText: '',
                ),
              ),
            ),
            const SizedBox(height: AppSpacing.lg),
            _ProviderSelector(
              selectedType: provider.providerType,
              onTypeChanged: provider.updateProviderType,
            ),
            const SizedBox(height: AppSpacing.lg),
            _Panel(
              title: '보이스 설정',
              child: AnimatedSwitcher(
                duration: const Duration(milliseconds: 300),
                transitionBuilder: (Widget child, Animation<double> animation) {
                  return FadeTransition(
                    opacity: animation,
                    child: SizeTransition(
                      sizeFactor: animation,
                      axisAlignment: 0.0,
                      child: child,
                    ),
                  );
                },
                child: () {
                  switch (provider.providerType) {
                    case TtsProviderType.google:
                      return Column(
                        key: const ValueKey('google_options'),
                        children: [
                          _OptionRow(
                            icon: Icons.language_rounded,
                            title: '언어',
                            value: getLanguageByTtsCode(provider.language).displayName,
                            accentColor: theme.colorScheme.primary,
                            onTap: () => _showLanguageSelectionSheet(context, provider),
                          ),
                          const SizedBox(height: AppSpacing.md),
                          _OptionRow(
                            icon: Icons.record_voice_over_rounded,
                            title: '보이스',
                            value: provider.isLoadingVoices 
                                ? '목록 불러오는 중...' 
                                : (provider.voiceId.isEmpty ? '선택 (기본값)' : provider.voiceId),
                            accentColor: theme.colorScheme.primary,
                            onTap: () => _showVoiceSelectionSheet(context, provider),
                          ),
                          const SizedBox(height: AppSpacing.md),
                          _SliderPreview(
                            label: '속도 (0.25배 ~ 4.0배)',
                            valueText: '${provider.speakingRate.toStringAsFixed(2)}x',
                            value: provider.speakingRate,
                            min: 0.25,
                            max: 4.0,
                            activeColor: theme.colorScheme.primary,
                            onChanged: provider.updateSpeakingRate,
                          ),
                          const SizedBox(height: AppSpacing.md),
                          _SliderPreview(
                            label: '톤 (-20 ~ 20)',
                            valueText: provider.pitch > 0 ? '+${provider.pitch.toStringAsFixed(1)}' : provider.pitch.toStringAsFixed(1),
                            value: provider.pitch,
                            min: -20.0,
                            max: 20.0,
                            activeColor: theme.colorScheme.primary,
                            onChanged: provider.updatePitch,
                          ),
                        ],
                      );
                    case TtsProviderType.elevenlabs:
                      return Column(
                        key: const ValueKey('elevenlabs_options'),
                        children: [
                          _OptionRow(
                            icon: Icons.record_voice_over_rounded,
                            title: '보이스',
                            value: 'Rachel (Bella)',
                            accentColor: AppColors.secondary,
                          ),
                          const SizedBox(height: AppSpacing.md),
                          _OptionRow(
                            icon: Icons.language_rounded,
                            title: '언어',
                            value: getLanguageByTtsCode(provider.language).displayName,
                            accentColor: AppColors.secondary,
                            onTap: () => _showLanguageSelectionSheet(context, provider),
                          ),
                          const SizedBox(height: AppSpacing.md),
                          _SliderPreview(
                            label: '안정성 (Stability)',
                            valueText: '보통 (50%)',
                            value: 0.50,
                            activeColor: AppColors.secondary,
                          ),
                          const SizedBox(height: AppSpacing.md),
                          _SliderPreview(
                            label: '유사도 (Clarity)',
                            valueText: '높음 (75%)',
                            value: 0.75,
                            activeColor: AppColors.secondary,
                          ),
                        ],
                      );
                    case TtsProviderType.gemini:
                      return Column(
                        key: const ValueKey('gemini_options'),
                        children: [
                          _OptionRow(
                            icon: Icons.record_voice_over_rounded,
                            title: '보이스 에이전트',
                            value: 'Aoede',
                            accentColor: const Color(0xFF9B72CB),
                          ),
                          const SizedBox(height: AppSpacing.md),
                          _OptionRow(
                            icon: Icons.language_rounded,
                            title: '언어',
                            value: getLanguageByTtsCode(provider.language).displayName,
                            accentColor: const Color(0xFF9B72CB),
                            onTap: () => _showLanguageSelectionSheet(context, provider),
                          ),
                          const SizedBox(height: AppSpacing.md),
                          _SliderPreview(
                            label: '감정 표현 강도',
                            valueText: '풍부하게',
                            value: 0.8,
                            activeColor: const Color(0xFF9B72CB),
                          ),
                        ],
                      );
                  }
                }(),
              ),
            ),
            const SizedBox(height: AppSpacing.lg),
            _Panel(
              title: '생성 미리보기',
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _TtsAudioPlayerWidget(provider: provider),
                  if (provider.errorMessage != null) ...[
                    const SizedBox(height: AppSpacing.sm),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xs),
                      child: Text(
                        provider.errorMessage!,
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.colorScheme.error,
                        ),
                      ),
                    ),
                  ],
                  const SizedBox(height: AppSpacing.lg),
                  SizedBox(
                    width: double.infinity,
                    child: FilledButton.icon(
                      onPressed: provider.isGenerating || provider.text.trim().isEmpty
                          ? null
                          : () => provider.generateTts(),
                      style: FilledButton.styleFrom(
                        backgroundColor: provider.providerType == TtsProviderType.google
                            ? theme.colorScheme.primary
                            : AppColors.secondary,
                      ),
                      icon: provider.isGenerating
                          ? const SizedBox(
                              width: 16,
                              height: 16,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: Colors.white70,
                              ),
                            )
                          : const Icon(Icons.auto_awesome_rounded),
                      label: const Text('음성 생성'),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ProviderSelector extends StatelessWidget {
  const _ProviderSelector({
    required this.selectedType,
    required this.onTypeChanged,
  });

  final TtsProviderType selectedType;
  final ValueChanged<TtsProviderType> onTypeChanged;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    final bg = isDark
        ? AppColors.surfaceContainerHighDark
        : AppColors.surfaceContainerHigh;

    return Container(
      height: 48,
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(AppRadius.md),
      ),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final width = constraints.maxWidth / 3;
          int selectedIndex = 0;
          if (selectedType == TtsProviderType.elevenlabs) {
            selectedIndex = 1;
          } else if (selectedType == TtsProviderType.gemini) {
            selectedIndex = 2;
          }

          return Stack(
            children: [
              AnimatedPositioned(
                duration: const Duration(milliseconds: 250),
                curve: Curves.easeInOutCubic,
                left: selectedIndex * width,
                width: width,
                top: 0,
                bottom: 0,
                child: Container(
                  decoration: BoxDecoration(
                    color: isDark ? AppColors.surfaceContainerDark : Colors.white,
                    borderRadius: BorderRadius.circular(AppRadius.sm),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: isDark ? 0.2 : 0.06),
                        blurRadius: 4,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                ),
              ),
              Row(
                children: [
                  Expanded(
                    child: GestureDetector(
                      behavior: HitTestBehavior.opaque,
                      onTap: () => onTypeChanged(TtsProviderType.google),
                      child: Center(
                        child: AnimatedDefaultTextStyle(
                          duration: const Duration(milliseconds: 200),
                          style: theme.textTheme.bodyMedium!.copyWith(
                            fontWeight: FontWeight.w800,
                            color: selectedType == TtsProviderType.google
                                ? theme.colorScheme.primary
                                : (isDark
                                    ? AppColors.textSecondaryDark
                                    : AppColors.textSecondary),
                          ),
                          child: const Text('Google Cloud'),
                        ),
                      ),
                    ),
                  ),
                  Expanded(
                    child: GestureDetector(
                      behavior: HitTestBehavior.opaque,
                      onTap: () => onTypeChanged(TtsProviderType.elevenlabs),
                      child: Center(
                        child: AnimatedDefaultTextStyle(
                          duration: const Duration(milliseconds: 200),
                          style: theme.textTheme.bodyMedium!.copyWith(
                            fontWeight: FontWeight.w800,
                            color: selectedType == TtsProviderType.elevenlabs
                                ? AppColors.secondary
                                : (isDark
                                    ? AppColors.textSecondaryDark
                                    : AppColors.textSecondary),
                          ),
                          child: const Text('ElevenLabs'),
                        ),
                      ),
                    ),
                  ),
                  Expanded(
                    child: GestureDetector(
                      behavior: HitTestBehavior.opaque,
                      onTap: () => onTypeChanged(TtsProviderType.gemini),
                      child: Center(
                        child: selectedType == TtsProviderType.gemini
                            ? ShaderMask(
                                shaderCallback: (bounds) => AppColors.geminiGradient.createShader(bounds),
                                blendMode: BlendMode.srcIn,
                                child: Text(
                                  'Gemini',
                                  style: theme.textTheme.bodyMedium!.copyWith(
                                    fontWeight: FontWeight.w900,
                                    color: Colors.white, // Required for ShaderMask
                                  ),
                                ),
                              )
                            : AnimatedDefaultTextStyle(
                                duration: const Duration(milliseconds: 200),
                                style: theme.textTheme.bodyMedium!.copyWith(
                                  fontWeight: FontWeight.w800,
                                  color: isDark
                                      ? AppColors.textSecondaryDark
                                      : AppColors.textSecondary,
                                ),
                                child: const Text('Gemini'),
                              ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          );
        },
      ),
    );
  }
}

class _StudioHero extends StatelessWidget {
  const _StudioHero({
    required this.icon,
    required this.title,
    required this.description,
  });

  final IconData icon;
  final String title;
  final String description;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Container(
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: isDark ? AppColors.primarySubtleDark : AppColors.primarySubtle,
        borderRadius: BorderRadius.circular(AppRadius.md),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: theme.colorScheme.primary,
              borderRadius: BorderRadius.circular(AppRadius.sm),
            ),
            child: Icon(icon, color: Colors.white),
          ),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: AppSpacing.xs),
                Text(
                  description,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: isDark
                        ? AppColors.textSecondaryDark
                        : AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _Panel extends StatelessWidget {
  const _Panel({
    required this.title,
    required this.child,
    this.trailing,
  });

  final String title;
  final Widget child;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Container(
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: isDark ? AppColors.surfaceContainerDark : AppColors.surface,
        borderRadius: BorderRadius.circular(AppRadius.md),
        border: Border.all(
          color: isDark ? AppColors.dividerSubtleDark : AppColors.dividerSubtle,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  title,
                  style: theme.textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ),
              if (trailing != null) trailing!,
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          child,
        ],
      ),
    );
  }
}

class _OptionRow extends StatelessWidget {
  const _OptionRow({
    required this.icon,
    required this.title,
    required this.value,
    this.accentColor,
    this.onTap,
  });

  final IconData icon;
  final String title;
  final String value;
  final Color? accentColor;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final primaryColor = accentColor ?? theme.colorScheme.primary;

    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Container(
        height: 52,
        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
        decoration: BoxDecoration(
          color: isDark
              ? AppColors.surfaceContainerHighDark
              : AppColors.surfaceContainer,
          borderRadius: BorderRadius.circular(AppRadius.sm),
        ),
        child: Row(
          children: [
            Icon(icon, size: 20, color: primaryColor),
            const SizedBox(width: AppSpacing.md),
            Expanded(
              child: Text(
                title,
                style: theme.textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
            Text(
              value,
              style: theme.textTheme.bodyMedium,
            ),
            if (onTap != null) ...[
              const SizedBox(width: AppSpacing.xs),
              const Icon(Icons.keyboard_arrow_down_rounded, size: 20),
            ] else if (title == '보이스') ...[
              const SizedBox(width: AppSpacing.xs),
              const Icon(Icons.keyboard_arrow_down_rounded, size: 20),
            ],
          ],
        ),
      ),
    );
  }
}

class _SliderPreview extends StatelessWidget {
  const _SliderPreview({
    required this.label,
    required this.valueText,
    required this.value,
    this.min = 0.0,
    this.max = 1.0,
    this.activeColor,
    this.onChanged,
  });

  final String label;
  final String valueText;
  final double value;
  final double min;
  final double max;
  final Color? activeColor;
  final ValueChanged<double>? onChanged;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: Text(
                label,
                style: theme.textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
            Text(
              valueText,
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurface.withValues(alpha: 0.68),
              ),
            ),
          ],
        ),
        Slider(
          value: value,
          min: min,
          max: max,
          onChanged: onChanged,
          activeColor: activeColor,
        ),
      ],
    );
  }
}

class _TtsAudioPlayerWidget extends StatefulWidget {
  const _TtsAudioPlayerWidget({required this.provider});

  final TtsProvider provider;

  @override
  State<_TtsAudioPlayerWidget> createState() => _TtsAudioPlayerWidgetState();
}

class _TtsAudioPlayerWidgetState extends State<_TtsAudioPlayerWidget> {
  late AudioPlayer _player;
  bool _isPlaying = false;
  String? _currentFilePath;
  Duration _position = Duration.zero;
  Duration _duration = Duration.zero;

  @override
  void initState() {
    super.initState();
    _player = AudioPlayer();
    _player.playerStateStream.listen((state) {
      if (mounted) {
        setState(() {
          _isPlaying = state.playing && state.processingState != ProcessingState.completed;
        });
      }
    });
    _player.positionStream.listen((position) {
      if (mounted) setState(() => _position = position);
    });
    _player.durationStream.listen((duration) {
      if (mounted) setState(() => _duration = duration ?? Duration.zero);
    });
  }

  @override
  void didUpdateWidget(covariant _TtsAudioPlayerWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.provider.isGenerating) {
      _player.stop();
      _currentFilePath = null;
    } else if (widget.provider.generatedFilePath != null &&
        widget.provider.generatedFilePath != _currentFilePath) {
      _currentFilePath = widget.provider.generatedFilePath;
      _player.setFilePath(_currentFilePath!);
    }
  }

  @override
  void dispose() {
    _player.dispose();
    super.dispose();
  }

  void _togglePlay() async {
    if (_currentFilePath == null) return;

    if (_isPlaying) {
      await _player.pause();
    } else {
      if (_player.processingState == ProcessingState.completed) {
        await _player.seek(Duration.zero);
      }
      await _player.play();
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final mutedText = isDark ? AppColors.textSecondaryDark : AppColors.textSecondary;

    return Container(
      height: 76,
      decoration: BoxDecoration(
        color: isDark ? AppColors.surfaceContainerHighDark : AppColors.surfaceContainerHigh,
        borderRadius: BorderRadius.circular(AppRadius.md),
      ),
      child: Row(
        children: [
          const SizedBox(width: AppSpacing.lg),
          GestureDetector(
            onTap: widget.provider.isGenerating || widget.provider.generatedFilePath == null ? null : _togglePlay,
            child: CircleAvatar(
              radius: 22,
              backgroundColor: widget.provider.isGenerating
                  ? Colors.grey
                  : (widget.provider.generatedFilePath != null
                      ? (widget.provider.providerType == TtsProviderType.google
                          ? theme.colorScheme.primary
                          : AppColors.secondary)
                      : Colors.grey.shade400),
              child: widget.provider.isGenerating
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2.5,
                        color: Colors.white,
                      ),
                    )
                  : Icon(
                      _isPlaying ? Icons.pause_rounded : Icons.play_arrow_rounded,
                      color: Colors.white,
                    ),
            ),
          ),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.provider.isGenerating
                      ? '음성을 생성하는 중...'
                      : (widget.provider.generatedFilePath != null
                          ? '음성 생성 완료'
                          : '아직 생성된 음성이 없습니다'),
                  style: theme.textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: AppSpacing.xs),
                if (widget.provider.generatedFilePath != null && !widget.provider.isGenerating)
                  Row(
                    children: [
                      Text(
                        '${_position.inSeconds} / ${_duration.inSeconds}s',
                        style: theme.textTheme.labelSmall?.copyWith(
                          color: mutedText,
                        ),
                      ),
                      const SizedBox(width: AppSpacing.sm),
                      Expanded(
                        child: LinearProgressIndicator(
                          value: _duration.inMilliseconds > 0
                              ? _position.inMilliseconds / _duration.inMilliseconds
                              : 0.0,
                          backgroundColor: isDark ? AppColors.dividerSubtleDark : AppColors.dividerSubtle,
                          color: widget.provider.providerType == TtsProviderType.google
                              ? theme.colorScheme.primary
                              : AppColors.secondary,
                        ),
                      ),
                      const SizedBox(width: AppSpacing.lg),
                    ],
                  )
                else
                  Text(
                    widget.provider.isGenerating
                        ? '잠시만 기다려주세요.'
                        : '스크립트를 입력하면 결과를 확인합니다.',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: mutedText,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
              ],
            ),
          ),
          if (widget.provider.generatedFilePath == null || widget.provider.isGenerating)
            const SizedBox(width: AppSpacing.lg),
        ],
      ),
    );
  }
}

class _LanguageSelectionSheet extends StatefulWidget {
  const _LanguageSelectionSheet({required this.provider});

  final TtsProvider provider;

  @override
  State<_LanguageSelectionSheet> createState() => _LanguageSelectionSheetState();
}

class _LanguageSelectionSheetState extends State<_LanguageSelectionSheet> {
  final TextEditingController _searchController = TextEditingController();
  List<TtsLanguage> _filteredLanguages = supportedTtsLanguages;

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _filterLanguages(String query) {
    if (query.isEmpty) {
      setState(() => _filteredLanguages = supportedTtsLanguages);
      return;
    }
    final lowerQuery = query.toLowerCase();
    setState(() {
      _filteredLanguages = supportedTtsLanguages.where((lang) {
        return lang.displayName.toLowerCase().contains(lowerQuery) ||
               lang.ttsCode.toLowerCase().contains(lowerQuery);
      }).toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Container(
      constraints: BoxConstraints(
        maxHeight: MediaQuery.of(context).size.height * 0.8,
      ),
      decoration: BoxDecoration(
        color: isDark ? AppColors.surfaceDark : AppColors.surface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(AppRadius.lg)),
      ),
      child: Column(
        children: [
          const SizedBox(height: AppSpacing.sm),
          Container(
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: isDark ? Colors.grey.shade700 : Colors.grey.shade300,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(height: AppSpacing.lg),
          Text(
            '언어 선택',
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
            child: TextField(
              controller: _searchController,
              onChanged: _filterLanguages,
              decoration: InputDecoration(
                hintText: '언어 검색...',
                prefixIcon: const Icon(Icons.search_rounded),
                filled: true,
                fillColor: isDark ? AppColors.surfaceContainerHighDark : AppColors.surfaceContainerHigh,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(AppRadius.md),
                  borderSide: BorderSide.none,
                ),
                contentPadding: const EdgeInsets.symmetric(vertical: 0, horizontal: AppSpacing.md),
              ),
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
              itemCount: _filteredLanguages.length,
              itemBuilder: (context, index) {
                final lang = _filteredLanguages[index];
                final isSelected = widget.provider.language == lang.ttsCode;
                
                return ListTile(
                  title: Text(
                    lang.displayName,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                      color: isSelected ? theme.colorScheme.primary : null,
                    ),
                  ),
                  trailing: isSelected 
                    ? Icon(Icons.check_circle_rounded, color: theme.colorScheme.primary) 
                    : null,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(AppRadius.sm),
                  ),
                  onTap: () {
                    if (widget.provider.language != lang.ttsCode) {
                      widget.provider.updateLanguage(lang.ttsCode);
                      widget.provider.fetchAvailableVoices();
                    }
                    Navigator.pop(context);
                  },
                );
              },
            ),
          ),
          const SizedBox(height: AppSpacing.xl),
        ],
      ),
    );
  }
}

class _VoiceModelOption {
  final String originalName;
  final String engine;
  final String variant;
  final Map<String, dynamic> rawData;

  _VoiceModelOption(this.originalName, this.engine, this.variant, this.rawData);
}

class _VoiceSelectionSheet extends StatefulWidget {
  const _VoiceSelectionSheet({required this.provider});

  final TtsProvider provider;

  @override
  State<_VoiceSelectionSheet> createState() => _VoiceSelectionSheetState();
}

class _VoiceSelectionSheetState extends State<_VoiceSelectionSheet> {
  final Map<String, List<_VoiceModelOption>> _engineToVariants = {};
  String? _selectedEngine;

  @override
  void initState() {
    super.initState();
    _parseVoices();
    _initSelection();
  }

  @override
  void didUpdateWidget(covariant _VoiceSelectionSheet oldWidget) {
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
          _VoiceModelOption(name, engine, variant, v)
        );
      } else {
        _engineToVariants.putIfAbsent('기타', () => []).add(
          _VoiceModelOption(name, '기타', name, v)
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
