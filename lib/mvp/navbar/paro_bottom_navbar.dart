// lib/mvp/navbar/paro_bottom_navbar.dart
import 'package:flutter/material.dart';

class ParoBottomNavBar extends StatelessWidget {
  const ParoBottomNavBar({
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
