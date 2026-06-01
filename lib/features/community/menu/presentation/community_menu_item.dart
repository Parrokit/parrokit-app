import 'package:flutter/material.dart';

class CommunityMenuSectionItem {
  const CommunityMenuSectionItem({
    required this.title,
    required this.categories,
  });

  final String title;
  final List<CommunityMenuCategoryItem> categories;
}

class CommunityMenuCategoryItem {
  const CommunityMenuCategoryItem({
    required this.title,
    required this.items,
  });

  final String? title;
  final List<CommunityMenuItem> items;
}

class CommunityMenuItem {
  const CommunityMenuItem({
    required this.title,
    required this.icon,
    required this.colors,
    this.boardType,
    this.activityType,
  });

  final String title;
  final IconData icon;
  final CommunityMenuColors colors;
  final String? boardType;
  final String? activityType;
}

class CommunityMenuColors {
  const CommunityMenuColors({
    required this.iconColor,
    required this.bgColor,
  });

  final Color iconColor;
  final Color bgColor;
}
