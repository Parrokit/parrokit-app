import 'package:flutter/material.dart';
import 'leading_icon.dart';

class DropdownTile<T> extends StatelessWidget {
  const DropdownTile({
    required this.icon,
    required this.title,
    required this.value,
    required this.items,
    required this.onChanged,
    this.display,
  });

  final IconData icon;
  final String title;
  final T value;
  final List<T> items;
  final ValueChanged<T> onChanged;
  final String Function(T value)? display;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;

    return Row(
      children: [
        LeadingIcon(icon: icon),
        const SizedBox(width: 10),
        Expanded(
          child: Text(title,
              style: tt.bodyLarge?.copyWith(fontWeight: FontWeight.w700)),
        ),
        const SizedBox(width: 12),
        DropdownButton<T>(
          value: value,
          underline: const SizedBox.shrink(),
          style: tt.bodyMedium?.copyWith(color: cs.onSurface),
          items: items
              .map((e) => DropdownMenuItem<T>(
            value: e,
            child: Text(display?.call(e) ?? e.toString()),
          ))
              .toList(),
          onChanged: (v) {
            if (v != null) onChanged(v);
          },
        ),
      ],
    );
  }
}
