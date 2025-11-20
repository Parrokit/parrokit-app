// lib/mvp/recent/recent_screen.dart
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:parrokit/provider/dashboard_ui_provider.dart';
import 'package:parrokit/mvp/player/clip_player_screen.dart';

class RecentScreen extends StatefulWidget {
  const RecentScreen({super.key});

  @override
  State<RecentScreen> createState() => _RecentScreenState();
}

class _RecentScreenState extends State<RecentScreen> {
  late Future<List<(int, Uint8List?, String?, String?)>> _future;

  Future<List<(int, Uint8List?, String?, String?)>> _load({bool refreshThumb = false}) {
    final dash = context.read<DashboardUiProvider>();
    return dash.fetchRecentClips(limit: 100, refreshThumb: refreshThumb);
  }

  @override
  void initState() {
    super.initState();
    _future = _load();
  }

  Future<void> _onRefresh() async {
    final f = _load();        // 캐시 사용
    setState(() {             // ✅ 리턴값 없음 (void)
      _future = f;
    });
    await f;                  // RefreshIndicator 종료 타이밍
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text('최근 본 클립'),
      ),
      body: RefreshIndicator(
        onRefresh: _onRefresh,
        child: FutureBuilder<List<(int, Uint8List?, String?, String?)>>(
          future: _future,
          builder: (context, snap) {
            if (snap.connectionState == ConnectionState.waiting) {
              return const _RecentListSkeleton();
            }
            if (snap.hasError) {
              return Center(
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: Text(
                    '최근 목록을 불러오는 중 오류가 발생했어요.\n${snap.error}',
                    textAlign: TextAlign.center,
                  ),
                ),
              );
            }
            final items = snap.data ?? const [];
            if (items.isEmpty) {
              return const _EmptyRecent();
            }

            return ListView.separated(
              padding: const EdgeInsets.fromLTRB(12, 8, 12, 16),
              itemBuilder: (context, index) {
                final (clipId, thumb, clipTitle, titleName) = items[index];
                return _RecentRow(
                  clipId: clipId,
                  thumb: thumb,
                  clipTitle: clipTitle ?? '제목 없음',
                  titleName: titleName,
                  onTap: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (_) => ClipPlayerScreen(
                          clipId: clipId,
                          initialIndex: 0,
                          loopSegment: true,
                          showSubtitles: true,
                        ),
                      ),
                    );
                  },
                );
              },
              separatorBuilder: (_, __) => Divider(
                height: 8,
                thickness: 0.5,
                color: cs.outlineVariant.withOpacity(.6),
              ),
              itemCount: items.length,
            );
          },
        ),
      ),
    );
  }
}

class _RecentRow extends StatelessWidget {
  const _RecentRow({
    required this.clipId,
    required this.thumb,
    required this.clipTitle,
    required this.titleName,
    required this.onTap,
  });

  final int clipId;
  final Uint8List? thumb;
  final String clipTitle;
  final String? titleName;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    final tt = theme.textTheme;
    final isDark = theme.brightness == Brightness.dark;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Ink(
        decoration: BoxDecoration(
          color: cs.surface, // 테마 표면색
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: cs.outlineVariant.withOpacity(isDark ? .5 : .7)),
        ),
        child: Padding(
          padding: const EdgeInsets.all(10),
          child: Row(
            children: [
              // 썸네일 (16:9, 고정 폭)
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: SizedBox(
                  width: 128,
                  height: 72, // 16:9 비율
                  child: thumb != null
                      ? Image.memory(thumb!, fit: BoxFit.cover)
                      : Container(
                    color: isDark ? const Color(0xFF1B1F24) : cs.surfaceVariant,
                    child: const _ThumbPlaceholder(iconSize: 28),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              // 텍스트 정보
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // 클립 제목
                    Text(
                      clipTitle,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: tt.titleMedium?.copyWith(fontWeight: FontWeight.w800),
                    ),
                    const SizedBox(height: 4),
                    // 작품명
                    Text(
                      titleName ?? '',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: tt.bodySmall?.copyWith(
                        color: cs.onSurface.withOpacity(0.6),
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              // 액션
              TextButton.icon(
                onPressed: onTap,
                icon: Icon(Icons.play_circle_fill, color: cs.primary),
                label: Text(
                  '이어보기',
                  style: tt.labelSmall?.copyWith(
                    color: cs.primary,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                style: TextButton.styleFrom(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  foregroundColor: cs.primary,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ThumbPlaceholder extends StatelessWidget {
  const _ThumbPlaceholder({this.iconSize = 32});
  final double iconSize;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Center(
      child: Icon(
        Icons.video_library_outlined,
        size: iconSize,
        color: isDark ? const Color(0xFF8A96A8) : cs.outline,
      ),
    );
  }
}

class _RecentListSkeleton extends StatelessWidget {
  const _RecentListSkeleton();

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final base = cs.surfaceVariant.withOpacity(.65);
    final hilite = cs.surface;

    return ListView.separated(
      padding: const EdgeInsets.fromLTRB(12, 8, 12, 16),
      itemBuilder: (_, __) => _ShimmerTile(base: base, hilite: hilite),
      separatorBuilder: (_, __) => Divider(
        height: 8,
        thickness: 0.5,
        color: cs.outlineVariant.withOpacity(.6),
      ),
      itemCount: 8,
    );
  }
}

class _ShimmerTile extends StatefulWidget {
  const _ShimmerTile({required this.base, required this.hilite});
  final Color base;
  final Color hilite;

  @override
  State<_ShimmerTile> createState() => _ShimmerTileState();
}

class _ShimmerTileState extends State<_ShimmerTile> with SingleTickerProviderStateMixin {
  late final AnimationController _ac = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 1100),
  )..repeat(reverse: true);

  late final Animation<double> _t = Tween(begin: 0.0, end: 1.0).animate(_ac);

  @override
  void dispose() {
    _ac.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final border = isDark ? Colors.white10 : Colors.black12;

    return AnimatedBuilder(
      animation: _t,
      builder: (_, __) {
        return Container(
          height: 92,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: border),
            gradient: LinearGradient(
              begin: Alignment.centerLeft,
              end: Alignment.centerRight,
              stops: const [0.1, 0.3, 0.5, 0.7, 0.9],
              colors: [
                widget.base,
                Color.lerp(widget.base, widget.hilite, _t.value * .6 + .2)!,
                widget.base,
                Color.lerp(widget.base, widget.hilite, _t.value * .6 + .2)!,
                widget.base,
              ],
            ),
          ),
        );
      },
    );
  }
}

class _EmptyRecent extends StatelessWidget {
  const _EmptyRecent();

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.history_toggle_off, size: 48, color: cs.outline),
            const SizedBox(height: 10),
            Text(
              '아직 최근 본 클립이 없어요',
              style: tt.titleMedium?.copyWith(fontWeight: FontWeight.w800),
            ),
            const SizedBox(height: 6),
            Text(
              '플레이어에서 시청하면 자동으로 여기에 쌓입니다.',
              style: tt.bodyMedium?.copyWith(color: cs.onSurface.withOpacity(0.7)),
            ),
          ],
        ),
      ),
    );
  }
}