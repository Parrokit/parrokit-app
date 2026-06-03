import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:parrokit/core/shared/theme/app_colors.dart';
import 'package:parrokit/core/shared/theme/app_radius.dart';
import 'package:parrokit/core/shared/theme/app_spacing.dart';
import 'package:parrokit/features/content-studio/tts/domain/repositories/tts_generation_repository.dart';
import 'package:parrokit/features/content-studio/tts/presentation/tts_provider.dart';

class TtsScreen extends StatelessWidget {
  const TtsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider<TtsProvider>(
      create: (_) => TtsProvider(),
      child: const _TtsScreenContent(),
    );
  }
}

class _TtsScreenContent extends StatefulWidget {
  const _TtsScreenContent();

  @override
  State<_TtsScreenContent> createState() => _TtsScreenContentState();
}

class _TtsScreenContentState extends State<_TtsScreenContent> {
  late final TextEditingController _textController;

  @override
  void initState() {
    super.initState();
    _textController = TextEditingController();
  }

  @override
  void dispose() {
    _textController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final mutedText =
        isDark ? AppColors.textSecondaryDark : AppColors.textSecondary;
    final provider = context.watch<TtsProvider>();

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
                onChanged: provider.updateText,
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
                child: provider.providerType == TtsProviderType.google
                    ? Column(
                        key: const ValueKey('google_options'),
                        children: [
                          _OptionRow(
                            icon: Icons.record_voice_over_rounded,
                            title: '보이스',
                            value: '밝은 내레이션',
                            accentColor: theme.colorScheme.primary,
                          ),
                          const SizedBox(height: AppSpacing.md),
                          _OptionRow(
                            icon: Icons.language_rounded,
                            title: '언어',
                            value: '한국어 (ko-KR)',
                            accentColor: theme.colorScheme.primary,
                          ),
                          const SizedBox(height: AppSpacing.md),
                          _SliderPreview(
                            label: '속도',
                            valueText: '보통',
                            value: 0.48,
                            activeColor: theme.colorScheme.primary,
                          ),
                          const SizedBox(height: AppSpacing.md),
                          _SliderPreview(
                            label: '톤',
                            valueText: '중간',
                            value: 0.54,
                            activeColor: theme.colorScheme.primary,
                          ),
                        ],
                      )
                    : Column(
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
                            value: '영어 (en-US)',
                            accentColor: AppColors.secondary,
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
                      ),
              ),
            ),
            const SizedBox(height: AppSpacing.lg),
            _Panel(
              title: '생성 미리보기',
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    height: 76,
                    decoration: BoxDecoration(
                      color: isDark
                          ? AppColors.surfaceContainerHighDark
                          : AppColors.surfaceContainerHigh,
                      borderRadius: BorderRadius.circular(AppRadius.md),
                    ),
                    child: Row(
                      children: [
                        const SizedBox(width: AppSpacing.lg),
                        CircleAvatar(
                          radius: 22,
                          backgroundColor: provider.isGenerating
                              ? Colors.grey
                              : (provider.generatedFilePath != null
                                  ? (provider.providerType == TtsProviderType.google
                                      ? theme.colorScheme.primary
                                      : AppColors.secondary)
                                  : Colors.grey.shade400),
                          child: provider.isGenerating
                              ? const SizedBox(
                                  width: 20,
                                  height: 20,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2.5,
                                    color: Colors.white,
                                  ),
                                )
                              : const Icon(
                                  Icons.play_arrow_rounded,
                                  color: Colors.white,
                                ),
                        ),
                        const SizedBox(width: AppSpacing.md),
                        Expanded(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                provider.isGenerating
                                    ? '음성을 생성하는 중...'
                                    : (provider.generatedFilePath != null
                                        ? '음성 생성 완료'
                                        : '아직 생성된 음성이 없습니다'),
                                style: theme.textTheme.titleSmall?.copyWith(
                                  fontWeight: FontWeight.w800,
                                ),
                              ),
                              const SizedBox(height: AppSpacing.xs),
                              Text(
                                provider.isGenerating
                                    ? '잠시만 기다려주세요.'
                                    : (provider.generatedFilePath != null
                                        ? '성공적으로 생성되었습니다: ${provider.generatedFilePath!.split('/').last}'
                                        : '스크립트를 입력하면 이곳에서 결과를 확인합니다.'),
                                style: theme.textTheme.bodySmall?.copyWith(
                                  color: mutedText,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: AppSpacing.lg),
                      ],
                    ),
                  ),
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
          final width = constraints.maxWidth / 2;
          final isGoogleSelected = selectedType == TtsProviderType.google;

          return Stack(
            children: [
              AnimatedPositioned(
                duration: const Duration(milliseconds: 250),
                curve: Curves.easeInOutCubic,
                left: isGoogleSelected ? 0 : width,
                right: isGoogleSelected ? width : 0,
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
                            color: isGoogleSelected
                                ? theme.colorScheme.primary
                                : (isDark
                                    ? AppColors.textSecondaryDark
                                    : AppColors.textSecondary),
                          ),
                          child: const Text('Google Cloud TTS'),
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
                            color: !isGoogleSelected
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
  });

  final IconData icon;
  final String title;
  final String value;
  final Color? accentColor;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final primaryColor = accentColor ?? theme.colorScheme.primary;

    return Container(
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
          const SizedBox(width: AppSpacing.xs),
          const Icon(Icons.keyboard_arrow_down_rounded, size: 20),
        ],
      ),
    );
  }
}

class _SliderPreview extends StatelessWidget {
  const _SliderPreview({
    required this.label,
    required this.valueText,
    required this.value,
    this.activeColor,
  });

  final String label;
  final String valueText;
  final double value;
  final Color? activeColor;

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
          onChanged: null,
          activeColor: activeColor,
        ),
      ],
    );
  }
}
