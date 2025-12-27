import 'package:flutter/material.dart';

import '../../data/editor_strings.dart';
import 'time_triplet_field.dart';
import 'card_container.dart';
import 'labeled_text_field.dart';

class SegmentCard extends StatelessWidget {
  const SegmentCard({
    super.key,
    required this.index,
    required this.startCtl,
    required this.endCtl,
    required this.originalCtl,
    required this.pronCtl,
    required this.koCtl,
  });

  final int index;
  final TextEditingController startCtl;
  final TextEditingController endCtl;
  final TextEditingController originalCtl;
  final TextEditingController pronCtl;
  final TextEditingController koCtl;

  @override
  Widget build(BuildContext context) {
    final tt = Theme.of(context).textTheme;

    return CardContainer(
      padding: const EdgeInsets.fromLTRB(12, 12, 12, 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(EditorStrings.segmentCardTitle(index),
              style: tt.bodyLarge?.copyWith(fontWeight: FontWeight.w800)),
          const SizedBox(height: 10),

          // ✅ 세로(Column) 배치로 변경: 시작 → 간격 → 끝
          TimeTripletField(label: '시작', target: startCtl, showGuide: false),
          const SizedBox(height: 12),
          TimeTripletField(label: '끝', target: endCtl),
          const SizedBox(height: 14),

          LabeledTextField(
            label: EditorStrings.pronLabel,
            hint: EditorStrings.pronHint,
            controller: pronCtl,
            helper: EditorStrings.pronHelper,
            prefixIcon: Icons.record_voice_over_outlined,
            clearable: true,
          ),
          const SizedBox(height: 10),
          LabeledTextField(
            label: EditorStrings.originalLabel,
            hint: EditorStrings.originalHint,
            controller: originalCtl,
            helper: EditorStrings.originalHelper,
            prefixIcon: Icons.translate,
            clearable: true,
          ),
          const SizedBox(height: 10),
          LabeledTextField(
            label: EditorStrings.koLabel,
            hint: EditorStrings.koHint,
            controller: koCtl,
            helper: EditorStrings.koHelper,
            prefixIcon: Icons.subtitles_outlined,
            clearable: true,
          ),
        ],
      ),
    );
  }
}
