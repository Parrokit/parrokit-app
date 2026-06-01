import 'package:flutter/material.dart';

import 'community_menu_constants.dart';
import 'community_menu_item.dart';

CommunityMenuItem buildActivityMenuItem({
  required String title,
  required IconData icon,
  required CommunityMenuColors colors,
  required String boardType,
  required String activityType,
}) {
  return buildMenuItem(
    title: title,
    icon: icon,
    colors: colors,
    boardType: boardType,
    activityType: activityType,
  );
}

CommunityMenuItem buildMenuItem({
  required String title,
  required IconData icon,
  required CommunityMenuColors colors,
  String? boardType,
  String? activityType,
}) {
  return CommunityMenuItem(
    title: title,
    icon: icon,
    colors: colors,
    boardType: boardType,
    activityType: activityType,
  );
}

List<CommunityMenuItem> buildBoardItems(CommunityMenuColors colors) {
  return [
    buildActivityMenuItem(title: '작성한 글', icon: Icons.article_rounded, colors: colors, boardType: communityBoardTypeBoard, activityType: communityActivityWritten),
    buildActivityMenuItem(title: '작성한 댓글', icon: Icons.chat_bubble_rounded, colors: colors, boardType: communityBoardTypeBoard, activityType: communityActivityCommented),
    buildActivityMenuItem(title: '공감한 글', icon: Icons.thumb_up_rounded, colors: colors, boardType: communityBoardTypeBoard, activityType: communityActivityLiked),
    buildActivityMenuItem(title: '공감한 댓글', icon: Icons.favorite_rounded, colors: colors, boardType: communityBoardTypeBoard, activityType: communityActivityLikedComment),
    buildActivityMenuItem(title: '스크랩', icon: Icons.bookmark_rounded, colors: colors, boardType: communityBoardTypeBoard, activityType: communityActivityScraped),
  ];
}

List<CommunityMenuItem> buildQuestionItems(CommunityMenuColors colors) {
  return [
    buildActivityMenuItem(title: '작성한 질문', icon: Icons.help_rounded, colors: colors, boardType: communityBoardTypeQuestion, activityType: communityActivityWritten),
    buildActivityMenuItem(title: '작성한 답변', icon: Icons.forum_rounded, colors: colors, boardType: communityBoardTypeQuestion, activityType: communityActivityCommented),
    buildActivityMenuItem(title: '답변에 달린 댓글', icon: Icons.chat_rounded, colors: colors, boardType: communityBoardTypeQuestion, activityType: communityActivityCommentedReply),
    buildActivityMenuItem(title: '공감한 질문', icon: Icons.thumb_up_rounded, colors: colors, boardType: communityBoardTypeQuestion, activityType: communityActivityLiked),
    buildActivityMenuItem(title: '공감한 답변 및 댓글', icon: Icons.favorite_rounded, colors: colors, boardType: communityBoardTypeQuestion, activityType: communityActivityLikedComment),
    buildActivityMenuItem(title: '스크랩', icon: Icons.bookmark_rounded, colors: colors, boardType: communityBoardTypeQuestion, activityType: communityActivityScraped),
  ];
}

List<CommunityMenuItem> buildVoteItems(CommunityMenuColors colors) {
  return [
    buildActivityMenuItem(title: '참여한 투표', icon: Icons.how_to_vote_rounded, colors: colors, boardType: communityBoardTypeVote, activityType: communityActivityWritten),
    buildActivityMenuItem(title: '게시한 투표', icon: Icons.campaign_rounded, colors: colors, boardType: communityBoardTypeVote, activityType: communityActivityWrittenPosted),
    buildActivityMenuItem(title: '작성한 댓글', icon: Icons.chat_rounded, colors: colors, boardType: communityBoardTypeVote, activityType: communityActivityCommented),
    buildActivityMenuItem(title: '공감한 투표', icon: Icons.thumb_up_rounded, colors: colors, boardType: communityBoardTypeVote, activityType: communityActivityLiked),
    buildActivityMenuItem(title: '공감한 댓글', icon: Icons.favorite_rounded, colors: colors, boardType: communityBoardTypeVote, activityType: communityActivityLikedComment),
    buildActivityMenuItem(title: '스크랩', icon: Icons.bookmark_rounded, colors: colors, boardType: communityBoardTypeVote, activityType: communityActivityScraped),
  ];
}
