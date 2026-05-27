import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:parrokit/core/router/app_routes.dart';
import 'package:provider/provider.dart';
import 'package:parrokit/data/models/post.dart';
import 'package:parrokit/features/community/providers/community_provider.dart';
import 'package:parrokit/core/provider/user_provider.dart';

class BoardScreen extends StatefulWidget {
  final String selectedFilter;

  const BoardScreen({super.key, required this.selectedFilter});

  @override
  State<BoardScreen> createState() => _BoardScreenState();
}

class _BoardScreenState extends State<BoardScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<CommunityProvider>().fetchPosts(postType: 'board', refresh: true);
    });
  }

  String _formatTimeAgo(DateTime? time) {
    if (time == null) return '';
    final diff = DateTime.now().difference(time);
    if (diff.inDays > 0) return '${diff.inDays}일 전';
    if (diff.inHours > 0) return '${diff.inHours}시간 전';
    if (diff.inMinutes > 0) return '${diff.inMinutes}분 전';
    return '방금 전';
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<CommunityProvider>();

    if (provider.isLoading && provider.posts.isEmpty) {
      return const Center(child: CircularProgressIndicator());
    }

    final filteredPosts = widget.selectedFilter == '전체'
        ? provider.posts
        : provider.posts
            .where((p) => p.category == widget.selectedFilter)
            .toList();

    if (filteredPosts.isEmpty) {
      return Center(
        child: Text(
          '등록된 게시글이 없습니다.',
          style: TextStyle(color: Colors.grey[600], fontSize: 16),
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: () =>
          context.read<CommunityProvider>().fetchPosts(postType: 'board', refresh: true),
      child: ListView.separated(
        padding: const EdgeInsets.only(bottom: 80), // Fab 여백
        itemCount: filteredPosts.length,
        separatorBuilder: (context, index) =>
            const Divider(color: Color(0xFFEEEEEE), height: 1),
        itemBuilder: (context, index) {
          return _buildPostItem(filteredPosts[index]);
        },
      ),
    );
  }

  Widget _buildPostItem(Post post) {
    final provider = context.watch<CommunityProvider>();
    final currentUser = context.watch<UserProvider>().currentUser;
    final isMe = currentUser != null && post.authorId == currentUser.id;
    
    return InkWell(
      onTap: () => context.push(AppRoutes.communityBoardViewPathOf(post.id)),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
              decoration: BoxDecoration(
                color: Colors.grey[100],
                borderRadius: BorderRadius.circular(4),
              ),
              child: Text(
                post.category,
                style: TextStyle(
                  fontSize: 11,
                  color: Colors.grey[700],
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              post.title,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w700,
                color: Colors.black,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              post.snippet,
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[600],
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  '${isMe ? (currentUser.displayName ?? post.authorNickname) : ((post.authorId != null ? provider.getCachedUser(post.authorId!)?.displayName : null) ?? post.authorNickname)} · ${_formatTimeAgo(post.createdAt)}',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey[500],
                  ),
                ),
                Row(
                  children: [
                    Icon(Icons.remove_red_eye,
                        size: 14, color: Colors.grey[400]),
                    const SizedBox(width: 4),
                    Text('${post.viewCount}',
                        style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey[500],
                            fontWeight: FontWeight.w600)),
                    const SizedBox(width: 12),
                    Icon(Icons.thumb_up, size: 14, color: Colors.grey[400]),
                    const SizedBox(width: 4),
                    Text('${post.likeCount}',
                        style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey[500],
                            fontWeight: FontWeight.w600)),
                    const SizedBox(width: 12),
                    Icon(Icons.chat_bubble, size: 14, color: Colors.grey[400]),
                    const SizedBox(width: 4),
                    Text('${post.commentCount}',
                        style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey[500],
                            fontWeight: FontWeight.w600)),
                  ],
                )
              ],
            )
          ],
        ),
      ),
    );
  }
}
