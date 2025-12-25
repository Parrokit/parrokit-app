// ============================================================================
// lib/features/recom/presentation/recom_screen.dart
// ============================================================================
//
// [역할]
// 추천 기능 진입점 화면.
// RecomSelectScreen으로 위임.
//
// [레이어]
// Presentation Layer
// ============================================================================

import 'package:flutter/material.dart';
import 'recom_select_screen.dart';

/// 추천 기능 진입점.
class RecomScreen extends StatelessWidget {
  const RecomScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const RecomSelectScreen();
  }
}
