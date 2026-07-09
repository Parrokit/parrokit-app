// ============================================================================
// lib/core/app.dart
// ============================================================================
//
// [역할]
// 앱 루트 위젯.
// MaterialApp 설정 및 테마/라우터 구성.
//
// [레이어]
// Core Layer
// ============================================================================

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:parrokit/core/state/provider/clip_provider.dart';
import 'package:parrokit/core/state/provider/theme_provider.dart';
import 'package:parrokit/core/shared/theme/app_theme.dart';

final scaffoldMessengerKey = GlobalKey<ScaffoldMessengerState>();

class App extends StatefulWidget {
  const App({super.key, required this.router});

  final GoRouter router;

  @override
  State<App> createState() => _AppState();
}

class _AppState extends State<App> {
  @override
  Widget build(BuildContext context) {
    final theme = context.watch<ThemeProvider>();

    final clipProvider = context.watch<ClipProvider>();

    return MaterialApp.router(
      title: 'Parrokit',
      scaffoldMessengerKey: scaffoldMessengerKey,
      theme: AppTheme.light,
      darkTheme: AppTheme.dark,
      themeMode: theme.themeMode,
      routerConfig: widget.router,
      debugShowCheckedModeBanner: false,
      builder: (context, child) {
        return Stack(
          children: [
            Positioned.fill(child: child ?? const SizedBox.shrink()),
            if (clipProvider.shouldShowServerUploadBanner ||
                clipProvider.shouldShowCloudUploadBanner)
              SafeArea(
                child: Align(
                  alignment: Alignment.topCenter,
                  child: Padding(
                    padding: const EdgeInsets.all(12),
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(maxWidth: 560),
                      child: ConstrainedBox(
                        constraints: BoxConstraints(
                          maxHeight: MediaQuery.sizeOf(context).height * 0.35,
                        ),
                        child: SingleChildScrollView(
                          physics: const BouncingScrollPhysics(),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              if (clipProvider.shouldShowServerUploadBanner)
                                _ServerUploadBanner(
                                  isLoading: clipProvider.isServerUploadRunning,
                                  progress: clipProvider.serverUploadProgress,
                                  total: clipProvider.serverUploadTotal,
                                  message: clipProvider.serverUploadMessage,
                                  error: clipProvider.serverUploadError,
                                ),
                              if (clipProvider.shouldShowServerUploadBanner &&
                                  clipProvider.shouldShowCloudUploadBanner)
                                const SizedBox(height: 10),
                              if (clipProvider.shouldShowCloudUploadBanner)
                                _CloudUploadBanner(
                                  isLoading: clipProvider.isCloudUploadRunning,
                                  progress: clipProvider.cloudUploadProgress,
                                  total: clipProvider.cloudUploadTotal,
                                  message: clipProvider.cloudUploadMessage,
                                  error: clipProvider.cloudUploadError,
                                ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
          ],
        );
      },
    );
  }
}

class _ServerUploadBanner extends StatelessWidget {
  const _ServerUploadBanner({
    required this.isLoading,
    required this.progress,
    required this.total,
    required this.message,
    required this.error,
  });

  final bool isLoading;
  final int progress;
  final int total;
  final String message;
  final String? error;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final progressValue = total > 0 ? (progress / total).clamp(0.0, 1.0) : null;
    final isError = error != null;
    final isComplete = !isLoading && error == null;
    final accentColor = isError
        ? colorScheme.error
        : isComplete
            ? colorScheme.secondary
            : colorScheme.primary;
    final surfaceColor = isError
        ? colorScheme.errorContainer
        : isComplete
            ? colorScheme.secondaryContainer.withValues(alpha: 0.75)
            : colorScheme.surfaceContainerHighest;
    final foreground = isError
        ? colorScheme.onErrorContainer
        : isComplete
            ? colorScheme.onSecondaryContainer
            : colorScheme.onSurface;
    final title = isError
        ? '서버 저장에 실패했어요'
        : isLoading
            ? '클립을 서버에 올리는 중'
            : '서버 저장이 끝났어요';
    final subtitle = isError
        ? '잠시 후 다시 시도할 수 있어요.'
        : isLoading
            ? '파일을 서버로 옮기고 있습니다.'
            : '서버 저장이 완료됐어요.';

    return ClipRRect(
      borderRadius: BorderRadius.circular(20),
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: surfaceColor,
          border: Border.all(
            color: accentColor.withValues(alpha: 0.18),
            width: 1,
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: accentColor.withValues(alpha: 0.12),
                  shape: BoxShape.circle,
                ),
                child: Center(
                  child: isLoading
                      ? SizedBox(
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            value: progressValue,
                            color: accentColor,
                          ),
                        )
                      : Icon(
                          isError
                              ? Icons.error_outline_rounded
                              : Icons.cloud_done_rounded,
                          size: 20,
                          color: accentColor,
                        ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            title,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: Theme.of(context)
                                .textTheme
                                .titleMedium
                                ?.copyWith(
                                  color: foreground,
                                  fontWeight: FontWeight.w700,
                                ),
                          ),
                        ),
                        if (!isLoading && !isError)
                          Icon(
                            Icons.done_rounded,
                            size: 18,
                            color: accentColor,
                          ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      subtitle,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: foreground.withValues(alpha: 0.82),
                          ),
                    ),
                    const SizedBox(height: 12),
                    if (isLoading && total > 0) ...[
                      ClipRRect(
                        borderRadius: BorderRadius.circular(999),
                        child: LinearProgressIndicator(
                          minHeight: 7,
                          value: progressValue,
                          backgroundColor: accentColor.withValues(alpha: 0.12),
                          valueColor: AlwaysStoppedAnimation<Color>(
                            accentColor,
                          ),
                        ),
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          Text(
                            '$progress / $total',
                            style: Theme.of(context)
                                .textTheme
                                .labelMedium
                                ?.copyWith(
                                  color: foreground.withValues(alpha: 0.78),
                                  fontWeight: FontWeight.w600,
                                ),
                          ),
                          const Spacer(),
                          Text(
                            '잠시만 기다려주세요',
                            style: Theme.of(context)
                                .textTheme
                                .labelMedium
                                ?.copyWith(
                                  color: foreground.withValues(alpha: 0.60),
                                ),
                          ),
                        ],
                      ),
                    ] else if (isError) ...[
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: colorScheme.onErrorContainer
                              .withValues(alpha: 0.08),
                          borderRadius: BorderRadius.circular(14),
                        ),
                        child: Text(
                          error!,
                          style:
                              Theme.of(context).textTheme.bodySmall?.copyWith(
                                    color: foreground.withValues(alpha: 0.80),
                                  ),
                        ),
                      ),
                    ] else ...[
                      const SizedBox(height: 2),
                      Text(
                        message,
                        style:
                            Theme.of(context).textTheme.labelMedium?.copyWith(
                                  color: foreground.withValues(alpha: 0.72),
                                ),
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _CloudUploadBanner extends StatelessWidget {
  const _CloudUploadBanner({
    required this.isLoading,
    required this.progress,
    required this.total,
    required this.message,
    required this.error,
  });

  final bool isLoading;
  final int progress;
  final int total;
  final String message;
  final String? error;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final progressValue = total > 0 ? (progress / total).clamp(0.0, 1.0) : null;
    final isError = error != null;
    final isComplete = !isLoading && error == null;
    final accentColor = isError
        ? colorScheme.error
        : isComplete
            ? colorScheme.primary
            : colorScheme.secondary;
    final surfaceColor = isError
        ? colorScheme.errorContainer
        : isComplete
            ? colorScheme.primaryContainer.withValues(alpha: 0.75)
            : colorScheme.surfaceContainerHighest;
    final foreground = isError
        ? colorScheme.onErrorContainer
        : isComplete
            ? colorScheme.onPrimaryContainer
            : colorScheme.onSurface;
    final title = isError
        ? 'Google Drive 저장에 실패했어요'
        : isLoading
            ? 'Google Drive에 올리는 중'
            : 'Google Drive 저장이 끝났어요';
    final subtitle = isError
        ? '잠시 후 다시 시도할 수 있어요.'
        : isLoading
            ? '내 Drive 폴더에 파일을 저장하고 있습니다.'
            : '이제 개인 Cloud에 저장되어 있어요.';

    return ClipRRect(
      borderRadius: BorderRadius.circular(20),
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: surfaceColor,
          border: Border.all(
            color: accentColor.withValues(alpha: 0.18),
            width: 1,
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: accentColor.withValues(alpha: 0.12),
                  shape: BoxShape.circle,
                ),
                child: Center(
                  child: isLoading
                      ? SizedBox(
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            value: progressValue,
                            color: accentColor,
                          ),
                        )
                      : Icon(
                          isError
                              ? Icons.error_outline_rounded
                              : Icons.cloud_done_rounded,
                          size: 20,
                          color: accentColor,
                        ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            title,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: Theme.of(context)
                                .textTheme
                                .titleMedium
                                ?.copyWith(
                                  color: foreground,
                                  fontWeight: FontWeight.w700,
                                ),
                          ),
                        ),
                        if (!isLoading && !isError)
                          Icon(
                            Icons.done_rounded,
                            size: 18,
                            color: accentColor,
                          ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      subtitle,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: foreground.withValues(alpha: 0.82),
                          ),
                    ),
                    const SizedBox(height: 12),
                    if (isLoading && total > 0) ...[
                      ClipRRect(
                        borderRadius: BorderRadius.circular(999),
                        child: LinearProgressIndicator(
                          minHeight: 7,
                          value: progressValue,
                          backgroundColor: accentColor.withValues(alpha: 0.12),
                          valueColor: AlwaysStoppedAnimation<Color>(
                            accentColor,
                          ),
                        ),
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          Text(
                            '$progress / $total',
                            style: Theme.of(context)
                                .textTheme
                                .labelMedium
                                ?.copyWith(
                                  color: foreground.withValues(alpha: 0.78),
                                  fontWeight: FontWeight.w600,
                                ),
                          ),
                          const Spacer(),
                          Text(
                            '잠시만 기다려주세요',
                            style: Theme.of(context)
                                .textTheme
                                .labelMedium
                                ?.copyWith(
                                  color: foreground.withValues(alpha: 0.60),
                                ),
                          ),
                        ],
                      ),
                    ] else if (isError) ...[
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: colorScheme.onErrorContainer
                              .withValues(alpha: 0.08),
                          borderRadius: BorderRadius.circular(14),
                        ),
                        child: Text(
                          error!,
                          style:
                              Theme.of(context).textTheme.bodySmall?.copyWith(
                                    color: foreground.withValues(alpha: 0.80),
                                  ),
                        ),
                      ),
                    ] else ...[
                      const SizedBox(height: 2),
                      Text(
                        message,
                        style:
                            Theme.of(context).textTheme.labelMedium?.copyWith(
                                  color: foreground.withValues(alpha: 0.72),
                                ),
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
