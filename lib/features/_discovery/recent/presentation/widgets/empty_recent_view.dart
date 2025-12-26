// ============================================================================
// lib/features/recent/presentation/widgets/empty_recent_view.dart
// ============================================================================
//
// [역할]
// 최근 본 클립이 없을 때 표시하는 빈 상태 뷰.
//
// [레이어]
// Presentation Layer > Widgets
// ============================================================================

import 'package:flutter/material.dart';
import 'package:parrokit/core/theme/app_spacing.dart';

/// 최근 본 클립 빈 상태 뷰.
class EmptyRecentView extends StatelessWidget {
  const EmptyRecentView({super.key});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.sectionGap),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.history_toggle_off,
              size: 48,
              color: cs.outline,
            ),
            const SizedBox(height: 10),
            Text(
              '아직 최근 본 클립이 없어요',
              style: tt.titleMedium?.copyWith(fontWeight: FontWeight.w800),
            ),
            const SizedBox(height: 6),
            Text(
              '플레이어에서 시청하면 자동으로 여기에 쌓입니다.',
              style: tt.bodyMedium?.copyWith(
                color: cs.onSurface.withValues(alpha: 0.7),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
