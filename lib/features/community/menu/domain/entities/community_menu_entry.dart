class CommunityMenuSectionEntry {
  const CommunityMenuSectionEntry({
    required this.title,
    required this.categories,
  });

  final String title;
  final List<CommunityMenuCategoryEntry> categories;
}

class CommunityMenuCategoryEntry {
  const CommunityMenuCategoryEntry({
    required this.title,
    required this.items,
  });

  final String? title;
  final List<CommunityMenuEntry> items;
}

class CommunityMenuEntry {
  const CommunityMenuEntry({
    required this.title,
    required this.iconKey,
    required this.colorKey,
    this.boardType,
    this.activityType,
    this.routePath,
  });

  final String title;
  final String iconKey;
  final String colorKey;
  final String? boardType;
  final String? activityType;
  final String? routePath;
}
