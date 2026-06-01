import 'package:flutter/material.dart';
import 'package:parrokit/core/provider/user_provider.dart';
import 'package:parrokit/features/community/shell/presentation/providers/community_provider.dart';
import 'package:provider/provider.dart';
import 'package:parrokit/core/theme/app_colors.dart';

class QuestionStickyReplyBar extends StatelessWidget {
  const QuestionStickyReplyBar({
    super.key,
    required this.replyController,
    required this.replyFocusNode,
    required this.onSubmitReply,
  });

  final TextEditingController replyController;
  final FocusNode replyFocusNode;
  final VoidCallback onSubmitReply;

  @override
  Widget build(BuildContext context) {
    final currentUser = context.watch<UserProvider>().currentUser;
    final provider = context.watch<CommunityProvider>();

    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(top: BorderSide(color: AppColors.commF1F3F5)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (provider.replyingTo != null)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              color: AppColors.commF8F9FA,
              child: Row(
                children: [
                  Text(
                    '${provider.replyingTo!.authorNickname}님에게 답글 남기는 중',
                    style: TextStyle(
                      fontSize: 13,
                      color: Colors.grey[600],
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const Spacer(),
                  GestureDetector(
                    onTap: () => provider.setReplyingTo(null),
                    child: const Icon(Icons.close, size: 16, color: AppColors.commADB5BD),
                  ),
                ],
              ),
            ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
            child: SafeArea(
              top: false,
              child: Row(
                children: [
                  CircleAvatar(
                    radius: 14,
                    backgroundColor: AppColors.commF1F3F5,
                    backgroundImage: currentUser?.photoUrl != null
                        ? NetworkImage(currentUser!.photoUrl!)
                        : null,
                    child: currentUser?.photoUrl == null
                        ? const Icon(Icons.person, size: 14, color: Colors.grey)
                        : null,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: TextField(
                      controller: replyController,
                      focusNode: replyFocusNode,
                      decoration: const InputDecoration(
                        hintText: '답글 남기기...',
                        hintStyle: TextStyle(fontSize: 14, color: AppColors.commADB5BD),
                        border: InputBorder.none,
                      ),
                      style: const TextStyle(fontSize: 14),
                    ),
                  ),
                  TextButton(
                    onPressed: onSubmitReply,
                    child: Text(
                      '답글',
                      style: TextStyle(
                        color: Colors.orange[600],
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
