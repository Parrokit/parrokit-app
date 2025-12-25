// ============================================================================
// lib/features/_content/editor/presentation/sections/season_episode_section.dart
// ============================================================================
//
// [역할]
// 시즌/회차 입력 섹션 위젯.
// 시즌 번호, 에피소드 번호 자동완성.
//
// [레이어]
// Presentation Layer > Sections
// ============================================================================

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../domain/editor_state.dart';
import '../widgets/section_title.dart';
import '../clip_editor_view_model.dart';

/// 시즌/회차 입력 섹션.
class SeasonEpisodeSection extends StatelessWidget {
  const SeasonEpisodeSection({super.key, required this.vm});

  final ClipEditorViewModel vm;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SectionTitle("시즌/화"),
        const SizedBox(height: 10),
        if (vm.contentType == ContentType.season) ...[
          _buildSeasonAutocomplete(context),
          const SizedBox(height: 8),
          _buildEpisodeAutocomplete(context),
        ],
        if (vm.contentType == ContentType.movie)
          Padding(
            padding: const EdgeInsets.only(top: 4.0),
            child: Text(
              '영화 타입은 시즌/회차 정보가 필요하지 않습니다.',
              style: Theme.of(context)
                  .textTheme
                  .bodySmall
                  ?.copyWith(color: Theme.of(context).hintColor),
            ),
          ),
      ],
    );
  }

  Widget _buildSeasonAutocomplete(BuildContext context) {
    return Autocomplete<int>(
      optionsBuilder: (textEditingValue) {
        final query = textEditingValue.text.trim();
        if (query.isEmpty) return vm.seasonNumbers;
        final qNum = int.tryParse(query);
        if (qNum == null) {
          return vm.seasonNumbers.where((n) => n.toString().contains(query));
        }
        return vm.seasonNumbers.where((n) => n == qNum);
      },
      displayStringForOption: (option) => option.toString(),
      onSelected: (selection) {
        vm.seasonCtl.text = selection.toString();
        vm.loadEpisodeOptions();
      },
      fieldViewBuilder: (context, controller, focusNode, onFieldSubmitted) {
        if (controller.text != vm.seasonCtl.text) {
          controller.text = vm.seasonCtl.text;
        }
        controller.addListener(() => vm.seasonCtl.text = controller.text);
        focusNode.addListener(() {
          if (!focusNode.hasFocus) vm.loadEpisodeOptions();
        });
        return TextField(
          controller: controller,
          focusNode: focusNode,
          decoration: InputDecoration(
            labelText: '시즌',
            hintText: '몇 번째 시즌인지 숫자로 입력하세요.',
            prefixIcon: const Icon(Icons.layers_outlined),
            border: const OutlineInputBorder(),
            suffixIcon: controller.text.isEmpty
                ? null
                : IconButton(
                    icon: const Icon(Icons.clear),
                    onPressed: () {
                      controller.clear();
                      vm.seasonCtl.clear();
                    },
                  ),
          ),
          keyboardType: TextInputType.number,
          inputFormatters: [FilteringTextInputFormatter.digitsOnly],
        );
      },
      optionsViewBuilder: (context, onSelected, options) {
        return _buildIntOptionsView(options, onSelected);
      },
    );
  }

  Widget _buildEpisodeAutocomplete(BuildContext context) {
    return Autocomplete<int>(
      optionsBuilder: (textEditingValue) {
        final query = textEditingValue.text.trim();
        if (query.isEmpty) return vm.episodeNumbers;
        final qNum = int.tryParse(query);
        if (qNum == null) {
          return vm.episodeNumbers.where((n) => n.toString().contains(query));
        }
        return vm.episodeNumbers.where((n) => n == qNum);
      },
      displayStringForOption: (option) => option.toString(),
      onSelected: (selection) {
        vm.episodeCtl.text = selection.toString();
        vm.autoFillEpisodeTitle();
      },
      fieldViewBuilder: (context, controller, focusNode, onFieldSubmitted) {
        if (controller.text != vm.episodeCtl.text) {
          controller.text = vm.episodeCtl.text;
        }
        controller.addListener(() => vm.episodeCtl.text = controller.text);
        focusNode.addListener(() {
          if (!focusNode.hasFocus) vm.autoFillEpisodeTitle();
        });
        return TextField(
          controller: controller,
          focusNode: focusNode,
          decoration: InputDecoration(
            labelText: '화 (에피소드)',
            hintText: '몇 화인지 숫자로 입력하세요.',
            prefixIcon: const Icon(Icons.format_list_numbered_outlined),
            border: const OutlineInputBorder(),
            suffixIcon: controller.text.isEmpty
                ? null
                : IconButton(
                    icon: const Icon(Icons.clear),
                    onPressed: () {
                      controller.clear();
                      vm.episodeCtl.clear();
                    },
                  ),
          ),
          keyboardType: TextInputType.number,
          inputFormatters: [FilteringTextInputFormatter.digitsOnly],
        );
      },
      optionsViewBuilder: (context, onSelected, options) {
        return _buildIntOptionsView(options, onSelected);
      },
    );
  }

  Widget _buildIntOptionsView(Iterable<int> options, Function(int) onSelected) {
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
                  child: Text(option.toString()),
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}
