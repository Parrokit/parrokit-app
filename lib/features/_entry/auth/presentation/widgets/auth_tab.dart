// ============================================================================
// lib/features/auth/presentation/widgets/auth_tab.dart
// ============================================================================
//
// [역할]
// 로그인/회원가입 탭 버튼 위젯.
// 탭 선택 상태에 따라 스타일 변경.
//
// [레이어]
// Presentation Layer > Widgets
// - 순수 재사용 가능한 UI 컴포넌트
// - 상태 없음 (StatelessWidget)
// - 다른 화면에서도 재사용 가능
// ============================================================================

import 'package:flutter/material.dart';

/// 로그인/회원가입 탭 버튼 위젯.
///
/// 선택 상태에 따라 밑줄과 색상이 변경됨.
/// [AuthFormSection]에서 모드 전환에 사용.
class AuthTab extends StatelessWidget {
  // ─────────────────────────────────────────────────────────────────
  // 필수 파라미터
  // ─────────────────────────────────────────────────────────────────

  /// 탭 레이블 텍스트
  final String label;

  /// 현재 선택 상태
  final bool selected;

  /// 탭 클릭 콜백
  final VoidCallback onTap;

  const AuthTab({
    super.key,
    required this.label,
    required this.selected,
    required this.onTap,
  });

  // ─────────────────────────────────────────────────────────────────
  // Build
  // ─────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final baseStyle = theme.textTheme.titleMedium;

    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 160),
        padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 4),
        decoration: BoxDecoration(
          border: Border(
            bottom: BorderSide(
              // 선택 시 primary 색상 밑줄, 미선택 시 투명
              color: selected ? theme.colorScheme.primary : Colors.transparent,
              width: 2,
            ),
          ),
        ),
        child: Text(
          label,
          style: baseStyle?.copyWith(
            // 선택 시 굵고 primary 색상, 미선택 시 얇고 회색
            fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
            color: selected
                ? theme.colorScheme.primary
                : theme.colorScheme.onSurface.withValues(alpha: 0.6),
          ),
        ),
      ),
    );
  }
}
