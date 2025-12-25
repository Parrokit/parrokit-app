// ============================================================================
// lib/features/_content/editor/presentation/sections/work_name_section.dart
// ============================================================================
//
// [역할]
// 작품명 입력 섹션 위젯.
// 작품명 자동완성 + 원어 작품명 입력.
//
// [레이어]
// Presentation Layer > Sections
// ============================================================================

import 'package:flutter/material.dart';

import '../widgets/labeled_text_field.dart';
import '../clip_editor_view_model.dart';

/// 작품명 입력 섹션.
class WorkNameSection extends StatelessWidget {
  const WorkNameSection({super.key, required this.vm});

  final ClipEditorViewModel vm;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Autocomplete<String>(
          optionsBuilder: (textEditingValue) {
            final query = textEditingValue.text.trim();
            if (query.isEmpty) return vm.allTitleNames;
            return vm.allTitleNames.where(
              (name) => name.toLowerCase().contains(query.toLowerCase()),
            );
          },
          onSelected: (selection) {
            vm.nameCtl.text = selection;
            vm.loadSeasonOptions(selection);
          },
          fieldViewBuilder: (context, controller, focusNode, onFieldSubmitted) {
            if (controller.text != vm.nameCtl.text) {
              controller.text = vm.nameCtl.text;
            }
            controller.addListener(() {
              vm.nameCtl.text = controller.text;
            });
            return TextField(
              controller: controller,
              focusNode: focusNode,
              decoration: const InputDecoration(
                labelText: '작품명',
                hintText: '영상의 시리즈/영화 제목을 입력하세요. (예: 스파이 패밀리)',
                prefixIcon: Icon(Icons.movie_outlined),
                border: OutlineInputBorder(),
              ),
            );
          },
          optionsViewBuilder: (context, onSelected, options) {
            return _buildOptionsView(options, onSelected);
          },
        ),
        const SizedBox(height: 8),
        LabeledTextField(
          label: '원어 작품명',
          hint: '작품의 본토 이름을 입력하세요.',
          controller: vm.nameNativeCtl,
          prefixIcon: Icons.movie_outlined,
          clearable: true,
        ),
      ],
    );
  }

  Widget _buildOptionsView(
      Iterable<String> options, Function(String) onSelected) {
    return Align(
      alignment: Alignment.topLeft,
      child: Material(
        elevation: 4,
        borderRadius: BorderRadius.circular(10),
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxHeight: 280, minWidth: 240),
          child: ListView.separated(
            padding: const EdgeInsets.symmetric(vertical: 6),
            shrinkWrap: true,
            itemCount: options.length,
            separatorBuilder: (_, __) =>
                const Divider(height: 1, thickness: 0.5),
            itemBuilder: (context, index) {
              final option = options.elementAt(index);
              return InkWell(
                onTap: () => onSelected(option),
                child: Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                  child: Text(option),
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}
