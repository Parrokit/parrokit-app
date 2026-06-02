import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:parrokit/core/router/app_routes.dart';
import 'package:parrokit/core/theme/app_colors.dart';
import 'package:parrokit/core/provider/user_provider.dart';
import 'providers/activity_provider.dart';
import 'widgets/activity_card.dart';

class CommunityActivityScreen extends StatelessWidget {
  const CommunityActivityScreen({
    super.key,
    required this.boardType,
    required this.activityType,
    this.activityProviderFactory,
  });

  final String boardType;
  final String activityType;
  final ActivityProvider Function()? activityProviderFactory;

  String _getAppBarTitle() {
    String boardName = '';
    switch (boardType) {
      case 'board':
        boardName = '일반 게시판';
        break;
      case 'question':
        boardName = '질문 게시판';
        break;
      case 'vote':
        boardName = '투표 게시판';
        break;
      default:
        boardName = '알 수 없음';
    }

    String activityName = '';
    switch (activityType) {
      case 'written':
        activityName = '작성한 글';
        break;
      case 'written_posted':
        activityName = '게시한 투표';
        break;
      case 'commented':
        activityName = '작성한 댓글';
        break;
      case 'liked':
        activityName = '공감한 글';
        break;
      case 'liked_comment':
        activityName = '공감한 댓글';
        break;
      case 'scraped':
        activityName = '스크랩';
        break;
      default:
        activityName = '활동';
    }

    // 투표 등 특정 조합에 대한 특별 처리
    if (boardType == 'vote' && activityType == 'written') {
      activityName = '참여한 투표';
    }
    if (boardType == 'question' && activityType == 'written') {
      activityName = '작성한 질문/답변';
    }

    return '$boardName - $activityName';
  }

  String _getTotalCountLabel(int count) {
    String typeLabel = '';
    switch (activityType) {
      case 'written':
      case 'written_posted':
        typeLabel = '글';
        if (boardType == 'vote') typeLabel = '투표';
        if (boardType == 'question') typeLabel = '질문/답변';
        break;
      case 'commented':
      case 'commented_reply':
        typeLabel = '댓글';
        break;
      case 'liked':
      case 'liked_comment':
        typeLabel = '공감';
        break;
      case 'scraped':
        typeLabel = '스크랩';
        break;
      default:
        typeLabel = '활동';
    }
    return '총 $typeLabel $count개';
  }

  String? _resolveDetailPath(String boardType, String postId) {
    if (postId.isEmpty) return null;
    switch (boardType) {
      case 'question':
        return AppRoutes.communityQuestionViewPathOf(postId);
      case 'vote':
        return AppRoutes.communityVoteViewPathOf(postId);
      case 'board':
      default:
        return AppRoutes.communityBoardViewPathOf(postId);
    }
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final userProvider = Provider.of<UserProvider>(context, listen: false);
    final userId = userProvider.currentUser?.id ?? '';

    return ChangeNotifierProvider(
      create: (context) =>
          (activityProviderFactory?.call() ?? ActivityProvider())
            ..fetchActivities(
              userId: userId,
              boardType: boardType,
              activityType: activityType,
            ),
      child: Scaffold(
        appBar: AppBar(
          title: Text(
            _getAppBarTitle(),
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          centerTitle: true,
        ),
        body: Consumer<ActivityProvider>(
          builder: (context, provider, child) {
            if (provider.isLoading && provider.activities.isEmpty) {
              return const Center(child: CircularProgressIndicator());
            }

            if (provider.error != null) {
              return Center(
                child: Text('오류가 발생했습니다: ${provider.error}',
                    style: TextStyle(color: colorScheme.error)),
              );
            }

            if (provider.activities.isEmpty) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.inbox_rounded,
                        size: 64, color: AppColors.textDisabled),
                    const SizedBox(height: 16),
                    Text(
                      '아직 활동 내역이 없습니다.',
                      style: TextStyle(
                          fontSize: 16, color: colorScheme.onSurfaceVariant),
                    ),
                  ],
                ),
              );
            }

            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: double.infinity,
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  decoration: BoxDecoration(
                    color: colorScheme.surface,
                    border: Border(
                      bottom: BorderSide(color: colorScheme.outlineVariant),
                    ),
                  ),
                  child: Text(
                    _getTotalCountLabel(provider.activities.length),
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: colorScheme.onSurfaceVariant,
                    ),
                  ),
                ),
                Expanded(
                  child: ListView.builder(
                    padding: EdgeInsets.zero,
                    itemCount: provider.activities.length,
                    itemBuilder: (context, index) {
                      final item = provider.activities[index];
                      return ActivityCard(
                        item: item,
                        onTap: () {
                          final path = _resolveDetailPath(
                            item.boardType,
                            item.sourcePostId,
                          );
                          if (path == null) return;
                          context.push(path);
                        },
                      );
                    },
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}
