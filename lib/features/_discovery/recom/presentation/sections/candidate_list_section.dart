// ============================================================================
// lib/features/recom/presentation/sections/candidate_list_section.dart
// ============================================================================
//
// [역할]
// 추천 후보 애니메이션 목록 섹션.
// 선택 가능한 리스트 표시.
//
// [레이어]
// Presentation Layer > Sections
// ============================================================================

import 'package:flutter/material.dart';

/// 후보 목록 섹션.
class CandidateListSection extends StatelessWidget {
  const CandidateListSection({
    super.key,
    required this.candidates,
    required this.selected,
    required this.onToggle,
  });

  final List<String> candidates;
  final List<String> selected;
  final void Function(String title) onToggle;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: ListView.builder(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: candidates.length,
        itemBuilder: (_, i) {
          final title = candidates[i];
          final isSelected = selected.contains(title);

          return ListTile(
            title: Text(title),
            trailing: isSelected
                ? const Icon(Icons.check_circle)
                : const Icon(Icons.circle_outlined),
            onTap: () => onToggle(title),
          );
        },
      ),
    );
  }
}
