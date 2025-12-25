import 'package:flutter/material.dart';

class SpeedMenu extends StatelessWidget {
  const SpeedMenu(
      {required this.value, required this.onSelected, this.isLight = true});

  final double value;
  final ValueChanged<double> onSelected;
  final bool isLight;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    const speeds = [0.75, 1.0, 1.25, 1.5, 2.0];

    return PopupMenuButton<double>(
      tooltip: '재생 속도',
      onSelected: onSelected,
      itemBuilder: (ctx) => [
        for (final s in speeds)
          PopupMenuItem<double>(
            value: s,
            child: Text('${s.toStringAsFixed(2)}x'),
          ),
      ],
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
        decoration: BoxDecoration(
          color: isLight ? cs.surface.withOpacity(0.9) : Colors.white12,
          borderRadius: BorderRadius.circular(999),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.speed_rounded, size: 18),
            const SizedBox(width: 6),
            Text('${value.toStringAsFixed(2)}x',
                style: TextStyle(
                    fontWeight: FontWeight.w700,
                    color: isLight ? cs.onSurface : Colors.white)),
            const SizedBox(width: 4),
            const Icon(Icons.arrow_drop_down_rounded),
          ],
        ),
      ),
    );
  }
}
