import 'package:flutter/material.dart';
import 'package:parrokit/data/local/app_database.dart';

/// [역할]
/// 에피소드 목록을 간단히 보여주는 리스트 위젯.
///
/// 폴더 뷰에서 에피소드 레벨로 진입했을 때 사용됩니다.
class EpisodeList extends StatelessWidget {
  const EpisodeList({
    super.key,
    required this.episodes,
    required this.onOpen,
  });

  final List<Episode> episodes;
  final ValueChanged<Episode> onOpen;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return CustomScrollView(
      slivers: [
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(12, 0, 12, 8),
            child: Text('에피소드',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w800,
                    )),
          ),
        ),
        SliverList.separated(
          itemBuilder: (ctx, i) {
            final ep = episodes[i];
            final epNo = ep.number?.toString().padLeft(2, '0');
            final epTitle = ep.title ?? 'Episode';
            return ListTile(
              onTap: () => onOpen(ep),
              leading: CircleAvatar(
                radius: 16,
                backgroundColor: cs.surfaceContainerHighest,
                child: Text(epNo ?? '•',
                    style: Theme.of(context).textTheme.labelLarge?.copyWith(
                          fontWeight: FontWeight.w800,
                          color: cs.onSurface,
                        )),
              ),
              title: Text(epTitle,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                        fontWeight: FontWeight.w800,
                      )),
              trailing: Icon(Icons.chevron_right_rounded,
                  color: cs.onSurface.withValues(alpha: 0.4)),
            );
          },
          separatorBuilder: (_, __) => Divider(
              height: 1, color: cs.outlineVariant.withValues(alpha: 0.6)),
          itemCount: episodes.length,
        ),
        const SliverToBoxAdapter(child: SizedBox(height: 24)),
      ],
    );
  }
}
