import 'package:flutter/material.dart';

class VoteScreen extends StatelessWidget {
  final String selectedFilter;

  const VoteScreen({super.key, required this.selectedFilter});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Text('투표 화면 (필터: $selectedFilter)'),
    );
  }
}
