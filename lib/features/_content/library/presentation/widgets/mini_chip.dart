import 'package:flutter/material.dart';

class MiniChip extends StatelessWidget {
  const MiniChip({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: cs.surface,
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: cs.outlineVariant, width: 0.8),
      ),
      child: Text(label,
          style: TextStyle(
              fontSize: 11,
              color: cs.onSurface.withOpacity(0.8),
              fontWeight: FontWeight.w700)),
    );
  }
}
