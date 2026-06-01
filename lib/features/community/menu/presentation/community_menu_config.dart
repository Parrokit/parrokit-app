import 'package:flutter/material.dart';
import 'package:parrokit/core/theme/app_colors.dart';
import 'community_menu_item.dart';

List<CommunityMenuSectionItem> buildCommunityMenuSections() {
  final boardColors = CommunityMenuColors(
    iconColor: AppColors.communityBoardAccent,
    bgColor: AppColors.communityBoardAccentSoft,
  );
  final questionColors = CommunityMenuColors(
    iconColor: AppColors.communityQuestionAccent,
    bgColor: AppColors.communityQuestionAccentSoft,
  );
  final voteColors = CommunityMenuColors(
    iconColor: AppColors.communityVoteAccent,
    bgColor: AppColors.communityVoteAccentSoft,
  );
  final settingsColors = CommunityMenuColors(
    iconColor: AppColors.textSecondary,
    bgColor: AppColors.surfaceContainerHigh,
  );

  return [
    CommunityMenuSectionItem(
      title: '나의 활동',
      categories: [
        CommunityMenuCategoryItem(
          title: '일반 게시판',
          items: [
            CommunityMenuItem(title: '작성한 글', icon: Icons.article_rounded, colors: boardColors),
            CommunityMenuItem(title: '작성한 댓글', icon: Icons.chat_bubble_rounded, colors: boardColors),
            CommunityMenuItem(title: '공감한 글', icon: Icons.thumb_up_rounded, colors: boardColors),
            CommunityMenuItem(title: '공감한 댓글', icon: Icons.favorite_rounded, colors: boardColors),
            CommunityMenuItem(title: '스크랩', icon: Icons.bookmark_rounded, colors: boardColors),
          ],
        ),
        CommunityMenuCategoryItem(
          title: '질문 게시판',
          items: [
            CommunityMenuItem(title: '작성한 질문', icon: Icons.help_rounded, colors: questionColors),
            CommunityMenuItem(title: '작성한 답변', icon: Icons.forum_rounded, colors: questionColors),
            CommunityMenuItem(title: '답변에 달린 댓글', icon: Icons.chat_rounded, colors: questionColors),
            CommunityMenuItem(title: '공감한 질문', icon: Icons.thumb_up_rounded, colors: questionColors),
            CommunityMenuItem(title: '공감한 답변 및 댓글', icon: Icons.favorite_rounded, colors: questionColors),
            CommunityMenuItem(title: '스크랩', icon: Icons.bookmark_rounded, colors: questionColors),
          ],
        ),
        CommunityMenuCategoryItem(
          title: '투표 게시판',
          items: [
            CommunityMenuItem(title: '참여한 투표', icon: Icons.how_to_vote_rounded, colors: voteColors),
            CommunityMenuItem(title: '작성한 댓글', icon: Icons.chat_rounded, colors: voteColors),
            CommunityMenuItem(title: '공감한 투표', icon: Icons.thumb_up_rounded, colors: voteColors),
            CommunityMenuItem(title: '공감한 댓글', icon: Icons.favorite_rounded, colors: voteColors),
            CommunityMenuItem(title: '스크랩', icon: Icons.bookmark_rounded, colors: voteColors),
          ],
        ),
      ],
    ),
    CommunityMenuSectionItem(
      title: '커뮤니티 설정',
      categories: [
        CommunityMenuCategoryItem(
          title: null,
          items: [
            CommunityMenuItem(
              title: '알림 설정',
              icon: Icons.notifications_rounded,
              colors: settingsColors,
            ),
            CommunityMenuItem(
              title: '차단 사용자 관리',
              icon: Icons.shield_rounded,
              colors: settingsColors,
            ),
          ],
        ),
      ],
    ),
  ];
}
