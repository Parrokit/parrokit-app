// ============================================================================
// lib/core/shared/widgets/shell_fab_padding.dart
// ============================================================================
//
// [역할]
// AppShell(바깥 Scaffold)의 bottomNavigationBar는 extendBody 때문에 안쪽
// 화면의 Scaffold에 자동으로 반영되지 않습니다. 그래서 화면마다 FAB를
// 네비바 위에 붙이려면 직접 여백을 계산해야 하는데, 화면마다 따로
// 계산하면 화면 전환 시 FAB 높이가 미묘하게 달라지는 문제가 생깁니다.
// 이 위젯이 그 계산을 한 곳에서 담당합니다.
//
// [레이어]
// Core > Shared > Widgets
// ============================================================================

import 'package:flutter/material.dart';

class ShellFabPadding extends StatelessWidget {
  const ShellFabPadding({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    final bottomInset = MediaQuery.paddingOf(context).bottom;
    return Padding(
      padding: EdgeInsets.only(bottom: kBottomNavigationBarHeight + bottomInset),
      child: child,
    );
  }
}
