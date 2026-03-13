// ============================================================================
// lib/features/_content/editor/presentation/sections/work_name_section.dart
// ============================================================================
//
// [역할]
// 컬렉션 이름 입력 섹션 위젯 (선택 사항).
// 자동완성 지원.
//
// [레이어]
// Presentation Layer > Sections
// ============================================================================

import 'package:flutter/material.dart';

import '../../data/constants/editor_strings.dart';
import '../widgets/labeled_text_field.dart';
import '../clip_editor_view_model.dart';

/// 컬렉션 이름 입력 섹션.
class WorkNameSection extends StatelessWidget {
  const WorkNameSection({super.key, required this.vm});

  final ClipEditorViewModel vm;

  @override
  Widget build(BuildContext context) {
    return Autocomplete<String>(
      optionsBuilder: (textEditingValue) {
        final query = textEditingValue.text.trim();
        if (query.isEmpty) return vm.allCollectionNames;
        return vm.allCollectionNames.where(
          (name) => name.toLowerCase().contains(query.toLowerCase()),
        );
      },
      onSelected: (selection) {
        vm.collectionNameCtl.text = selection;
      },
      fieldViewBuilder: (context, controller, focusNode, onFieldSubmitted) {
        if (controller.text != vm.collectionNameCtl.text) {
          controller.text = vm.collectionNameCtl.text;
        }
        controller.addListener(() {
          vm.collectionNameCtl.text = controller.text;
        });
        return LabeledTextField(
          label: EditorStrings.collectionLabel,
          hint: EditorStrings.collectionHint,
          controller: controller,
          focusNode: focusNode,
          prefixIcon: Icons.folder_outlined,
          clearable: true,
        );
      },
      optionsViewBuilder: (context, onSelected, options) {
        return _buildOptionsView(options, onSelected);
      },
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
