import 'package:flutter/material.dart';
import 'package:parrokit/core/theme/app_colors.dart';
import 'community_menu_builders.dart';
import 'community_menu_item.dart';

List<CommunityMenuSectionItem> buildCommunityMenuSections() {
  final boardColors = buildMenuColors(
    iconColor: AppColors.communityBoardAccent,
    bgColor: AppColors.communityBoardAccentSoft,
  );
  final questionColors = buildMenuColors(
    iconColor: AppColors.communityQuestionAccent,
    bgColor: AppColors.communityQuestionAccentSoft,
  );
  final voteColors = buildMenuColors(
    iconColor: AppColors.communityVoteAccent,
    bgColor: AppColors.communityVoteAccentSoft,
  );
  final settingsColors = buildMenuColors(
    iconColor: AppColors.textSecondary,
    bgColor: AppColors.surfaceContainerHigh,
  );

  return [
    CommunityMenuSectionItem(
      title: '나의 활동',
      categories: [
        CommunityMenuCategoryItem(
          title: '일반 게시판',
          items: buildBoardItems(boardColors),
        ),
        CommunityMenuCategoryItem(
          title: '질문 게시판',
          items: buildQuestionItems(questionColors),
        ),
        CommunityMenuCategoryItem(
          title: '투표 게시판',
          items: buildVoteItems(voteColors),
        ),
      ],
    ),
    CommunityMenuSectionItem(
      title: '커뮤니티 설정',
      categories: [
        CommunityMenuCategoryItem(
          title: null,
          items: [
            buildMenuItem(title: '알림 설정', icon: Icons.notifications_rounded, colors: settingsColors),
            buildMenuItem(title: '차단 사용자 관리', icon: Icons.shield_rounded, colors: settingsColors),
          ],
        ),
      ],
    ),
  ];
}

CommunityMenuColors buildMenuColors({
  required Color iconColor,
  required Color bgColor,
}) {
  return CommunityMenuColors(iconColor: iconColor, bgColor: bgColor);
}
