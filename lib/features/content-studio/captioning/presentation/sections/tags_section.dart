// ============================================================================
// lib/features/_content/editor/presentation/sections/tags_section.dart
// ============================================================================
//
// [역할]
// 태그 입력 섹션 위젯.
// 태그 추가, 삭제, Chip 목록.
//
// [레이어]
// Presentation Layer > Sections
// ============================================================================

import 'package:flutter/material.dart';

import '../../data/constants/editor_strings.dart';
import '../widgets/labeled_text_field.dart';
import '../captioning_view_model.dart';

/// 태그 입력 섹션.
class TagsSection extends StatelessWidget {
  const TagsSection({super.key, required this.vm});

  final CaptioningViewModel vm;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        LabeledTextField(
          label: EditorStrings.tagsLabel,
          hint: EditorStrings.tagsHint,
          controller: vm.tagsCtl,
          prefixIcon: Icons.tag_outlined,
          clearable: true,
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            TextButton.icon(
              icon: const Icon(Icons.add_rounded, size: 18),
              label: Text(EditorStrings.addTagButtonLabel),
              onPressed: () {
                final tag = vm.tagsCtl.text.trim();
                if (tag.isEmpty) return;
                vm.addTag(tag);
                vm.tagsCtl.clear();
              },
            ),
            const SizedBox(width: 8),
            TextButton.icon(
              icon: const Icon(Icons.delete_rounded, size: 18),
              label: Text(EditorStrings.clearAllTagsButtonLabel),
              onPressed: () {
                for (final tag in List<String>.from(vm.tags)) {
                  vm.removeTag(tag);
                }
              },
            ),
          ],
        ),
        if (vm.tags.isNotEmpty) ...[
          const SizedBox(height: 8),
          Wrap(
            spacing: 6,
            runSpacing: -8,
            children: vm.tags
                .map((tag) => Chip(
                      label: Text(tag),
                      deleteIcon: const Icon(Icons.close_rounded, size: 18),
                      onDeleted: () => vm.removeTag(tag),
                    ))
                .toList(),
          ),
        ],
      ],
    );
  }
}
