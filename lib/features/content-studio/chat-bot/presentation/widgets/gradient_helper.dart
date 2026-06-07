import 'package:flutter/material.dart';

LinearGradient getGradientForMode(String mode) {
  switch (mode) {
    case 'tts':
      return const LinearGradient(
        colors: [Color(0xFFC084FC), Color(0xFFEC4899)],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      );
    case 'video':
      return const LinearGradient(
        colors: [Color(0xFF3B82F6), Color(0xFF06B6D4)],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      );
    default: // 'general'
      return const LinearGradient(
        colors: [Color(0xFF8B5CF6), Color(0xFF3B82F6)],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      );
  }
}
