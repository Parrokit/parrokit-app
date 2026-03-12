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
import 'package:parrokit/core/theme/app_radius.dart';

import '../../data/editor_strings.dart';
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
            vm.autoFillNativeTitle(selection);
          },
          fieldViewBuilder: (context, controller, focusNode, onFieldSubmitted) {
            if (controller.text != vm.nameCtl.text) {
              controller.text = vm.nameCtl.text;
            }
            controller.addListener(() {
              vm.nameCtl.text = controller.text;
            });
            return LabeledTextField(
              label: EditorStrings.workNameLabel,
              hint: EditorStrings.workNameHint,
              controller: controller,
              focusNode: focusNode,
              prefixIcon: Icons.movie_outlined,
              clearable: true,
            );
          },
          optionsViewBuilder: (context, onSelected, options) {
            return _buildOptionsView(options, onSelected);
          },
        ),
        const SizedBox(height: 8),
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: LabeledTextField(
                label: EditorStrings.workNameNativeLabel,
                hint: EditorStrings.workNameNativeHint,
                controller: vm.nameNativeCtl,
                prefixIcon: Icons.movie_outlined,
                clearable: true,
              ),
            ),
            const SizedBox(width: 8),
            Padding(
              padding: const EdgeInsets.only(top: 24),
              child: FilledButton.icon(
                onPressed:
                    vm.isLookingUpNativeTitle ? null : vm.lookupNativeTitle,
                style: FilledButton.styleFrom(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(AppRadius.md),
                  ),
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                ),
                icon: vm.isLookingUpNativeTitle
                    ? const SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Icon(Icons.auto_awesome, size: 18),
                label: Text(
                  vm.isLookingUpNativeTitle
                      ? EditorStrings.workNameNativeLookupLoading
                      : EditorStrings.workNameNativeLookupButton,
                ),
              ),
            ),
          ],
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
