import 'package:flutter/material.dart';

class MiniChip extends StatelessWidget {
  const MiniChip({super.key, required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
      decoration: BoxDecoration(
        color: cs.secondaryContainer.withValues(alpha: 0.5),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(
        '#$label',
        style: TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w600,
          color: cs.onSecondaryContainer.withValues(alpha: 0.8),
        ),
      ),
    );
  }
}
