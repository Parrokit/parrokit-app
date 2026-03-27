// ============================================================================
// lib/features/_content/clip_editor/presentation/widgets/stt_confirm_dialog.dart
// ============================================================================
//
// [역할]
// STT 시작 전 코인 소모 안내 다이얼로그.
//
// [레이어]
// Presentation Layer > Widgets
// ============================================================================

import 'package:flutter/material.dart';

/// STT 시작 전 코인 안내 다이얼로그를 표시합니다.
///
/// [true] 반환 → 사용자가 시작 확인
/// [false] 반환 → 사용자가 취소
Future<bool> showSttConfirmDialog(BuildContext context) async {
  final result = await showDialog<bool>(
    context: context,
    builder: (ctx) {
      final cs = Theme.of(ctx).colorScheme;
      return AlertDialog(
        title: const Text('자막 자동 생성'),
        content: const Text(
          '30초당 1코인이 소모됩니다.\n시작하시겠어요?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('취소'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: FilledButton.styleFrom(
              backgroundColor: cs.primary,
            ),
            child: const Text('시작'),
          ),
        ],
      );
    },
  );
  return result ?? false;
}
