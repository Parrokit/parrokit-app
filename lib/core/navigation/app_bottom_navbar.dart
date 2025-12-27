// ============================================================================
// lib/core/navigation/app_bottom_navbar.dart
// ============================================================================
//
// [역할]
// 앱 하단 네비게이션 바 위젯.
// 홈, 탐색, 라이브러리, 애니 추천, 더보기 탭으로 구성.
//
// [레이어]
// Core Layer > Navigation
// 앱 전체 네비게이션 쉘 컴포넌트.
// ============================================================================

import 'package:flutter/material.dart';

/// 앱 하단 네비게이션 바.
///
/// [currentIndex]: 현재 선택된 탭 인덱스
/// [onTap]: 탭 선택 콜백
class AppBottomNavBar extends StatelessWidget {
  const AppBottomNavBar({
    super.key,
    required this.currentIndex,
    required this.onTap,
  });

  final int currentIndex;
  final ValueChanged<int> onTap;

  @override
  Widget build(BuildContext context) {
    return BottomNavigationBar(
      currentIndex: currentIndex,
      onTap: onTap,
      items: const [
        BottomNavigationBarItem(icon: Icon(Icons.home_filled), label: '홈'),
        BottomNavigationBarItem(icon: Icon(Icons.explore), label: '탐색'),
        BottomNavigationBarItem(icon: Icon(Icons.bookmarks), label: '라이브러리'),
        BottomNavigationBarItem(icon: Icon(Icons.more_horiz), label: '더보기'),
      ],
    );
  }
}
