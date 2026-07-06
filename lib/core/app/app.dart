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
import 'package:parrokit/core/shared/utils/app_logger.dart';
import 'package:parrokit/core/shared/utils/has_internet.dart';
import 'package:parrokit/core/state/provider/clip_provider.dart';
import 'package:parrokit/core/state/provider/user_provider.dart';
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
  String? _backfillAttemptedUid;

  @override
  Widget build(BuildContext context) {
    final theme = context.watch<ThemeProvider>();

    final userProvider = context.watch<UserProvider>();
    final clipProvider = context.watch<ClipProvider>();

    _scheduleCollectionBackfillIfNeeded(
      context,
      userProvider: userProvider,
      clipProvider: clipProvider,
    );

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
            if (clipProvider.shouldShowCollectionBackfillBanner ||
                clipProvider.shouldShowServerUploadBanner)
              SafeArea(
                child: Align(
                  alignment: Alignment.topCenter,
                  child: Padding(
                    padding: const EdgeInsets.all(12),
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(maxWidth: 560),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          if (clipProvider.shouldShowCollectionBackfillBanner)
                            _CollectionBackfillBanner(
                              isLoading: clipProvider.isCollectionBackfilling,
                              progress: clipProvider.collectionBackfillProgress,
                              total: clipProvider.collectionBackfillTotal,
                              message: clipProvider.collectionBackfillMessage,
                              error: clipProvider.collectionBackfillError,
                            ),
                          if (clipProvider.shouldShowCollectionBackfillBanner &&
                              clipProvider.shouldShowServerUploadBanner)
                            const SizedBox(height: 10),
                          if (clipProvider.shouldShowServerUploadBanner)
                            _ServerUploadBanner(
                              isLoading: clipProvider.isServerUploadRunning,
                              progress: clipProvider.serverUploadProgress,
                              total: clipProvider.serverUploadTotal,
                              message: clipProvider.serverUploadMessage,
                              error: clipProvider.serverUploadError,
                            ),
                        ],
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

  void _scheduleCollectionBackfillIfNeeded(
    BuildContext context, {
    required UserProvider userProvider,
    required ClipProvider clipProvider,
  }) {
    final user = userProvider.currentUser;
    if (user == null || !userProvider.isLoggedIn) {
      AppLogger.d(
        '[Collection][Backfill] skip login state uid=${_maskUid(user?.id)} loggedIn=${userProvider.isLoggedIn}',
      );
      _backfillAttemptedUid = null;
      return;
    }

    if (_backfillAttemptedUid == user.id ||
        clipProvider.isCollectionBackfilling) {
      AppLogger.d(
        '[Collection][Backfill] skip duplicate-or-running uid=${_maskUid(user.id)} attempted=${_maskUid(_backfillAttemptedUid)} running=${clipProvider.isCollectionBackfilling}',
      );
      return;
    }

    _backfillAttemptedUid = user.id;
    AppLogger.i(
      '[Collection][Backfill] schedule uid=${_maskUid(user.id)}',
    );
    final userProviderRef = context.read<UserProvider>();
    final clipProviderRef = context.read<ClipProvider>();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      if (!mounted) return;
      if (userProviderRef.currentUser?.id != user.id) {
        AppLogger.d(
          '[Collection][Backfill] abort user-changed uid=${_maskUid(user.id)} current=${_maskUid(userProviderRef.currentUser?.id)}',
        );
        return;
      }
      if (!await hasInternet()) {
        AppLogger.w(
          '[Collection][Backfill] abort no-internet uid=${_maskUid(user.id)}',
        );
        _backfillAttemptedUid = null;
        return;
      }

      try {
        AppLogger.i(
          '[Collection][Backfill] start uid=${_maskUid(user.id)}',
        );
        await clipProviderRef.syncCollectionDataToServer(user.id);
        AppLogger.i(
          '[Collection][Backfill] success uid=${_maskUid(user.id)}',
        );
      } catch (_) {
        AppLogger.e(
          '[Collection][Backfill] failed uid=${_maskUid(user.id)}',
        );
        // provider가 에러 상태를 보관한다.
      }
    });
  }

  String? _maskUid(String? uid) {
    if (uid == null || uid.isEmpty) return null;
    if (uid.length <= 4) return '****';
    return '***${uid.substring(uid.length - 4)}';
  }
}

class _CollectionBackfillBanner extends StatelessWidget {
  const _CollectionBackfillBanner({
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
            ? colorScheme.tertiary
            : colorScheme.primary;
    final surfaceColor = isError
        ? colorScheme.errorContainer
        : isComplete
            ? colorScheme.tertiaryContainer.withValues(alpha: 0.75)
            : colorScheme.surfaceContainerHighest;
    final foreground = isError
        ? colorScheme.onErrorContainer
        : isComplete
            ? colorScheme.onTertiaryContainer
            : colorScheme.onSurface;
    final title = isError
        ? '동기화에 문제가 생겼어요'
        : isLoading
            ? '컬렉션을 서버에 맞추는 중'
            : '컬렉션 동기화가 끝났어요';
    final subtitle = isError
        ? '잠시 후 다시 시도할 수 있어요.'
        : isLoading
            ? '잠깐만 기다리면 최신 상태로 정리됩니다.'
            : '이제 서버와 로컬 상태가 맞춰졌어요.';

    return SafeArea(
      child: Align(
        alignment: Alignment.topCenter,
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 560),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(20),
              child: DecoratedBox(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      surfaceColor,
                      surfaceColor.withValues(alpha: 0.92),
                    ],
                  ),
                  border: Border.all(
                    color: accentColor.withValues(alpha: 0.18),
                    width: 1,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: colorScheme.shadow.withValues(alpha: 0.10),
                      blurRadius: 24,
                      offset: const Offset(0, 10),
                    ),
                  ],
                ),
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(0, 0, 0, 0),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        height: 4,
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              accentColor,
                              accentColor.withValues(alpha: 0.6),
                            ],
                          ),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 14,
                        ),
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
                                            : Icons.check_rounded,
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
                                    style: Theme.of(context)
                                        .textTheme
                                        .bodyMedium
                                        ?.copyWith(
                                          color: foreground.withValues(
                                            alpha: 0.82,
                                          ),
                                        ),
                                  ),
                                  const SizedBox(height: 12),
                                  if (isLoading && total > 0) ...[
                                    ClipRRect(
                                      borderRadius: BorderRadius.circular(999),
                                      child: LinearProgressIndicator(
                                        minHeight: 7,
                                        value: progressValue,
                                        backgroundColor: accentColor
                                            .withValues(alpha: 0.12),
                                        valueColor:
                                            AlwaysStoppedAnimation<Color>(
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
                                                color: foreground.withValues(
                                                  alpha: 0.78,
                                                ),
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
                                                color: foreground.withValues(
                                                  alpha: 0.60,
                                                ),
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
                                        style: Theme.of(context)
                                            .textTheme
                                            .bodySmall
                                            ?.copyWith(
                                              color: foreground.withValues(
                                                alpha: 0.80,
                                              ),
                                            ),
                                      ),
                                    ),
                                  ],
                                  if (!isLoading && !isError) ...[
                                    const SizedBox(height: 2),
                                    Text(
                                      message,
                                      style: Theme.of(context)
                                          .textTheme
                                          .labelMedium
                                          ?.copyWith(
                                            color: foreground.withValues(
                                              alpha: 0.72,
                                            ),
                                          ),
                                    ),
                                  ],
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
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
                            style: Theme.of(context).textTheme.labelMedium?.copyWith(
                                  color: foreground.withValues(alpha: 0.78),
                                  fontWeight: FontWeight.w600,
                                ),
                          ),
                          const Spacer(),
                          Text(
                            '잠시만 기다려주세요',
                            style: Theme.of(context).textTheme.labelMedium?.copyWith(
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
                          color: colorScheme.onErrorContainer.withValues(alpha: 0.08),
                          borderRadius: BorderRadius.circular(14),
                        ),
                        child: Text(
                          error!,
                          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                color: foreground.withValues(alpha: 0.80),
                              ),
                        ),
                      ),
                    ] else ...[
                      const SizedBox(height: 2),
                      Text(
                        message,
                        style: Theme.of(context).textTheme.labelMedium?.copyWith(
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
