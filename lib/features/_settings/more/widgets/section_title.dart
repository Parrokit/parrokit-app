import 'package:flutter/material.dart';

class SectionTitle extends StatelessWidget {
  const SectionTitle(this.title);

  final String title;

  @override
  Widget build(BuildContext context) {
    final tt = Theme.of(context).textTheme;
    return Text(
      title,
      style: tt.titleMedium?.copyWith(fontWeight: FontWeight.w800),
    );
  }
}
