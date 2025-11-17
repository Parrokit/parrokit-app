import 'package:flutter/material.dart';
import 'package:parrokit/mvp/recom/screens/recommendation_select_screen.dart';

/// Screen entry point. Delegates to [RecommendationSelectScreen].
class RecomScreen extends StatelessWidget {
  const RecomScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const RecommendationSelectScreen();
  }
}