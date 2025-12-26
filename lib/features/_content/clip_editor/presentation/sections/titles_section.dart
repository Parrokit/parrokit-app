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
        SectionTitle("제목"),
        const SizedBox(height: 10),
        LabeledTextField(
          label: isMovie ? '영화 제목' : '회차 제목',
          hint: isMovie ? '영화의 제목을 입력하세요.' : '회차의 제목을 입력하세요.',
          helper: isMovie
              ? '시리즈가 없는 단독 영화의 경우,\n작품명과 동일하거나 편한대로 작성해주세요.'
              : '수정한 경우, 기존 값은 새 내용으로 갱신됩니다.',
          controller: vm.epiTitleCtl,
          prefixIcon: Icons.title_outlined,
          clearable: true,
        ),
        const SizedBox(height: 10),
        LabeledTextField(
          label: '클립 제목',
          hint: '클립 제목을 입력하세요.',
          controller: vm.titleCtl,
          helper: '어떤 장면인지 바로 알아볼 수 있게 간결하게 적어주세요.',
          prefixIcon: Icons.title,
          clearable: true,
        ),
      ],
    );
  }
}
