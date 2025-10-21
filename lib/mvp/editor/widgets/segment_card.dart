// lib/mvp/editor/widgets/segment_card.dart
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:parrokit/mvp/editor/widgets/time_triplet_field.dart';
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
          Text('구간 #$index',
              style: tt.bodyLarge?.copyWith(fontWeight: FontWeight.w800)),
          const SizedBox(height: 10),

          // ✅ 세로(Column) 배치로 변경: 시작 → 간격 → 끝
          TimeTripletField(label: '시작', target: startCtl,showGuide: false),
          const SizedBox(height: 12),
          TimeTripletField(label: '끝', target: endCtl),
          const SizedBox(height: 14),

          LabeledTextField(
            label: '발음',
            hint: 'bonjour / 봉주르',
            controller: pronCtl,
            helper: '로마자·한글·자국어 표기 등 편한 방식으로 적어도 좋아요.',
            prefixIcon: Icons.record_voice_over_outlined,
            clearable: true,
          ),
          const SizedBox(height: 10),
          LabeledTextField(
            label: '원문',
            hint: '原文 예: merci / gracias / 谢谢',
            controller: originalCtl,
            helper: '대사의 원문(아무 언어나)을 입력하세요.',
            prefixIcon: Icons.translate,
            clearable: true,
          ),
          const SizedBox(height: 10),
          LabeledTextField(
            label: '해석',
            hint: '고마워 / 감사합니다',
            controller: koCtl,
            helper: '본인이 이해하기 쉬운 표현으로 번역을 적어주세요.',
            prefixIcon: Icons.subtitles_outlined,
            clearable: true,
          ),
        ],
      ),
    );
  }
}