import 'package:flutter/material.dart';

class ProgressBar extends StatelessWidget {
  const ProgressBar({required this.index, required this.total, super.key});

  final int index;
  final int total;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return Row(
      children: List.generate(total, (i) {
        final active = i == index;
        return Expanded(
          child: Container(
            height: 3,
            margin: EdgeInsets.only(right: i == total - 1 ? 0 : 4),
            decoration: BoxDecoration(
              color: active
                  ? scheme.onSecondary
                  : scheme.onSecondary.withOpacity(0.3),
              borderRadius: BorderRadius.circular(2),
            ),
          ),
        );
      }),
    );
  }
}