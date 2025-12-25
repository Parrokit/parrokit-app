import 'package:flutter/material.dart';

/// A simple rounded-corner network image used for posters.
class Poster extends StatelessWidget {
  const Poster({required this.url});

  final String url;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(8),
      child: Image.network(
        url,
        width: 56,
        height: 56,
        fit: BoxFit.cover,
        errorBuilder: (_, __, ___) => Container(
          width: 56,
          height: 56,
          color: Theme.of(context).colorScheme.surfaceVariant,
          child: const Icon(Icons.image_not_supported),
        ),
      ),
    );
  }
}

