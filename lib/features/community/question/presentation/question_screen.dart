import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:parrokit/core/router/app_routes.dart';
import 'package:provider/provider.dart';
import 'package:parrokit/data/models/post.dart';
import 'package:parrokit/features/community/shell/presentation/providers/community_provider.dart';
import 'package:parrokit/core/provider/user_provider.dart';
import 'package:parrokit/features/community/shell/presentation/utils/community_post_ui_utils.dart';
import 'package:parrokit/core/theme/app_colors.dart';

class QuestionScreen extends StatefulWidget {
  final String selectedFilter;

  const QuestionScreen({super.key, required this.selectedFilter});

  @override
  State<QuestionScreen> createState() => _QuestionScreenState();
}

class _QuestionScreenState extends State<QuestionScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<CommunityProvider>().fetchPosts(postType: 'question', refresh: true);
    });
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<CommunityProvider>();

    if (provider.isLoading && provider.posts.isEmpty) {
      return const Center(child: CircularProgressIndicator());
    }

    // 1. postType이 'question'인 것만 먼저 필터링
    var questionPosts = provider.posts.where((p) => p.postType == 'question').toList();

    // 2. 선택된 탭(필터)에 따라 한 번 더 필터링
    if (widget.selectedFilter == '채택 완료') {
      questionPosts = questionPosts.where((p) => p.questionStatus == 'resolved').toList();
    } else if (widget.selectedFilter == '답변 대기중') {
      // 대기중이거나 만료된 것도 아직 채택 안 된 상태이므로 묶어서 보여주거나 필터링 가능. 일단 'waiting' 상태만
      questionPosts = questionPosts.where((p) => p.questionStatus == 'waiting').toList();
    }

    if (questionPosts.isEmpty) {
      return Center(
        child: Text(
          '해당 조건의 질문이 없습니다.',
          style: TextStyle(color: Colors.grey[600], fontSize: 16),
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: () => context.read<CommunityProvider>().fetchPosts(postType: 'question', refresh: true),
      child: ListView.separated(
        padding: const EdgeInsets.only(bottom: 80), // Fab space
        itemCount: questionPosts.length,
        separatorBuilder: (context, index) => const Divider(
          color: AppColors.disabled,
          thickness: 8,
        ),
        itemBuilder: (context, index) {
          return GestureDetector(
            onTap: () {
              context.push(AppRoutes.communityQuestionViewPathOf(questionPosts[index].id));
            },
            behavior: HitTestBehavior.opaque,
            child: _buildFeedItem(questionPosts[index], provider),
          );
        },
      ),
    );
  }

  Widget _buildFeedItem(Post question, CommunityProvider provider) {
    final userProvider = context.watch<UserProvider>();
    final authorName = resolveCommunityAuthorName(
      post: question,
      provider: provider,
      userProvider: userProvider,
    );
    final avatarUrl = resolveCommunityAuthorAvatarUrl(
      post: question,
      provider: provider,
      userProvider: userProvider,
    );

    final isResolved = question.questionStatus == 'resolved';
    final isExpired = question.questionStatus == 'expired';

    String statusText = '답변 대기중';
    Color statusColor = Colors.blue[600]!;
    Color statusBgColor = Colors.blue[50]!;

    if (isResolved) {
      statusText = '채택 완료';
      statusColor = Colors.grey[600]!;
      statusBgColor = Colors.grey[200]!;
    } else if (isExpired) {
      statusText = '만료됨';
      statusColor = Colors.red[600]!;
      statusBgColor = Colors.red[50]!;
    }

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header: Avatar + Author + Time + Status
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Row(
              children: [
                CircleAvatar(
                  radius: 18,
                  backgroundColor: Colors.grey[300],
                  backgroundImage: avatarUrl != null ? NetworkImage(avatarUrl) : null,
                  child: avatarUrl == null ? const Icon(Icons.person, color: Colors.white) : null,
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Flexible(
                            child: Text(
                              authorName,
                              style: const TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.bold,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          const SizedBox(width: 8),
                          // 크래커 보상 뱃지
                          if (question.rewardCrackers > 0)
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                              decoration: BoxDecoration(
                                color: Colors.orange[50],
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(color: Colors.orange[200]!),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  const Text('🍪', style: TextStyle(fontSize: 10)),
                                  const SizedBox(width: 2),
                                  Text(
                                    '${question.rewardCrackers}',
                                    style: TextStyle(
                                      fontSize: 11,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.orange[800],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                        ],
                      ),
                      Text(
                        formatCommunityTimeAgo(question.createdAt),
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey[500],
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: statusBgColor,
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    statusText,
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: statusColor,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                const Icon(Icons.more_vert, color: Colors.grey),
              ],
            ),
          ),
          const SizedBox(height: 12),

          // Title & Content
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Text(
              question.title,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          const SizedBox(height: 6),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Text(
              question.snippet,
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[800],
              ),
              maxLines: 3,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          const SizedBox(height: 12),

          // Image Placeholder
          if (question.hasImage && question.imageUrls.isNotEmpty)
            Container(
              width: double.infinity,
              height: 250,
              color: Colors.grey[200],
              margin: const EdgeInsets.only(bottom: 12),
              child: Image.network(
                question.imageUrls.first,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) =>
                    const Icon(Icons.image_not_supported, color: Colors.grey),
              ),
            ),

          // Actions Row
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Row(
              children: [
                const Icon(Icons.favorite_border, size: 24, color: Colors.black87),
                const SizedBox(width: 6),
                Text(
                  '${question.likeCount}',
                  style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
                ),
                const SizedBox(width: 16),
                const Icon(Icons.chat_bubble_outline, size: 22, color: Colors.black87),
                const SizedBox(width: 6),
                Text(
                  '${question.commentCount}',
                  style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
                ),
                const Spacer(),
                const Icon(Icons.bookmark_border, size: 24, color: Colors.black87),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
