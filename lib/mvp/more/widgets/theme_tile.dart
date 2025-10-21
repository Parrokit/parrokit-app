import 'package:flutter/material.dart';
import 'leading_icon.dart';

class ThemeTile extends StatelessWidget {
  const ThemeTile({
    super.key,
    required this.value,
    required this.onChanged,
  });

  final ThemeMode value;
  final ValueChanged<ThemeMode> onChanged;

  @override
  Widget build(BuildContext context) {
    final tt = Theme.of(context).textTheme;
    final cs = Theme.of(context).colorScheme;

    Widget chip(ThemeMode m, String label, Color color) {
      final selected = value == m;
      return ChoiceChip(
        label: Text(
          label,
          style: TextStyle(
            fontWeight: FontWeight.w600,
            color: selected ? cs.onPrimary : cs.onSurfaceVariant,
          ),
        ),
        selected: selected,
        onSelected: (_) => onChanged(m),
        showCheckmark: false,
        selectedColor: color,
        backgroundColor: cs.surfaceVariant,
        side: BorderSide(color: selected ? color : cs.outlineVariant),
      );
    }

    return Row(
      children: [
        const LeadingIcon(icon: Icons.dark_mode_outlined),
        const SizedBox(width: 10),
        Expanded(
          child: Text(
            '테마',
            style: tt.bodyLarge?.copyWith(fontWeight: FontWeight.w700),
          ),
        ),
        const SizedBox(width: 12),
        Wrap(
          spacing: 8,
          children: [
            chip(ThemeMode.system, '시스템', cs.primary),
            chip(ThemeMode.light, '라이트', cs.primary),
            chip(ThemeMode.dark, '다크', cs.primary),
          ],
        ),
      ],
    );
  }
}
