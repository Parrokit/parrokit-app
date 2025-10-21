import 'package:flutter/material.dart';
import 'package:parrokit/data/local/pa_database.dart';

class SegmentList extends StatelessWidget {
  const SegmentList({
    required this.segments,
    required this.currentIndex,
    required this.onTapItem,
  });

  final List<Segment> segments;
  final int currentIndex;
  final ValueChanged<int> onTapItem;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    String fmtMs(int ms) {
      final d = Duration(milliseconds: ms);
      final totalMs = d.inMilliseconds;
      final mm = ((totalMs ~/ 1000) ~/ 60).toString().padLeft(2, '0');
      final ss = ((totalMs ~/ 1000) % 60).toString().padLeft(2, '0');
      final mmm = (totalMs % 1000).toString().padLeft(3, '0');
      return '$mm:$ss.$mmm';
    }

    return ListView.separated(
      padding: const EdgeInsets.fromLTRB(12, 0, 12, 12),
      itemCount: segments.length,
      separatorBuilder: (_, __) =>
          Divider(height: 1, color: cs.outlineVariant.withOpacity(0.6)),
      itemBuilder: (ctx, i) {
        final seg = segments[i];
        final active = i == currentIndex;

        final chip = Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(
            color: active
                ? cs.primary.withOpacity(0.12)
                : cs.surfaceVariant.withOpacity(0.4),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Text('#${i + 1}  ${fmtMs(seg.startMs)} ~ ${fmtMs(seg.endMs)}',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w700,
                color: active ? cs.primary : cs.onSurface.withOpacity(0.7),
              )),
        );

        return ListTile(
          dense: true,
          onTap: () => onTapItem(i),
          title: Row(children: [chip]),
          subtitle: Padding(
            padding: const EdgeInsets.only(top: 6),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(seg.original,
                    style: const TextStyle(fontWeight: FontWeight.w700)),
                const SizedBox(height: 2),
                Text(seg.pron,
                    style: TextStyle(color: cs.onSurface.withOpacity(0.7))),
                const SizedBox(height: 2),
                Text(seg.trans),
              ],
            ),
          ),
          trailing: active
              ? Icon(Icons.play_arrow_rounded, color: cs.primary)
              : const Icon(Icons.play_arrow_rounded, color: Colors.transparent),
        );
      },
    );
  }
}
