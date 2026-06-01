import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:parrokit/data/models/comment.dart';
import 'package:parrokit/data/models/user.dart';
import 'package:shimmer/shimmer.dart';

class BoardCommentItem extends StatelessWidget {
  const BoardCommentItem({
    super.key,
    required this.comment,
    required this.isReply,
    required this.isAuthor,
    required this.isMyComment,
    required this.isLiked,
    required this.currentUser,
    required this.cachedUser,
    required this.onLike,
    required this.onReply,
    required this.onMore,
    required this.formatTimeAgo,
  });

  final Comment comment;
  final bool isReply;
  final bool isAuthor;
  final bool isMyComment;
  final bool isLiked;
  final AppUser? currentUser;
  final AppUser? cachedUser;
  final VoidCallback onLike;
  final VoidCallback onReply;
  final VoidCallback onMore;
  final String Function(DateTime?) formatTimeAgo;

  @override
  Widget build(BuildContext context) {
    final isDeleted = comment.status == 'deleted';
    final photoUrl = (isMyComment ? currentUser?.photoUrl : cachedUser?.photoUrl) ?? comment.authorAvatarUrl;
    final displayName = (isMyComment ? currentUser?.displayName : cachedUser?.displayName) ?? comment.authorNickname;

    return Container(
      padding: EdgeInsets.fromLTRB(isReply ? 52 : 18, 18, 18, 0),
      decoration: isReply
          ? const BoxDecoration(
              border: Border(left: BorderSide(color: Color(0xFFEFEFEF), width: 3)),
            )
          : null,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: isReply ? 36 : 44,
            height: isReply ? 36 : 44,
            decoration: const BoxDecoration(shape: BoxShape.circle, color: Color(0xFFE5E5E5)),
            child: ClipOval(
              child: (photoUrl != null && photoUrl.isNotEmpty && !isDeleted)
                  ? CachedNetworkImage(
                      imageUrl: photoUrl,
                      fit: BoxFit.cover,
                      placeholder: (context, url) => Shimmer.fromColors(
                        baseColor: Colors.grey[300]!,
                        highlightColor: Colors.grey[100]!,
                        child: Container(color: Colors.white),
                      ),
                      errorWidget: (context, url, error) => Center(
                        child: Icon(Icons.person, size: isReply ? 20 : 26, color: const Color(0xFF9E9E9E)),
                      ),
                    )
                  : Center(
                      child: isDeleted ? const SizedBox() : Icon(Icons.person, size: isReply ? 20 : 26, color: const Color(0xFF9E9E9E)),
                    ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      isDeleted ? '(삭제됨)' : displayName,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w800,
                        color: isDeleted ? const Color(0xFFB0B0B0) : const Color(0xFF1F1F1F),
                      ),
                    ),
                    if (!isDeleted && isAuthor) ...[
                      const SizedBox(width: 6),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(color: const Color(0xFFE6F0FF), borderRadius: BorderRadius.circular(4)),
                        child: const Text('작성자', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: Color(0xFF3F72C4))),
                      ),
                    ],
                    if (!isDeleted && isMyComment && !isAuthor) ...[
                      const SizedBox(width: 6),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(color: const Color(0xFFF0F0F0), borderRadius: BorderRadius.circular(4)),
                        child: const Text('내 댓글', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: Color(0xFF7A7A7A))),
                      ),
                    ],
                  ],
                ),
                const SizedBox(height: 2),
                if (!isDeleted)
                  Text(
                    formatTimeAgo(comment.createdAt),
                    style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: Color(0xFF8F96A3)),
                  ),
                const SizedBox(height: 8),
                if (!isDeleted && isReply && comment.replyToNickname != null)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 4),
                    child: Text(
                      '@${comment.replyToNickname}',
                      style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: Color(0xFF3F72C4)),
                    ),
                  ),
                Text(
                  comment.content,
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w500,
                    color: isDeleted ? const Color(0xFFB0B0B0) : const Color(0xFF232323),
                    height: 1.35,
                  ),
                ),
                const SizedBox(height: 10),
                if (!isDeleted)
                  Row(
                    children: [
                      GestureDetector(
                        onTap: onLike,
                        child: Row(
                          children: [
                            Icon(isLiked ? Icons.favorite : Icons.favorite_border, size: 18, color: isLiked ? Colors.redAccent : const Color(0xFF8F96A3)),
                            const SizedBox(width: 4),
                            Text(
                              comment.likeCount > 0 ? '${comment.likeCount}' : '좋아요',
                              style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: isLiked ? Colors.redAccent : const Color(0xFF8F96A3)),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 20),
                      GestureDetector(
                        onTap: onReply,
                        child: const Row(
                          children: [
                            Icon(Icons.chat_bubble_outline, size: 16, color: Color(0xFF8F96A3)),
                            SizedBox(width: 4),
                            Text('답글쓰기', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: Color(0xFF8F96A3))),
                          ],
                        ),
                      ),
                    ],
                  ),
              ],
            ),
          ),
          if (!isDeleted)
            IconButton(
              onPressed: onMore,
              icon: const Icon(Icons.more_vert, color: Color(0xFF8F96A3), size: 20),
            )
          else
            const SizedBox(width: 48),
        ],
      ),
    );
  }
}
