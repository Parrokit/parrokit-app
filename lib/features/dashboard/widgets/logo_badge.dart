import 'package:flutter/material.dart';

class LogoBadge extends StatelessWidget {
  const LogoBadge({super.key});

  @override
  Widget build(BuildContext context) {
    return ShaderMask(
      shaderCallback: (bounds) => const LinearGradient(
        colors: [Color(0xFF3B82F6), Color(0xFF06B6D4)], // 파랑-민트 그라디언트
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      ).createShader(bounds),
      child: const Icon(
        Icons.auto_awesome,
        size: 36,
        color: Colors.white,
      ),
    );
  }
}