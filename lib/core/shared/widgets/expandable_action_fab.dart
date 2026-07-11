// ============================================================================
// lib/core/shared/widgets/expandable_action_fab.dart
// ============================================================================
//
// [역할]
// 아이콘만 보이다가 [isExtended]가 true면 라벨까지 펼쳐지는 pill 모양 FAB.
// 대시보드의 "콘텐츠 제작", 커뮤니티의 "글쓰기", 콜렉션의 "클립/그룹/콜렉션
// 메뉴"처럼 구조는 같고 색상/아이콘/라벨/크기만 다른 FAB를 화면마다
// 복제하지 않기 위한 단일 위젯입니다.
//
// 화면 내 위치(하단 여백 등)는 이 위젯의 책임이 아니라 쓰는 쪽이
// 결정합니다 — 대시보드/커뮤니티는 `Scaffold.floatingActionButton`으로
// 쓰지만, 콜렉션은 `Stack` 안에서 `Positioned`로 직접 배치하는 등
// 화면마다 배치 방식 자체가 다르기 때문입니다. 위치 계산까지 이 위젯이
// 떠맡으면 배치 방식이 다른 화면에서 이중으로 겹쳐 오히려 어긋납니다.
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
    this.fontSize = 18,
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
  final double fontSize;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return AnimatedContainer(
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
                              fontSize: fontSize,
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
    );
  }
}
