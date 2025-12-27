// ============================================================================
// lib/features/_content/editor/presentation/sections/titles_section.dart
// ============================================================================
//
// [역할]
// 제목 입력 섹션 위젯.
// 회차/영화 제목 + 클립 제목.
//
// [레이어]
// Presentation Layer > Sections
// ============================================================================

import 'package:flutter/material.dart';

import '../../data/editor_strings.dart';
import '../../domain/editor_state.dart';
import '../widgets/section_title.dart';
import '../widgets/labeled_text_field.dart';
import '../clip_editor_view_model.dart';

/// 제목 입력 섹션.
class TitlesSection extends StatelessWidget {
  const TitlesSection({super.key, required this.vm});

  final ClipEditorViewModel vm;

  @override
  Widget build(BuildContext context) {
    final isMovie = vm.contentType == ContentType.movie;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SectionTitle(EditorStrings.titlesSectionTitle),
        const SizedBox(height: 10),
        LabeledTextField(
          label: isMovie
              ? EditorStrings.movieTitleLabel
              : EditorStrings.episodeTitleLabel,
          hint: isMovie
              ? EditorStrings.movieTitleHint
              : EditorStrings.episodeTitleHint,
          helper: isMovie
              ? EditorStrings.movieTitleHelper
              : EditorStrings.episodeTitleHelper,
          controller: vm.epiTitleCtl,
          prefixIcon: Icons.title_outlined,
          clearable: true,
        ),
        const SizedBox(height: 10),
        LabeledTextField(
          label: EditorStrings.clipTitleLabel,
          hint: EditorStrings.clipTitleHint,
          controller: vm.titleCtl,
          helper: EditorStrings.clipTitleHelper,
          prefixIcon: Icons.title,
          clearable: true,
        ),
      ],
    );
  }
}
