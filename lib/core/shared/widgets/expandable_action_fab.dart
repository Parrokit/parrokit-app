// ============================================================================
// lib/core/shared/widgets/expandable_action_fab.dart
// ============================================================================
//
// [역할]
// 아이콘만 보이다가 [isExtended]가 true면 라벨까지 펼쳐지는 pill 모양 FAB.
// 대시보드의 "콘텐츠 제작", 커뮤니티의 "글쓰기"처럼 구조는 같고 색상/아이콘/
// 라벨만 다른 FAB를 화면마다 복제하지 않기 위한 단일 위젯입니다.
//
// AppShell(바깥 Scaffold)의 bottomNavigationBar는 extendBody 때문에 안쪽
// 화면의 Scaffold에 자동으로 반영되지 않으므로, 네비바 위에 붙이기 위한
// 하단 여백 계산도 이 위젯이 직접 담당합니다. 화면마다 별도 위젯으로
// 감싸서 여백을 계산하면 화면끼리 값이 어긋날 여지가 생기므로, 쓰는
// 쪽은 이 위젯 하나만 `floatingActionButton`에 그대로 꽂으면 됩니다.
//
// [레이어]
// Core > Shared > Widgets
// ============================================================================

import 'package:flutter/material.dart';

class ExpandableActionFab extends StatelessWidget {
  const ExpandableActionFab({
    super.key,
    required this.isExtended,
    required this.icon,
    required this.label,
    required this.onTap,
    required this.backgroundColor,
    required this.foregroundColor,
    this.border,
    this.boxShadow,
    this.iconSize = 22,
  });

  final bool isExtended;
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final Color backgroundColor;
  final Color foregroundColor;
  final BoxBorder? border;
  final List<BoxShadow>? boxShadow;
  final double iconSize;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final bottomInset = MediaQuery.paddingOf(context).bottom;

    return Padding(
      padding: EdgeInsets.only(bottom: kBottomNavigationBarHeight + bottomInset),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 250),
        curve: Curves.easeInOut,
        height: 56,
        decoration: BoxDecoration(
          color: backgroundColor,
          borderRadius: BorderRadius.circular(28),
          border: border,
          boxShadow: boxShadow ??
              [
                BoxShadow(
                  color: colorScheme.shadow.withValues(alpha: 0.14),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
        ),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            borderRadius: BorderRadius.circular(28),
            onTap: onTap,
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: isExtended ? 20.0 : 16.0),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(icon, color: foregroundColor, size: iconSize),
                  AnimatedSize(
                    duration: const Duration(milliseconds: 250),
                    curve: Curves.easeInOut,
                    child: ClipRect(
                      child: Align(
                        alignment: Alignment.centerLeft,
                        widthFactor: isExtended ? 1 : 0,
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const SizedBox(width: 8),
                            Text(
                              label,
                              style: TextStyle(
                                color: foregroundColor,
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.clip,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
