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

import '../../data/editor_strings.dart';
import '../widgets/section_title.dart';
import '../widgets/labeled_text_field.dart';
import '../clip_editor_view_model.dart';

/// 태그 입력 섹션.
class TagsSection extends StatelessWidget {
  const TagsSection({super.key, required this.vm});

  final ClipEditorViewModel vm;

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SectionTitle(EditorStrings.tagsSectionTitle),
        const SizedBox(height: 10),
        LabeledTextField(
          label: EditorStrings.tagsLabel,
          hint: EditorStrings.tagsHint,
          controller: vm.tagsCtl,
          helper: EditorStrings.tagsHelper,
          prefixIcon: Icons.tag_outlined,
          clearable: true,
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            FilledButton.icon(
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
            FilledButton(
              style: FilledButton.styleFrom(
                side: BorderSide(
                  width: 1,
                  color: t.colorScheme.onSurface.withValues(alpha: 0.38),
                ),
                backgroundColor: t.colorScheme.surface,
                foregroundColor: t.colorScheme.primary,
              ),
              onPressed: () {
                for (final tag in List<String>.from(vm.tags)) {
                  vm.removeTag(tag);
                }
              },
              child: Text(EditorStrings.clearAllTagsButtonLabel),
            ),
          ],
        ),
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
    );
  }
}
