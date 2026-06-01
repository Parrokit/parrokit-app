import 'package:flutter/material.dart';
import 'package:parrokit/data/models/post.dart';
import 'package:parrokit/features/community/board/widgets/board_sheet_action.dart';

class BoardOptionsHandler {
  static Future<void> showCommentOptionsSheet({
    required BuildContext context,
    required bool isMyComment,
    required Future<bool> Function() onDelete,
  }) async {
    await showModalBottomSheet<void>(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (sheetContext) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (isMyComment)
                  BoardSheetAction(
                    label: '삭제',
                    isDestructive: true,
                    onTap: () async {
                      Navigator.pop(sheetContext);
                      final deleted = await onDelete();
                      if (!context.mounted) return;
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text(deleted ? '댓글이 삭제되었습니다.' : '삭제에 실패했습니다.')),
                      );
                    },
                  ),
                if (!isMyComment)
                  BoardSheetAction(
                    label: '신고',
                    onTap: () {
                      Navigator.pop(sheetContext);
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('신고가 접수되었습니다.')),
                      );
                    },
                  ),
                BoardSheetAction(label: '닫기', onTap: () => Navigator.pop(sheetContext)),
              ],
            ),
          ),
        );
      },
    );
  }

  static Future<void> showPostOptionsSheet({
    required BuildContext context,
    required Post post,
    required bool isMyPost,
    required VoidCallback onEdit,
    required Future<bool> Function() onDelete,
  }) async {
    await showModalBottomSheet<void>(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (sheetContext) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (isMyPost) ...[
                  BoardSheetAction(
                    label: '수정',
                    onTap: () {
                      Navigator.pop(sheetContext);
                      onEdit();
                    },
                  ),
                  BoardSheetAction(
                    label: '삭제',
                    isDestructive: true,
                    onTap: () async {
                      Navigator.pop(sheetContext);
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
                ],
                BoardSheetAction(
                  label: '신고',
                  onTap: () {
                    Navigator.pop(sheetContext);
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('신고가 접수되었습니다.')),
                    );
                  },
                ),
                BoardSheetAction(label: '닫기', onTap: () => Navigator.pop(sheetContext)),
              ],
            ),
          ),
        );
      },
    );
  }
}
