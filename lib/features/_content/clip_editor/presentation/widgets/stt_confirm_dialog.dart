// ============================================================================
// lib/features/_content/clip_editor/presentation/widgets/stt_confirm_dialog.dart
// ============================================================================
//
// [역할]
// STT 시작 전 코인 소모 안내 + ASR 엔진 선택 다이얼로그.
//
// [레이어]
// Presentation Layer > Widgets
// ============================================================================

import 'package:flutter/material.dart';

import '../../data/adapters/asr_engine.dart';

/// STT 시작 전 안내 다이얼로그를 표시하고 사용자가 선택한 엔진을 반환합니다.
///
/// 반환값:
/// - `AsrEngine` → 사용자가 시작 확인 (선택된 엔진)
/// - `null` → 사용자가 취소
Future<AsrEngine?> showSttConfirmDialog(
  BuildContext context, {
  AsrEngine initial = AsrEngine.diarize,
}) async {
  return showDialog<AsrEngine>(
    context: context,
    builder: (ctx) {
      AsrEngine selected = initial;
      final cs = Theme.of(ctx).colorScheme;

      return StatefulBuilder(
        builder: (ctx, setState) {
          return AlertDialog(
            title: const Text('자막 자동 생성'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('30초당 1코인이 소모됩니다.'),
                const SizedBox(height: 16),
                const Text(
                  '인식 모델 선택',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 4),
                RadioGroup<AsrEngine>(
                  groupValue: selected,
                  onChanged: (v) => setState(() => selected = v ?? selected),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: AsrEngine.values.map((e) {
                      return RadioListTile<AsrEngine>(
                        value: e,
                        title: Text(e.label),
                        subtitle: Text(
                          e.description,
                          style: const TextStyle(fontSize: 12),
                        ),
                        contentPadding: EdgeInsets.zero,
                        dense: true,
                      );
                    }).toList(),
                  ),
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(ctx, null),
                child: const Text('취소'),
              ),
              FilledButton(
                onPressed: () => Navigator.pop(ctx, selected),
                style: FilledButton.styleFrom(backgroundColor: cs.primary),
                child: const Text('시작'),
              ),
            ],
          );
        },
      );
    },
  );
}
