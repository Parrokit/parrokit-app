import 'dart:math';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:parrokit/core/router/app_routes.dart';

class QuestionScreen extends StatefulWidget {
  final String selectedFilter;

  const QuestionScreen({super.key, required this.selectedFilter});

  @override
  State<QuestionScreen> createState() => _QuestionScreenState();
}

class _QuestionScreenState extends State<QuestionScreen> {
  late List<_QuestionData> _allQuestions;

  @override
  void initState() {
    super.initState();
    _generateDummyQuestions();
  }

  void _generateDummyQuestions() {
    final random = Random();
    final nicknames = ['플러터초보', '다트마스터', '질문봇', '코딩하는고양이', '개발자지망생'];

    String getRandomNickname() => nicknames[random.nextInt(nicknames.length)];
    String getRandomTimeAgo() => '${random.nextInt(23) + 1}시간 전';

    _allQuestions = List.generate(10, (index) {
      final isResolved = random.nextBool();
      // Dummy image for Instagram feed style
      final hasImage = random.nextBool();
      final imageUrl = hasImage
          ? 'https://picsum.photos/seed/${random.nextInt(1000)}/400/300'
          : null;

      return _QuestionData(
        author: getRandomNickname(),
        timeAgo: getRandomTimeAgo(),
        title: '플러터 상태관리는 어떤 걸 쓰는 게 좋을까요? ($index)',
        content:
            '프로젝트를 새로 시작하려고 하는데 Provider, Riverpod, Bloc 중에 고민입니다. 현업에서는 주로 어떤 걸 많이 사용하시나요? 각각의 장단점이 궁금합니다.',
        imageUrl: imageUrl,
        likeCount: random.nextInt(100),
        commentCount: random.nextInt(30),
        isResolved: isResolved,
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    List<_QuestionData> filteredQuestions = _allQuestions;
    if (widget.selectedFilter == '채택 완료') {
      filteredQuestions = _allQuestions.where((q) => q.isResolved).toList();
    } else if (widget.selectedFilter == '답변 대기중') {
      filteredQuestions = _allQuestions.where((q) => !q.isResolved).toList();
    }

    if (filteredQuestions.isEmpty) {
      return Center(
        child: Text(
          '해당 조건의 질문이 없습니다.',
          style: TextStyle(color: Colors.grey[600], fontSize: 16),
        ),
      );
    }

    return ListView.separated(
      padding: const EdgeInsets.only(bottom: 80), // Fab space
      itemCount: filteredQuestions.length,
      separatorBuilder: (context, index) => const Divider(
        color: Color(0xFFEEEEEE),
        thickness: 8,
      ),
      itemBuilder: (context, index) {
        return GestureDetector(
          onTap: () {
            context.push(AppRoutes.communityQuestionViewPathOf(index));
          },
          behavior: HitTestBehavior.opaque,
          child: _buildFeedItem(filteredQuestions[index]),
        );
      },
    );
  }

  Widget _buildFeedItem(_QuestionData question) {
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
                  child: const Icon(Icons.person, color: Colors.white),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        question.author,
                        style: const TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        question.timeAgo,
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey[500],
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: question.isResolved
                        ? Colors.grey[200]
                        : Colors.blue[50],
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    question.isResolved ? '채택 완료' : '답변 대기중',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: question.isResolved
                          ? Colors.grey[600]
                          : Colors.blue[600],
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
              question.content,
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
          if (question.imageUrl != null)
            Container(
              width: double.infinity,
              height: 250,
              color: Colors.grey[200],
              margin: const EdgeInsets.only(bottom: 12),
              child: Image.network(
                question.imageUrl!,
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
                const Icon(Icons.favorite_border,
                    size: 24, color: Colors.black87),
                const SizedBox(width: 6),
                Text(
                  '${question.likeCount}',
                  style: const TextStyle(
                      fontSize: 14, fontWeight: FontWeight.w600),
                ),
                const SizedBox(width: 16),
                const Icon(Icons.chat_bubble_outline,
                    size: 22, color: Colors.black87),
                const SizedBox(width: 6),
                Text(
                  '${question.commentCount}',
                  style: const TextStyle(
                      fontSize: 14, fontWeight: FontWeight.w600),
                ),
                const Spacer(),
                const Icon(Icons.bookmark_border,
                    size: 24, color: Colors.black87),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _QuestionData {
  final String author;
  final String timeAgo;
  final String title;
  final String content;
  final String? imageUrl;
  final int likeCount;
  final int commentCount;
  final bool isResolved;

  _QuestionData({
    required this.author,
    required this.timeAgo,
    required this.title,
    required this.content,
    this.imageUrl,
    required this.likeCount,
    required this.commentCount,
    required this.isResolved,
  });
}
