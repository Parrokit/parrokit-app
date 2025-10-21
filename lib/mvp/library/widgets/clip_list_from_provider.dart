import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:parrokit/data/models/clip_item.dart';
import 'package:parrokit/pa_router.dart';
import 'package:parrokit/provider/media_provider.dart';
import 'package:parrokit/provider/tag_filter_provider.dart';
import 'package:parrokit/utils/show_toast.dart';
import 'package:provider/provider.dart';
import 'episode_thumb_nail.dart';
import 'swipe_action_tile.dart';
import 'mini_chip.dart';

class ClipListFromProvider extends StatelessWidget {
  const ClipListFromProvider({
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

  Future<void> _confirmDeleteClip(BuildContext context, ClipItem item) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text(
          '삭제할까요?',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        content: Text(
          item.clip.title ?? '클립',
          style: const TextStyle(color: Colors.black87, fontSize: 15),
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
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
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
      final ok2 = await context.read<MediaProvider>().deleteClipById(item.clip.id);

      // ✅ showToast 사용
      showToast(
        context,
        ok2 ? '삭제되었습니다' : '삭제에 실패했습니다',
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tick = context.select<TagFilterProvider, int>((p) => p.resultsVersion);
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
        if (loading) _skeletonSliver() else
        // ✅ 데이터일 때만 리스트 렌더
          SliverList.separated(
            itemCount: items.length,
            itemBuilder: (ctx, i) {
              final item = items[i];
              final clip = item.clip;
              final dur = _fmtMs(clip.durationMs);

              ImageProvider? thumbProvider;
              if (item.thumbnail != null) {
                thumbProvider = MemoryImage(item.thumbnail!);
              } else if (resolveThumb != null) {
                thumbProvider = resolveThumb!(item);
              }

              // ⬇️ 여기서 아이템만 애니메이션 적용
              return _FadeSlideIn(
                index: i,
                version: tick, // 태그 결과 바뀔 때만 애니 시작
                child: SwipeActionTile(
                  actionWidth: 160,
                  actions: [
                    Expanded(
                      child: Material(
                        child: InkWell(
                          onTap: () async {
                            final ok = await context.push<bool>(
                              '${PaRoutes.clipsPath}/${PaRoutes.clipsEditPath}?clipId=${clip.id}',
                            );
                            if (ok == true) {
                              final media = context.read<MediaProvider>();
                              media.backToTitles();
                              media.loadTitles();
                            }
                          },
                          child: Container(
                            height: double.infinity,
                            color: const Color(0xFF1E66F5),
                            alignment: Alignment.center,
                            child: const Icon(Icons.edit_rounded,
                                color: Colors.white, size: 22),
                          ),
                        ),
                      ),
                    ),
                    Expanded(
                      child: Material(
                        child: InkWell(
                          onTap: () => _confirmDeleteClip(context, item),
                          child: Container(
                            height: double.infinity,
                            color: const Color(0xFFE53935),
                            alignment: Alignment.center,
                            child: const Icon(Icons.delete_rounded,
                                color: Colors.white, size: 22),
                          ),
                        ),
                      ),
                    ),
                  ],
                  child: InkWell(
                    onTap: () => onOpen(item),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          EpisodeThumbnail(imageProvider: thumbProvider, duration: dur),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  clip.title ?? 'Clip',
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: const TextStyle(
                                      fontWeight: FontWeight.w800, fontSize: 16),
                                ),
                                const SizedBox(height: 6),
                                Wrap(
                                  spacing: 6,
                                  runSpacing: 4,
                                  children: [
                                    for (final t in item.tags.take(4))
                                      MiniChip(label: t.name),
                                  ],
                                ),
                              ],
                            ),
                          ),
                          Icon(
                            Icons.chevron_right_rounded,
                            color: Theme.of(ctx).colorScheme.onSurface.withOpacity(0.4),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              );
            },
            separatorBuilder: (_, __) => Divider(
              height: 1,
              color: Theme.of(_).colorScheme.outlineVariant.withOpacity(0.6),
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
    this.baseDelayMs = 60,
    this.stepMs = 28,
  });

  final Widget child;
  final int index;
  final int version;
  final int baseDelayMs;
  final int stepMs;

  @override
  Widget build(BuildContext context) {
    // version 이 바뀌면 Key가 달라져서 새 애니메이션 시작
    return TweenAnimationBuilder<double>(
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
  const _LineSkeleton({this.h = 16});
  final double h;
  @override
  Widget build(BuildContext context) {
    final c = Theme.of(context).colorScheme.onSurface.withOpacity(.08);
    return Container(
      height: h,
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: c,
        borderRadius: BorderRadius.circular(8),
      ),
    );
  }
}

Widget _skeletonSliver() => SliverList.builder(
  itemCount: 8,
  itemBuilder: (_, __) => const _LineSkeleton(),
);