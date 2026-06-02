// ============================================================================
// lib/features/_content/editor/presentation/sections/titles_section.dart
// ============================================================================
//
// [역할]
// 클립 제목 입력 섹션 위젯.
//
// [레이어]
// Presentation Layer > Sections
// ============================================================================

import 'package:flutter/material.dart';

import '../../data/constants/editor_strings.dart';
import '../widgets/labeled_text_field.dart';
import '../captioning_view_model.dart';

/// 제목 입력 섹션.
class TitlesSection extends StatelessWidget {
  const TitlesSection({super.key, required this.vm});

  final CaptioningViewModel vm;

  @override
  Widget build(BuildContext context) {
    return LabeledTextField(
      label: EditorStrings.clipTitleLabel,
      hint: EditorStrings.clipTitleHint,
      controller: vm.titleCtl,
      prefixIcon: Icons.title,
      clearable: true,
    );
  }
}
