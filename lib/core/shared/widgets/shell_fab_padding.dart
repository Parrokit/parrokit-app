// ============================================================================
// lib/core/shared/widgets/shell_fab_padding.dart
// ============================================================================
//
// [역할]
// AppShell(바깥 Scaffold)의 bottomNavigationBar는 extendBody 때문에 안쪽
// 화면의 Scaffold에 자동으로 반영되지 않습니다. 그래서 `Scaffold.
// floatingActionButton`으로 FAB를 쓰는 화면(대시보드, 커뮤니티 등)은 이
// 위젯으로 감싸서 네비바 위에 붙여야 합니다. `Positioned`로 직접
// 배치하는 화면(콜렉션 등)은 이미 자기 위치를 스스로 계산하므로 이
// 위젯을 쓰지 않습니다 — 배치 방식이 다른 화면끼리 같은 위치 로직을
// 강제로 공유하면 오히려 이중으로 겹쳐 어긋납니다.
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
