import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:parrokit/core/shared/theme/app_spacing.dart';
import 'package:go_router/go_router.dart';
import 'package:parrokit/data/models/clip_item.dart';
import 'package:parrokit/core/app/router/app_router.dart';
import 'package:parrokit/core/state/provider/clip_provider.dart';
import 'package:parrokit/core/shared/theme/app_colors.dart';
import 'package:parrokit/core/shared/theme/app_radius.dart';
import 'package:parrokit/features/collection/library/presentation/providers/tag_filter_provider.dart';
import 'package:parrokit/core/shared/utils/show_toast.dart';
import 'package:provider/provider.dart';
import 'episode_thumbnail.dart';
import 'swipe_action_tile.dart';
import 'mini_chip.dart';

class ClipListView extends StatelessWidget {
  const ClipListView({
    super.key,
    required this.items,
    required this.onOpen,
    this.resolveThumb,
  });

  final List<ClipItem> items;
  final ValueChanged<ClipItem> onOpen;
  final ImageProvider<Object>? Function(ClipItem item)? resolveThumb;

  String _fmtMs(int ms) {
    final total = ms ~/ 1000;
    final m = total ~/ 60;
    final s = total % 60;
    return '${m.toString().padLeft(2, '0')}분 ${s.toString().padLeft(2, '0')}초';
  }

  String? _storageLabel(String storageMode) {
    if (storageMode == 'local') return '로컬';
    if (storageMode == 'server') return '서버';
    if (storageMode == 'cloud') return '클라우드';

    if (storageMode.startsWith('cloud:')) {
      final provider = storageMode.split(':').length > 1
          ? storageMode.split(':')[1]
          : '';
      final providerLabel = switch (provider) {
        'gdrive' => 'Google Drive',
        'icloud' => 'iCloud',
        'dropbox' => 'Dropbox',
        _ => null,
      };
      return providerLabel == null ? '클라우드' : '클라우드 · $providerLabel';
    }

    return null;
  }

  Widget? _buildStorageChip(BuildContext context, String storageMode) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;

    final label = _storageLabel(storageMode);

    if (label == null) return null;

    final isCloud = storageMode.startsWith('cloud');

    final background = switch (storageMode) {
      'local' => cs.secondaryContainer.withValues(alpha: 0.55),
      'server' => cs.tertiaryContainer.withValues(alpha: 0.55),
      'cloud' => cs.primaryContainer.withValues(alpha: 0.55),
      _ when isCloud => cs.primaryContainer.withValues(alpha: 0.55),
      _ => cs.secondaryContainer.withValues(alpha: 0.55),
    };

    final foreground = switch (storageMode) {
      'local' => cs.onSecondaryContainer.withValues(alpha: 0.9),
      'server' => cs.onTertiaryContainer.withValues(alpha: 0.9),
      'cloud' => cs.onPrimaryContainer.withValues(alpha: 0.9),
      _ when isCloud => cs.onPrimaryContainer.withValues(alpha: 0.9),
      _ => cs.onSecondaryContainer.withValues(alpha: 0.9),
    };

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(AppRadius.xs),
      ),
      child: Text(
        label,
        style: theme.textTheme.labelSmall?.copyWith(
          fontWeight: FontWeight.w700,
          color: foreground,
        ),
      ),
    );
  }

  String? _collectionNameFor(
    ClipProvider provider,
    ClipItem item,
  ) {
    if (item.clip.collectionId == null) return null;
    for (final collection in provider.collections) {
      if (collection.id == item.clip.collectionId) {
        return collection.name;
      }
    }
    return null;
  }

  Future<void> _refreshClipListAfterStorageChange(
    ClipProvider provider,
  ) async {
    await provider.selectCollection(provider.selectedCollectionId);
  }

  Future<bool> _applyStorageMode(
    ClipProvider provider,
    ClipItem item, {
    required String storageMode,
    String? filePath,
  }) async {
    final collectionName = _collectionNameFor(provider, item);

    await provider.updateClip(
      clipId: item.clip.id,
      collectionName: collectionName,
      clipTitle: item.clip.title,
      filePath: filePath ?? item.clip.filePath,
      durationMs: item.clip.durationMs,
      segments: item.segments,
      tags: item.tags.map((tag) => tag.name).toList(),
      storageMode: storageMode,
    );

    await _refreshClipListAfterStorageChange(provider);
    return true;
  }

  Future<bool> _moveToLocal(
    ClipProvider provider,
    ClipItem item,
  ) async {
    final success = await provider.moveClipToLocal(item.clip.id);
    if (!success) return false;

    await _refreshClipListAfterStorageChange(provider);
    return true;
  }

  Future<bool> _moveToServer(
    ClipProvider provider,
    ClipItem item,
  ) async {
    final success = await provider.moveClipToServer(item.clip.id);
    if (!success) return false;

    await _refreshClipListAfterStorageChange(provider);
    return true;
  }

  Future<bool> _pickCloudSourceAndApply(
    ClipProvider provider,
    ClipItem item,
  ) async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.video,
      allowMultiple: false,
    );

    if (result == null || result.files.isEmpty) return false;
    final picked = result.files.first;
    final pickedPath = picked.path;
    if (pickedPath == null || pickedPath.isEmpty) return false;

    return _applyStorageMode(
      provider,
      item,
      storageMode: 'cloud',
      filePath: pickedPath,
    );
  }

  void _showStorageModeSheet(
    BuildContext context,
    ClipItem item, {
    required VoidCallback onApplied,
  }) {
    var selectedMode = item.clip.storageMode;
    final provider = context.read<ClipProvider>();

    showModalBottomSheet<void>(
      context: context,
      backgroundColor: Colors.transparent,
      barrierColor: Colors.black.withValues(alpha: 0.4),
      builder: (sheetContext) {
        return StatefulBuilder(
          builder: (sheetContext, setSheetState) {
            final theme = Theme.of(sheetContext);
            final cs = theme.colorScheme;

            Widget buildOption({
              required IconData icon,
              required String title,
              required String subtitle,
              required Color iconColor,
              required String value,
            }) {
              final isSelected = selectedMode == value;
              return Material(
                color: cs.surface,
                borderRadius: BorderRadius.circular(18),
                child: InkWell(
                  borderRadius: BorderRadius.circular(18),
                  onTap: () => setSheetState(() => selectedMode = value),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 14),
                    child: Row(
                      children: [
                        Checkbox(
                          value: isSelected,
                          onChanged: (_) =>
                              setSheetState(() => selectedMode = value),
                          activeColor: iconColor,
                        ),
                        Container(
                          width: 42,
                          height: 42,
                          decoration: BoxDecoration(
                            color: iconColor.withValues(alpha: 0.12),
                            borderRadius: BorderRadius.circular(14),
                          ),
                          child: Icon(icon, color: iconColor),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                title,
                                style: theme.textTheme.titleSmall?.copyWith(
                                  fontWeight: FontWeight.w800,
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                subtitle,
                                style: theme.textTheme.bodySmall?.copyWith(
                                  color: cs.onSurfaceVariant,
                                ),
                              ),
                            ],
                          ),
                        ),
                        Icon(
                          isSelected
                              ? Icons.check_circle_rounded
                              : Icons.chevron_right_rounded,
                          color: isSelected
                              ? iconColor
                              : cs.onSurfaceVariant.withValues(alpha: 0.6),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            }

            return Container(
              padding: const EdgeInsets.fromLTRB(20, 20, 20, 24),
              decoration: BoxDecoration(
                color: cs.surface,
                borderRadius:
                    const BorderRadius.vertical(top: Radius.circular(24)),
              ),
              child: SafeArea(
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Text(
                        '저장 위치 바꾸기',
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        '원하는 위치를 고르면, 기기 안에 남겨둘지도 함께 정할 수 있어요.',
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: cs.onSurfaceVariant,
                        ),
                      ),
                      const SizedBox(height: 16),
                      buildOption(
                        icon: Icons.phone_android_rounded,
                        title: '로컬',
                        subtitle: '이 기기 안에 저장해 인터넷이 없어도 바로 봅니다.',
                        iconColor: AppColors.info,
                        value: 'local',
                      ),
                      const SizedBox(height: 10),
                      buildOption(
                        icon: Icons.cloud_queue_rounded,
                        title: '서버',
                        subtitle: '서버에 저장하고, 기기에도 남겨 더 빨리 열 수 있습니다.',
                        iconColor: AppColors.secondary,
                        value: 'server',
                      ),
                      const SizedBox(height: 10),
                      buildOption(
                        icon: Icons.cloud_upload_rounded,
                        title: '클라우드',
                        subtitle: '클라우드에 저장하고, 자주 보는 파일은 기기에도 둘 수 있습니다.',
                        iconColor: AppColors.warning,
                        value: 'cloud',
                      ),
                      const SizedBox(height: 18),
                      FilledButton(
                        onPressed: selectedMode.isEmpty
                            ? null
                            : () async {
                                Navigator.pop(sheetContext);
                                final success = switch (selectedMode) {
                                  'local' => await _moveToLocal(
                                      provider,
                                      item,
                                    ),
                                  'server' => await _moveToServer(
                                      provider,
                                      item,
                                    ),
                                  'cloud' => await _pickCloudSourceAndApply(
                                      provider,
                                      item,
                                    ),
                                  _ => false,
                                };

                                if (success) {
                                  onApplied();
                                  if (selectedMode == 'server') {
                                    showToast('서버에 저장했어요.');
                                  } else if (selectedMode == 'local') {
                                    showToast('로컬로 옮겼어요.');
                                  }
                                } else if (selectedMode == 'server') {
                                  showToast('서버 저장에 실패했어요.');
                                } else if (selectedMode == 'local') {
                                  showToast('로컬 전환에 실패했어요.');
                                }
                              },
                        child: const Text('적용'),
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

  Widget _buildSwipeAction({
    required Color color,
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return Expanded(
      child: Material(
        child: InkWell(
          onTap: onTap,
          child: Container(
            height: double.infinity,
            color: color,
            alignment: Alignment.center,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(icon, color: Colors.white, size: 20),
                const SizedBox(height: 2),
                Text(
                  label,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 9,
                    fontWeight: FontWeight.w700,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _confirmDeleteClip(BuildContext context, ClipItem item) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text(
          '삭제할까요?',
          style: Theme.of(dialogContext)
              .textTheme
              .titleMedium
              ?.copyWith(fontWeight: FontWeight.bold),
        ),
        content: Text(
          item.clip.title,
          style: Theme.of(dialogContext).textTheme.bodyMedium?.copyWith(
                color: Colors.black87,
              ),
        ),
        actionsPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            style: TextButton.styleFrom(
              foregroundColor: Colors.grey[700],
              textStyle: const TextStyle(fontWeight: FontWeight.w600),
            ),
            child: const Text('취소'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(dialogContext, true),
            style: FilledButton.styleFrom(
              backgroundColor: Colors.redAccent,
              padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.lg, vertical: AppSpacing.md),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: const Text('삭제'),
          ),
        ],
      ),
    );

    if (ok == true) {
      if (!context.mounted) return;
      final ok2 =
          await context.read<ClipProvider>().deleteClipById(item.clip.id);

      if (!context.mounted) return;
      // ✅ showToast 사용
      showToast(ok2 ? '삭제되었습니다' : '삭제에 실패했습니다');
    }
  }

  @override
  Widget build(BuildContext context) {
    // Remove unused cs
    final tick =
        context.select<TagFilterProvider, int>((p) => p.resultsVersion);
    final loading = context.select<TagFilterProvider, bool>((p) => p.isLoading);

    return CustomScrollView(
      slivers: [
        // ✅ 헤더는 고정 (애니메이션 X)
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(12, 0, 12, 8),
            child: Text(
              '클립',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w800,
                  ),
            ),
          ),
        ),

        // ✅ 로딩 시엔 스켈레톤만
        if (loading)
          const _SkeletonSliver()
        else if (items.isEmpty)
          const SliverFillRemaining(
            child: Center(child: Text('아직 등록된 클립이 없어요.')),
          )
        else
          // ✅ 데이터일 때만 리스트 렌더
          SliverList.separated(
            itemCount: items.length,
            itemBuilder: (ctx, i) {
              final item = items[i];
              final clip = item.clip;
              final dur = _fmtMs(clip.durationMs);
              final swipeKey = GlobalKey<SwipeActionTileState>();

              ImageProvider? thumbProvider;
              if (item.thumbnail != null) {
                thumbProvider = MemoryImage(item.thumbnail!);
              } else if (resolveThumb != null) {
                thumbProvider = resolveThumb!(item);
              }
              final storageChip = _buildStorageChip(ctx, clip.storageMode);

              // ⬇️ 여기서 아이템만 애니메이션 적용
              return _FadeSlideIn(
                index: i,
                version: tick, // 태그 결과 바뀔 때만 애니 시작
                child: SwipeActionTile(
                  key: swipeKey,
                  actionWidth: 300,
                  actions: [
                    _buildSwipeAction(
                      color: AppColors.info,
                      icon: Icons.edit_rounded,
                      label: '편집',
                      onTap: () async {
                        final clipProvider = context.read<ClipProvider>();
                        final currentCollection =
                            clipProvider.selectedCollectionId == null
                                ? null
                                : clipProvider.collections
                                    .cast<dynamic>()
                                    .firstWhere(
                                      (c) =>
                                          (c.id as int) ==
                                          clipProvider.selectedCollectionId,
                                      orElse: () => null,
                                    );
                        final collectionName =
                            currentCollection?.name as String?;
                        final ok = await context.push<bool>(
                          '${AppRoutes.clipsPath}/${AppRoutes.clipsEditPath}?clipId=${clip.id}'
                          '${collectionName != null ? '&collectionName=${Uri.encodeComponent(collectionName)}' : ''}',
                        );
                        if (ok == true && context.mounted) {
                          clipProvider.backToCollections();
                          clipProvider.loadCollections();
                        }
                      },
                    ),
                    _buildSwipeAction(
                      color: AppColors.warning,
                      icon: Icons.swap_horiz_rounded,
                      label: '전환',
                      onTap: () => _showStorageModeSheet(
                        context,
                        item,
                        onApplied: () => swipeKey.currentState?.close(),
                      ),
                    ),
                    _buildSwipeAction(
                      color: AppColors.danger,
                      icon: Icons.delete_rounded,
                      label: '삭제',
                      onTap: () => _confirmDeleteClip(context, item),
                    ),
                  ],
                  child: InkWell(
                    onTap: () => onOpen(item),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 8),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          EpisodeThumbnail(
                              imageProvider: thumbProvider, duration: dur),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  clip.title,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: Theme.of(ctx)
                                      .textTheme
                                      .titleMedium
                                      ?.copyWith(fontWeight: FontWeight.w800),
                                ),
                                const SizedBox(height: 6),
                                Wrap(
                                  spacing: 6,
                                  runSpacing: 4,
                                  children: [
                                    if (storageChip != null) storageChip,
                                    for (final t in item.tags.take(4))
                                      MiniChip(label: t.name),
                                  ],
                                ),
                              ],
                            ),
                          ),
                          Icon(
                            Icons.chevron_right_rounded,
                            color: Theme.of(ctx)
                                .colorScheme
                                .onSurface
                                .withValues(alpha: 0.4),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              );
            },
            separatorBuilder: (ctx, __) => Divider(
              height: 1,
              color: Theme.of(ctx)
                  .colorScheme
                  .outlineVariant
                  .withValues(alpha: 0.6),
            ),
          ),

        const SliverToBoxAdapter(child: SizedBox(height: 24)),
      ],
    );
  }
}

class _FadeSlideIn extends StatelessWidget {
  const _FadeSlideIn({
    required this.child,
    required this.index,
    required this.version, // 태그 결과 버전 (변경될 때만 애니 트리거)
  });

  final Widget child;
  final int index;
  final int version;

  @override
  Widget build(BuildContext context) {
    // version 이 바뀌면 Key가 달라져서 새 애니메이션 시작
    return TweenAnimationBuilder<double>(
      key: ValueKey('ani_${version}_$index'),
      tween: Tween(begin: 0, end: 1),
      duration: const Duration(milliseconds: 340),
      curve: Curves.easeOutCubic,
      builder: (_, v, __) => Opacity(
        opacity: v,
        child: Transform.translate(
          offset: Offset(0, (1 - v) * 10),
          child: child,
        ),
      ),
    );
  }
}

class _LineSkeleton extends StatelessWidget {
  const _LineSkeleton();
  @override
  Widget build(BuildContext context) {
    final c = Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.08);
    return Container(
      height: 16,
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: c,
        borderRadius: BorderRadius.circular(AppRadius.sm),
      ),
    );
  }
}

class _SkeletonSliver extends StatelessWidget {
  const _SkeletonSliver();

  @override
  Widget build(BuildContext context) {
    return SliverList.builder(
      itemCount: 8,
      itemBuilder: (_, __) => const _LineSkeleton(),
    );
  }
}
