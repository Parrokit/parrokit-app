// ============================================================================
// lib/features/_content/editor/presentation/sections/type_section.dart
// ============================================================================
//
// [역할]
// 콘텐츠 타입 선택 섹션 위젯.
// 시즌/영화 SegmentedButton.
//
// [레이어]
// Presentation Layer > Sections
// ============================================================================

import 'package:flutter/material.dart';

import '../../data/editor_strings.dart';
import '../../domain/editor_state.dart';
import '../widgets/section_title.dart';
import '../clip_editor_view_model.dart';

/// 콘텐츠 타입 선택 섹션.
class TypeSection extends StatelessWidget {
  const TypeSection({super.key, required this.vm});

  final ClipEditorViewModel vm;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SectionTitle(EditorStrings.typeSectionTitle),
        const SizedBox(height: 10),
        Row(
          children: [
            Expanded(
              child: SegmentedButton<ContentType>(
                segments: const [
                  ButtonSegment(value: ContentType.season, label: Text('시즌')),
                  ButtonSegment(value: ContentType.movie, label: Text('영화')),
                ],
                selected: {vm.contentType},
                onSelectionChanged: (s) => vm.setContentType(s.first),
                showSelectedIcon: false,
              ),
            ),
          ],
        ),
      ],
    );
  }
}
