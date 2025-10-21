import 'package:flutter/material.dart';
import 'leading_icon.dart';

class SwitchTile extends StatelessWidget {
  const SwitchTile({
    required this.icon,
    required this.title,
    required this.value,
    required this.onChanged,
    this.subtitle,
  });

  final IconData icon;
  final String title;
  final String? subtitle;
  final bool value;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;

    return Row(
      children: [
        LeadingIcon(icon: icon),
        const SizedBox(width: 10),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title,
                  style: tt.bodyLarge?.copyWith(fontWeight: FontWeight.w700)),
              if (subtitle != null)
                Padding(
                  padding: const EdgeInsets.only(top: 2),
                  child: Text(subtitle!,
                      style: tt.bodySmall
                          ?.copyWith(color: cs.onSurface.withOpacity(0.6))),
                ),
            ],
          ),
        ),
        Switch(value: value, onChanged: onChanged),
      ],
    );
  }
}
