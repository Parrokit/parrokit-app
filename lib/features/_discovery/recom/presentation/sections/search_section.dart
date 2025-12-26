// ============================================================================
// lib/features/recom/presentation/sections/search_section.dart
// ============================================================================
//
// [역할]
// 추천 화면의 검색 입력 섹션.
// 검색 필드 + 검색어 추가 힌트 표시.
//
// [레이어]
// Presentation Layer > Sections
// ============================================================================

import 'package:flutter/material.dart';
import 'package:parrokit/core/theme/app_spacing.dart';

/// 검색 입력 섹션.
class SearchSection extends StatelessWidget {
  const SearchSection({
    super.key,
    required this.controller,
    required this.onChanged,
    required this.onSubmit,
    required this.onAddFromSearch,
    required this.showAddHint,
    required this.searchTerm,
  });

  final TextEditingController controller;
  final VoidCallback onChanged;
  final VoidCallback onSubmit;
  final VoidCallback onAddFromSearch;
  final bool showAddHint;
  final String searchTerm;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // 검색 필드
        Padding(
          padding: const EdgeInsets.all(AppSpacing.lg),
          child: TextField(
            controller: controller,
            textInputAction: TextInputAction.search,
            decoration: InputDecoration(
              hintText: '애니 제목으로 검색',
              prefixIcon: const Icon(Icons.search),
              suffixIcon: controller.text.trim().isEmpty
                  ? null
                  : IconButton(
                      tooltip: '이 제목 추가',
                      icon: const Icon(Icons.add_circle_outline),
                      onPressed: onAddFromSearch,
                    ),
              border: const OutlineInputBorder(borderSide: BorderSide.none),
              filled: true,
            ),
            onChanged: (_) => onChanged(),
            onSubmitted: (_) {
              if (controller.text.trim().isNotEmpty) onSubmit();
            },
          ),
        ),

        // 검색어 추가 힌트
        if (showAddHint)
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
            child: Align(
              alignment: Alignment.centerLeft,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  InputChip(
                    avatar: const Icon(Icons.tips_and_updates, size: 18),
                    label: Text("'$searchTerm' 추가"),
                    onPressed: onAddFromSearch,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Enter 키 또는 + 버튼으로 빠르게 담을 수 있어요.',
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                ],
              ),
            ),
          ),
      ],
    );
  }
}
