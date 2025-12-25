// ============================================================================
// lib/features/dashboard/presentation/widgets/section_header.dart
// ============================================================================
//
// [역할]
// 섹션 헤더 위젯. 제목, 부제목, 옵션 trailing 위젯 표시.
//
// [레이어]
// Presentation Layer > Widgets
// 순수 재사용 위젯 - 여러 섹션에서 공통 사용.
// ============================================================================

import 'package:flutter/material.dart';

/// 섹션 헤더 위젯.
///
/// [title]: 섹션 제목 (필수)
/// [subtitle]: 부제목 (선택)
/// [trailing]: 우측 위젯 (예: "모두 보기" 버튼)
class SectionHeader extends StatelessWidget {
  final String title;
  final String? subtitle;
  final Color textPrimary;
  final Color textSecondary;
  final Widget? trailing;

  const SectionHeader({
    super.key,
    required this.title,
    this.subtitle,
    required this.textPrimary,
    required this.textSecondary,
    this.trailing,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w900,
                  color: textPrimary,
                ),
              ),
              if (subtitle != null) ...[
                const SizedBox(height: 4),
                Text(
                  subtitle!,
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: textSecondary,
                  ),
                ),
              ],
            ],
          ),
        ),
        if (trailing != null) trailing!,
      ],
    );
  }
}
