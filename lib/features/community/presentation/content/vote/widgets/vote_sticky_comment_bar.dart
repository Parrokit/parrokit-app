import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:parrokit/core/provider/user_provider.dart';
import 'package:parrokit/features/community/providers/community_provider.dart';
import 'package:provider/provider.dart';

class VoteStickyCommentBar extends StatelessWidget {
  const VoteStickyCommentBar({
    super.key,
    required this.commentController,
    required this.commentFocusNode,
    required this.canSubmit,
    required this.onChanged,
    required this.onSubmit,
  });

  final TextEditingController commentController;
  final FocusNode commentFocusNode;
  final bool canSubmit;
  final ValueChanged<String> onChanged;
  final VoidCallback onSubmit;

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<CommunityProvider>();
    final currentUser = context.watch<UserProvider>().currentUser;

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (provider.replyingTo != null)
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            color: const Color(0xFFF8F9FA),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    '${provider.replyingTo?.authorNickname} 님에게 답글 남기는 중',
                    style: const TextStyle(fontSize: 13, color: Color(0xFF495057)),
                  ),
                ),
                GestureDetector(
                  onTap: () => provider.setReplyingTo(null),
                  child: const Icon(Icons.close, size: 16, color: Color(0xFF868E96)),
                ),
              ],
            ),
          ),
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.05),
                blurRadius: 10,
                offset: const Offset(0, -4),
              ),
            ],
            border: const Border(top: BorderSide(color: Color(0xFFE9ECEF), width: 1)),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
          child: SafeArea(
            child: Row(
              children: [
                CircleAvatar(
                  radius: 16,
                  backgroundColor: const Color(0xFFF1F3F5),
                  backgroundImage: (currentUser?.photoUrl != null && currentUser!.photoUrl!.isNotEmpty)
                      ? CachedNetworkImageProvider(currentUser.photoUrl!)
                      : null,
                  child: (currentUser?.photoUrl == null || currentUser!.photoUrl!.isEmpty)
                      ? const Icon(Icons.person, color: Color(0xFF9E9E9E), size: 18)
                      : null,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.grey[100],
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: Colors.white, width: 1),
                    ),
                    padding: const EdgeInsets.symmetric(horizontal: 16.0),
                    child: TextField(
                      controller: commentController,
                      focusNode: commentFocusNode,
                      onChanged: onChanged,
                      onSubmitted: (_) => onSubmit(),
                      decoration: const InputDecoration(
                        hintText: '투표 의견 남기기...',
                        border: InputBorder.none,
                        focusedBorder: InputBorder.none,
                        enabledBorder: InputBorder.none,
                        isDense: true,
                        contentPadding: EdgeInsets.symmetric(vertical: 8.0),
                      ),
                      style: const TextStyle(fontSize: 14),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                IconButton(
                  icon: Icon(
                    Icons.send_rounded,
                    color: canSubmit ? Colors.blue[600] : Colors.grey[400],
                    size: 22,
                  ),
                  onPressed: canSubmit ? onSubmit : null,
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
