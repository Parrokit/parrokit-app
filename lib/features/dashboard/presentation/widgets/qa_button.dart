// ============================================================================
// lib/features/dashboard/presentation/widgets/qa_button.dart
// ============================================================================
//
// [역할]
// 퀵 액션 버튼 위젯. 아이콘 + 레이블 조합의 칩 스타일 버튼.
//
// [레이어]
// Presentation Layer > Widgets
// 순수 재사용 위젯 - QuickActionsSection에서 사용.
// ============================================================================

import 'package:flutter/material.dart';

/// 퀵 액션 버튼 위젯.
///
/// 가로 스크롤 액션 바에서 사용하는 칩 스타일 버튼.
class QAButton extends StatelessWidget {
  final String label;
  final IconData icon;
  final Color cardBg;
  final Color subtle;
  final Color textPrimary;
  final Color textSecondary;
  final VoidCallback onTap;

  const QAButton({
    super.key,
    required this.label,
    required this.icon,
    required this.cardBg,
    required this.subtle,
    required this.textPrimary,
    required this.textSecondary,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(16),
      onTap: onTap,
      child: Ink(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: cardBg,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: subtle),
        ),
        child: ConstrainedBox(
          constraints: const BoxConstraints(minWidth: 60, maxWidth: 180),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, size: 20),
              const SizedBox(width: 8),
              Flexible(
                child: Text(
                  label,
                  maxLines: 1,
                  softWrap: false,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontWeight: FontWeight.w800,
                    color: textPrimary,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
