import 'package:flutter/material.dart';
import 'package:parrokit/data/models/post.dart';
import 'package:parrokit/features/community/shared/presentation/widgets/community_options_sheet.dart';

class BoardOptionsHandler {
  static Future<void> showCommentOptionsSheet({
    required BuildContext context,
    required bool isMyComment,
    required Future<bool> Function() onDelete,
  }) async {
    await showCommunityOptionsSheet(
      context: context,
      title: '댓글 옵션',
      actions: [
        if (isMyComment)
          CommunityOptionAction(
            label: '삭제',
            icon: Icons.delete_outline_rounded,
            isDestructive: true,
            onTap: () async {
              final deleted = await onDelete();
              if (!context.mounted) return;
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text(deleted ? '댓글이 삭제되었습니다.' : '삭제에 실패했습니다.')),
              );
            },
          ),
        if (!isMyComment)
          CommunityOptionAction(
            label: '신고',
            icon: Icons.report_outlined,
            onTap: () async {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('신고가 접수되었습니다.')),
              );
            },
          ),
      ],
    );
  }

  static Future<void> showPostOptionsSheet({
    required BuildContext context,
    required Post post,
    required bool isMyPost,
    required VoidCallback onEdit,
    required Future<bool> Function() onDelete,
  }) async {
    await showCommunityOptionsSheet(
      context: context,
      title: '글 옵션',
      actions: [
        if (isMyPost)
          CommunityOptionAction(
            label: '수정',
            icon: Icons.edit_outlined,
            onTap: () async {
              onEdit();
            },
          ),
        if (isMyPost)
          CommunityOptionAction(
            label: '삭제',
            icon: Icons.delete_outline_rounded,
            isDestructive: true,
            onTap: () async {
              final deleted = await onDelete();
              if (!context.mounted) return;
              if (deleted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('게시글이 삭제되었습니다.')),
                );
                Navigator.maybePop(context);
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('삭제에 실패했습니다.')),
                );
                }
              },
          ),
        if (!isMyPost)
          CommunityOptionAction(
            label: '신고',
            icon: Icons.report_outlined,
            onTap: () async {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('신고가 접수되었습니다.')),
              );
            },
          ),
      ],
    );
  }
}
