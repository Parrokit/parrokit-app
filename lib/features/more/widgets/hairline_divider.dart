import 'package:flutter/material.dart';

class HairlineDivider extends StatelessWidget {
  const HairlineDivider();

  @override
  Widget build(BuildContext context) {
    final c = Theme.of(context).colorScheme.outlineVariant;
    return Divider(color: c, height: 1, thickness: 0.6);
  }
}
