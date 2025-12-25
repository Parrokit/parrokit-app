import 'package:flutter/material.dart';

class DialogSheet extends StatelessWidget {
  const DialogSheet({
    required this.title,
    required this.body,
    required this.primaryText,
    required this.onPrimary,
    this.primaryIsDanger = false,
    this.secondaryText,
    this.onSecondary,
  });

  final String title;
  final String body;
  final String primaryText;
  final VoidCallback onPrimary;
  final bool primaryIsDanger;
  final String? secondaryText;
  final VoidCallback? onSecondary;

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context);
    final cs = t.colorScheme;

    return AlertDialog(
      backgroundColor: cs.surface,
      surfaceTintColor: Colors.transparent,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      title: Text(title,
          style:
              t.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w800)),
      content: Text(body,
          style: t.textTheme.bodyMedium
              ?.copyWith(color: cs.onSurface.withOpacity(0.8))),
      actions: [
        if (secondaryText != null)
          TextButton(
            onPressed: onSecondary,
            child: Text(secondaryText!),
          ),
        FilledButton.tonal(
          style: ButtonStyle(
            backgroundColor: WidgetStatePropertyAll(
              primaryIsDanger
                  ? Colors.red.withOpacity(0.12)
                  : cs.primaryContainer,
            ),
            foregroundColor: WidgetStatePropertyAll(
              primaryIsDanger ? Colors.red : cs.onPrimaryContainer,
            ),
          ),
          onPressed: onPrimary,
          child: Text(primaryText),
        ),
      ],
    );
  }
}
