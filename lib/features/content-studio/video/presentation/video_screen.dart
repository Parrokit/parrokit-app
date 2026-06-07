import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:video_player/video_player.dart';

import 'package:parrokit/core/shared/theme/app_colors.dart';
import 'package:parrokit/core/shared/theme/app_radius.dart';
import 'package:parrokit/core/shared/theme/app_spacing.dart';
import 'package:parrokit/features/content-studio/video/presentation/video_provider.dart';

class VideoScreen extends StatefulWidget {
  const VideoScreen({super.key});

  @override
  State<VideoScreen> createState() => _VideoScreenState();
}

class _VideoScreenState extends State<VideoScreen> {
  late final TextEditingController _promptController;

  @override
  void initState() {
    super.initState();
    _promptController = TextEditingController();
  }

  @override
  void dispose() {
    _promptController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final mutedText =
        isDark ? AppColors.textSecondaryDark : AppColors.textSecondary;
    final provider = context.watch<VideoProvider>();

    if (_promptController.text != provider.scenePrompt) {
      _promptController.value = _promptController.value.copyWith(
        text: provider.scenePrompt,
        selection: TextSelection.collapsed(offset: provider.scenePrompt.length),
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
            _VideoPreview(isDark: isDark),
            const SizedBox(height: AppSpacing.sectionGap),
            _Panel(
              title: '영상 프롬프트',
              trailing: Text(
                '${provider.scenePrompt.length} / 500',
                style: theme.textTheme.labelMedium?.copyWith(
                  color: mutedText,
                ),
              ),
              child: TextField(
                controller: _promptController,
                minLines: 5,
                maxLines: 8,
                onChanged: provider.updateScenePrompt,
                decoration: const InputDecoration(
                  hintText: '예: 책상 위 노트북 화면에 영어 회화 문장이 나타나는 밝은 학습 영상',
                  alignLabelWithHint: true,
                ),
              ),
            ),
            const SizedBox(height: AppSpacing.lg),
            _Panel(
              title: '영상 설정',
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _OptionGroup(
                    label: '화면비',
                    options: const ['9:16', '1:1', '16:9'],
                    selectedIndex: 0,
                  ),
                  const SizedBox(height: AppSpacing.lg),
                  _OptionGroup(
                    label: '길이',
                    options: const ['5초', '10초', '15초'],
                    selectedIndex: 1,
                  ),
                  const SizedBox(height: AppSpacing.lg),
                  _StyleRow(
                    icon: Icons.palette_rounded,
                    title: '스타일',
                    value: '교육용 모션',
                  ),
                  const SizedBox(height: AppSpacing.md),
                  _StyleRow(
                    icon: Icons.closed_caption_rounded,
                    title: '자막',
                    value: '자동 포함',
                  ),
                ],
              ),
            ),
            const SizedBox(height: AppSpacing.lg),
            _Panel(
              title: '생성 준비',
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      _InfoPill(
                        icon: Icons.bolt_rounded,
                        text: '예상 8 코인',
                      ),
                      const SizedBox(width: AppSpacing.sm),
                      _InfoPill(
                        icon: Icons.schedule_rounded,
                        text: '약 1분',
                      ),
                    ],
                  ),
                  const SizedBox(height: AppSpacing.lg),
                  SizedBox(
                    width: double.infinity,
                    child: FilledButton.icon(
                      onPressed: provider.isGenerating || provider.scenePrompt.trim().isEmpty
                          ? null
                          : provider.generateVideo,
                      icon: provider.isGenerating
                          ? const SizedBox(
                              width: 16,
                              height: 16,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: Colors.white,
                              ),
                            )
                          : const Icon(Icons.movie_creation_rounded),
                      label: Text(provider.isGenerating ? '영상 생성 중...' : '영상 생성'),
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

class _VideoPreview extends StatefulWidget {
  const _VideoPreview({required this.isDark});

  final bool isDark;

  @override
  State<_VideoPreview> createState() => _VideoPreviewState();
}

class _VideoPreviewState extends State<_VideoPreview> {
  VideoPlayerController? _controller;
  String? _lastUrl;
  String? _playerError;

  @override
  void dispose() {
    _controller?.dispose();
    super.dispose();
  }

  void _initPlayer(String url) async {
    if (_lastUrl == url) return;
    _lastUrl = url;
    _playerError = null;
    
    final oldController = _controller;
    final newController = VideoPlayerController.networkUrl(Uri.parse(url));
    _controller = newController;
    
    try {
      await newController.initialize();
      newController.setLooping(true);
      newController.play();
    } catch (e) {
      debugPrint("Video initialization error: $e");
      if (mounted) {
        setState(() {
          _playerError = "영상을 불러올 수 없습니다. 네트워크 연결이나 권한을 확인하세요.";
        });
      }
    }
    
    oldController?.dispose();
    if (mounted) setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final mutedText =
        widget.isDark ? AppColors.textSecondaryDark : AppColors.textSecondary;
    final provider = context.watch<VideoProvider>();
    final videoUrl = provider.generatedFilePath;

    if (videoUrl != null && videoUrl.isNotEmpty) {
      _initPlayer(videoUrl);
    } else {
      if (_controller != null) {
        _controller?.dispose();
        _controller = null;
        _lastUrl = null;
      }
    }

    return AspectRatio(
      aspectRatio: 16 / 9,
      child: Container(
        padding: videoUrl != null ? EdgeInsets.zero : const EdgeInsets.all(AppSpacing.lg),
        decoration: BoxDecoration(
          color: widget.isDark
              ? AppColors.surfaceContainerDark
              : AppColors.surfaceContainer,
          borderRadius: BorderRadius.circular(AppRadius.md),
          border: Border.all(
            color: widget.isDark ? AppColors.dividerSubtleDark : AppColors.dividerSubtle,
          ),
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(AppRadius.md),
          child: Stack(
            children: [
              if (videoUrl == null) ...[
                Positioned.fill(
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      color: widget.isDark
                          ? AppColors.surfaceContainerHighDark
                          : AppColors.surfaceContainerHigh,
                      borderRadius: BorderRadius.circular(AppRadius.sm),
                    ),
                  ),
                ),
                Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        width: 56,
                        height: 56,
                        decoration: BoxDecoration(
                          color: theme.colorScheme.primary,
                          borderRadius: BorderRadius.circular(AppRadius.md),
                        ),
                        child: const Icon(
                          Icons.smart_display_rounded,
                          color: Colors.white,
                          size: 30,
                        ),
                      ),
                      const SizedBox(height: AppSpacing.md),
                      Text(
                        '영상 미리보기',
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                      const SizedBox(height: AppSpacing.xs),
                      Text(
                        '생성 결과가 이 영역에 표시됩니다.',
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: mutedText,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),
              ] else if (_controller != null && _controller!.value.isInitialized) ...[
                Positioned.fill(
                  child: VideoPlayer(_controller!),
                ),
                // Simple play/pause overlay
                Positioned.fill(
                  child: GestureDetector(
                    onTap: () {
                      setState(() {
                        if (_controller!.value.isPlaying) {
                          _controller!.pause();
                        } else {
                          _controller!.play();
                        }
                      });
                    },
                    child: Container(
                      color: Colors.transparent,
                      child: _controller!.value.isPlaying
                          ? const SizedBox.shrink()
                          : Container(
                              color: Colors.black26,
                              child: const Center(
                                child: Icon(Icons.play_arrow_rounded, color: Colors.white, size: 48),
                              ),
                            ),
                    ),
                  ),
                ),
              ] else if (_playerError != null) ...[
                Center(
                  child: Padding(
                    padding: const EdgeInsets.all(AppSpacing.lg),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.error_outline_rounded, color: Colors.red, size: 32),
                        const SizedBox(height: AppSpacing.md),
                        Text(
                          _playerError!,
                          style: theme.textTheme.bodyMedium?.copyWith(color: Colors.red),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  ),
                ),
              ] else ...[
                const Center(child: CircularProgressIndicator()),
              ],
            ],
          ),
        ),
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

class _OptionGroup extends StatelessWidget {
  const _OptionGroup({
    required this.label,
    required this.options,
    required this.selectedIndex,
  });

  final String label;
  final List<String> options;
  final int selectedIndex;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: theme.textTheme.bodyMedium?.copyWith(
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: AppSpacing.sm),
        Row(
          children: [
            for (var i = 0; i < options.length; i++) ...[
              Expanded(
                child: _ChoiceTile(
                  label: options[i],
                  selected: i == selectedIndex,
                ),
              ),
              if (i != options.length - 1) const SizedBox(width: AppSpacing.sm),
            ],
          ],
        ),
      ],
    );
  }
}

class _ChoiceTile extends StatelessWidget {
  const _ChoiceTile({
    required this.label,
    required this.selected,
  });

  final String label;
  final bool selected;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Container(
      height: 44,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: selected
            ? theme.colorScheme.primary
            : isDark
                ? AppColors.surfaceContainerHighDark
                : AppColors.surfaceContainer,
        borderRadius: BorderRadius.circular(AppRadius.sm),
      ),
      child: Text(
        label,
        style: theme.textTheme.labelLarge?.copyWith(
          color: selected ? Colors.white : theme.colorScheme.onSurface,
          fontWeight: FontWeight.w900,
        ),
      ),
    );
  }
}

class _StyleRow extends StatelessWidget {
  const _StyleRow({
    required this.icon,
    required this.title,
    required this.value,
  });

  final IconData icon;
  final String title;
  final String value;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

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
          Icon(icon, size: 20, color: theme.colorScheme.primary),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Text(
              title,
              style: theme.textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          Text(value, style: theme.textTheme.bodyMedium),
          const SizedBox(width: AppSpacing.xs),
          const Icon(Icons.keyboard_arrow_down_rounded, size: 20),
        ],
      ),
    );
  }
}

class _InfoPill extends StatelessWidget {
  const _InfoPill({
    required this.icon,
    required this.text,
  });

  final IconData icon;
  final String text;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Expanded(
      child: Container(
        height: 40,
        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
        decoration: BoxDecoration(
          color: isDark ? AppColors.primarySubtleDark : AppColors.primarySubtle,
          borderRadius: BorderRadius.circular(AppRadius.full),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 18, color: theme.colorScheme.primary),
            const SizedBox(width: AppSpacing.xs),
            Flexible(
              child: Text(
                text,
                style: theme.textTheme.labelMedium?.copyWith(
                  color: theme.colorScheme.primary,
                  fontWeight: FontWeight.w800,
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
