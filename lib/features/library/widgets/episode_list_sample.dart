import 'package:flutter/material.dart';
import 'package:parrokit/data/local/pa_database.dart';

class EpisodeListSimple extends StatelessWidget {
  const EpisodeListSimple({
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
                backgroundColor: cs.surfaceVariant,
                child: Text(epNo ?? '•',
                    style: const TextStyle(fontWeight: FontWeight.w800)),
              ),
              title: Text(epTitle,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(fontWeight: FontWeight.w800)),
              trailing: Icon(Icons.chevron_right_rounded,
                  color: cs.onSurface.withOpacity(0.4)),
            );
          },
          separatorBuilder: (_, __) =>
              Divider(height: 1, color: cs.outlineVariant.withOpacity(0.6)),
          itemCount: episodes.length,
        ),
        const SliverToBoxAdapter(child: SizedBox(height: 24)),
      ],
    );
  }
}
