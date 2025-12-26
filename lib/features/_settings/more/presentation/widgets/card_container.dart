import 'package:flutter/material.dart';
import 'package:parrokit/core/theme/app_spacing.dart';
import 'package:parrokit/core/theme/app_radius.dart';

class CardContainer extends StatelessWidget {
  const CardContainer(
      {super.key,
      required this.child,
      this.padding = const EdgeInsets.all(AppSpacing.cardPadding)});

  final Widget child;
  final EdgeInsets padding;

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context);
    return Container(
      margin: const EdgeInsets.only(bottom: AppSpacing.xs),
      padding: padding,
      decoration: BoxDecoration(
        color: t.colorScheme.surface,
        borderRadius: BorderRadius.circular(AppRadius.lg),
        border: Border.all(color: t.colorScheme.outlineVariant, width: 0.8),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.02),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: child,
    );
  }
}
