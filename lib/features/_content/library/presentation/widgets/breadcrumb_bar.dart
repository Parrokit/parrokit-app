import 'package:flutter/material.dart';

class BreadcrumbBar extends StatelessWidget {
  const BreadcrumbBar({required this.path, required this.onTapCrumb});

  final List<String> path;
  final ValueChanged<int> onTapCrumb;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(horizontal: 12),
      child: Row(
        children: [
          for (int i = 0; i < path.length; i++) ...[
            InkWell(
              borderRadius: BorderRadius.circular(8),
              onTap: () => onTapCrumb(i),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 8),
                child: Text(
                  path[i],
                  style: TextStyle(
                    color: i == path.length - 1
                        ? cs.primary
                        : cs.onSurface.withOpacity(0.75),
                    fontWeight: i == path.length - 1
                        ? FontWeight.w800
                        : FontWeight.w600,
                  ),
                ),
              ),
            ),
            if (i != path.length - 1)
              Icon(Icons.chevron_right_rounded,
                  size: 18, color: cs.onSurface.withOpacity(0.4)),
          ]
        ],
      ),
    );
  }
}
