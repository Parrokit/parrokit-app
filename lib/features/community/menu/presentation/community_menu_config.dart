import 'package:flutter/material.dart';
import 'community_menu_item.dart';

List<CommunityMenuSectionItem> buildCommunityMenuSections() {
  final boardColors = CommunityMenuColors(
    iconColor: Colors.blue[600]!,
    bgColor: Colors.blue[50]!,
  );
  final questionColors = CommunityMenuColors(
    iconColor: Colors.deepPurple[600]!,
    bgColor: Colors.deepPurple[50]!,
  );
  final voteColors = CommunityMenuColors(
    iconColor: Colors.teal[600]!,
    bgColor: Colors.teal[50]!,
  );

  return [
    CommunityMenuSectionItem(
      title: '나의 활동',
      categories: [
        CommunityMenuCategoryItem(
          title: '일반 게시판',
          items: [
            CommunityMenuItem(title: '내 글', icon: Icons.article_rounded, colors: boardColors),
            CommunityMenuItem(title: '내 댓글', icon: Icons.chat_bubble_rounded, colors: boardColors),
            CommunityMenuItem(title: '내 공감', icon: Icons.thumb_up_rounded, colors: boardColors),
            CommunityMenuItem(title: '내 공감 댓글', icon: Icons.favorite_rounded, colors: boardColors),
            CommunityMenuItem(title: '내 스크랩', icon: Icons.bookmark_rounded, colors: boardColors),
          ],
        ),
        CommunityMenuCategoryItem(
          title: '질문 게시판',
          items: [
            CommunityMenuItem(title: '내 질문', icon: Icons.help_rounded, colors: questionColors),
            CommunityMenuItem(title: '내 답변', icon: Icons.forum_rounded, colors: questionColors),
            CommunityMenuItem(
              title: '내 답변에 대한 댓글',
              icon: Icons.chat_rounded,
              colors: questionColors,
            ),
            CommunityMenuItem(title: '공감한 질문', icon: Icons.thumb_up_rounded, colors: questionColors),
            CommunityMenuItem(title: '공감한 답변', icon: Icons.favorite_rounded, colors: questionColors),
            CommunityMenuItem(title: '내 스크랩 질문', icon: Icons.bookmark_rounded, colors: questionColors),
          ],
        ),
        CommunityMenuCategoryItem(
          title: '투표 게시판',
          items: [
            CommunityMenuItem(title: '내 투표', icon: Icons.how_to_vote_rounded, colors: voteColors),
            CommunityMenuItem(title: '내 투표 댓글', icon: Icons.chat_rounded, colors: voteColors),
            CommunityMenuItem(title: '공감한 투표', icon: Icons.thumb_up_rounded, colors: voteColors),
            CommunityMenuItem(title: '공감한 투표 댓글', icon: Icons.favorite_rounded, colors: voteColors),
            CommunityMenuItem(title: '스크랩한 투표', icon: Icons.bookmark_rounded, colors: voteColors),
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
              colors: CommunityMenuColors(
                iconColor: Colors.purple[500]!,
                bgColor: Colors.purple[50]!,
              ),
            ),
            CommunityMenuItem(
              title: '차단 사용자 관리',
              icon: Icons.shield_rounded,
              colors: voteColors,
            ),
          ],
        ),
      ],
    ),
  ];
}
