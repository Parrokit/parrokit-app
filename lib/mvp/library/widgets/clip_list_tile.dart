import 'package:flutter/material.dart';
import 'clip_meta.dart';
import 'mini_chip.dart';

class ClipListTile extends StatelessWidget {
  const ClipListTile({required this.meta, required this.onTap});

  final ClipMeta meta;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    String fmt(int ms) {
      final m = (ms ~/ 1000) ~/ 60;
      final s = (ms ~/ 1000) % 60;
      return '${m.toString().padLeft(2, '0')}:${s.toString().padLeft(2, '0')}';
    }

    return ListTile(
      onTap: onTap,
      leading: Container(
        width: 56,
        height: 34,
        decoration: BoxDecoration(
          color: cs.surfaceVariant.withOpacity(0.5),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: cs.outlineVariant, width: 0.8),
        ),
        child: const Icon(Icons.play_arrow_rounded, size: 20),
      ),
      title:
      Text(meta.title, style: const TextStyle(fontWeight: FontWeight.w800)),
      subtitle: Padding(
        padding: const EdgeInsets.only(top: 4),
        child: Wrap(
          spacing: 6,
          runSpacing: 4,
          children: [
            MiniChip(label: fmt(meta.durationMs)),
            for (final t in meta.tags.take(2)) MiniChip(label: t),
          ],
        ),
      ),
      trailing: Icon(Icons.chevron_right_rounded,
          color: cs.onSurface.withOpacity(0.4)),
    );
  }
}
