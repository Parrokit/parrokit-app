import 'package:flutter/material.dart';
import 'package:parrokit/core/theme/app_colors.dart';

class CommunityMenuCategoryLabel extends StatelessWidget {
  const CommunityMenuCategoryLabel({
    super.key,
    required this.title,
  });

  final String title;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(4, 10, 4, 4),
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 13,
          fontWeight: FontWeight.w700,
          color: AppColors.comm9AA3AF,
        ),
      ),
    );
  }
}

class CommunityMenuSectionTitle extends StatelessWidget {
  const CommunityMenuSectionTitle({
    super.key,
    required this.title,
  });

  final String title;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(4, 6, 4, 8),
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w700,
          color: AppColors.comm7E8794,
        ),
      ),
    );
  }
}
