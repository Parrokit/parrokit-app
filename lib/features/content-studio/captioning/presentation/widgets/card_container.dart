import 'package:flutter/material.dart';
import 'package:parrokit/core/shared/theme/app_radius.dart';

class CardContainer extends StatelessWidget {
  const CardContainer({super.key, required this.child, this.padding});

  final Widget child;
  final EdgeInsetsGeometry? padding;

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context);
    return Container(
      padding: padding ?? const EdgeInsets.all(16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(AppRadius.md),
        border: Border.all(color: t.colorScheme.outlineVariant, width: 0.8),
      ),
      child: child,
    );
  }
}
