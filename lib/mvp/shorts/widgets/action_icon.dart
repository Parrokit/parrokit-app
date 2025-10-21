import 'package:flutter/material.dart';

class ActionIcon extends StatelessWidget {
  const ActionIcon({
    required this.icon,
    required this.label,
    required this.onTap,
    this.active = false,
    super.key,
  });

  final IconData icon;
  final String label;
  final bool active;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          DecoratedBox(
            decoration: BoxDecoration(
              color: scheme.surfaceVariant.withOpacity(0.6),
              shape: BoxShape.circle,
              border: Border.all(color: scheme.outlineVariant),
            ),
            child: Padding(
              padding: const EdgeInsets.all(10),
              child: Icon(
                icon,
                size: 26,
                color: active ? scheme.primary : scheme.onSurface,
              ),
            ),
          ),
          const SizedBox(height: 6),
          Text(
            label,
            style: textTheme.bodySmall?.copyWith(
              color: active ? scheme.primary : scheme.onSurfaceVariant,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}


class AutoNextButton extends StatefulWidget {
  final bool initial;
  final ValueChanged<bool> onChanged;
  const AutoNextButton({
    super.key,
    this.initial = false,
    required this.onChanged,
  });

  @override
  State<AutoNextButton> createState() => _AutoNextButtonState();
}

class _AutoNextButtonState extends State<AutoNextButton> {
  late bool _enabled;

  @override
  void initState() {
    super.initState();
    _enabled = widget.initial;
  }

  @override
  Widget build(BuildContext context) {
    return IconButton(
      tooltip: "자동 넘겨가기",
      icon: Icon(_enabled ? Icons.playlist_play : Icons.playlist_remove),
      onPressed: () {
        setState(() => _enabled = !_enabled);
        widget.onChanged(_enabled);
      },
    );
  }
}