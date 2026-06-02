import 'package:flutter/material.dart';

class ContentStudioAppBar extends StatelessWidget
    implements PreferredSizeWidget {
  const ContentStudioAppBar({
    super.key,
    required this.title,
    required this.coins,
    required this.onBack,
    this.backgroundColor,
  });

  final String title;
  final int coins;
  final VoidCallback onBack;
  final Color? backgroundColor;

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final bg = backgroundColor ?? theme.colorScheme.surface;
    final fg = theme.colorScheme.onSurface;

    return AppBar(
      title: Text(title),
      backgroundColor: bg,
      foregroundColor: fg,
      surfaceTintColor: Colors.transparent,
      elevation: 0,
      scrolledUnderElevation: 0,
      leading: IconButton(
        icon: const Icon(Icons.arrow_back),
        onPressed: onBack,
      ),
      actions: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const SizedBox(width: 10),
              const Icon(
                Icons.monetization_on_rounded,
                color: Colors.amber,
                size: 20,
              ),
              const SizedBox(width: 5),
              Text(
                '$coins',
                style: theme.textTheme.bodyMedium,
              ),
              const SizedBox(width: 10),
            ],
          ),
        ),
      ],
    );
  }
}
