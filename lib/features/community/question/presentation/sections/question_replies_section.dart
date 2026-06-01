import 'package:flutter/material.dart';
import 'package:parrokit/core/provider/user_provider.dart';
import 'package:parrokit/data/models/comment.dart';
import 'package:parrokit/data/models/post.dart';
import 'package:parrokit/features/community/shell/presentation/providers/community_provider.dart';
import 'package:provider/provider.dart';

class QuestionRepliesSection extends StatelessWidget {
  const QuestionRepliesSection({
    super.key,
    required this.question,
    required this.answers,
    required this.onAcceptAnswer,
    required this.onFocusReplyInput,
    required this.formatTimeAgo,
  });

  final Post question;
  final List<Comment> answers;
  final void Function(Comment answer) onAcceptAnswer;
  final VoidCallback onFocusReplyInput;
  final String Function(DateTime?) formatTimeAgo;

  @override
  Widget build(BuildContext context) {
    if (answers.isEmpty) {
      return const Padding(
        padding: EdgeInsets.symmetric(vertical: 40),
        child: Center(
          child: Text(
            '아직 답변이 없습니다.\n첫 번째 답변을 남겨보세요!',
            textAlign: TextAlign.center,
            style: TextStyle(color: Color(0xFFADB5BD), fontSize: 14),
          ),
        ),
      );
    }

    final parentAnswers = answers.where((c) => c.parentId == null).toList();
    final childAnswers = answers.where((c) => c.parentId != null).toList();
    parentAnswers.sort((a, b) => (b.isAccepted ? 1 : 0).compareTo(a.isAccepted ? 1 : 0));

    final widgets = <Widget>[];
    for (var i = 0; i < parentAnswers.length; i++) {
      final parent = parentAnswers[i];
      widgets.add(_buildReplyItem(context, parent, isReply: false));

      final children = childAnswers.where((c) => c.parentId == parent.id).toList();
      for (final child in children) {
        widgets.add(_buildReplyItem(context, child, isReply: true));
      }

      if (i < parentAnswers.length - 1 || children.isNotEmpty) {
        widgets.add(const Divider(height: 1, color: Color(0xFFF1F3F5)));
      }
    }

    return Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: widgets);
  }

  Widget _buildReplyItem(BuildContext context, Comment answer, {required bool isReply}) {
    final currentUser = context.read<UserProvider>().currentUser;
    final isMe = currentUser != null && question.authorId == currentUser.id;
    final provider = context.read<CommunityProvider>();

    final answererName = (answer.authorId == currentUser?.id)
        ? (currentUser?.displayName ?? answer.authorNickname)
        : (provider.getCachedUser(answer.authorId)?.displayName ?? answer.authorNickname);

    final answererAvatar = (answer.authorId == currentUser?.id)
        ? (currentUser?.photoUrl ?? answer.authorAvatarUrl)
        : (provider.getCachedUser(answer.authorId)?.photoUrl ?? answer.authorAvatarUrl);

    return Container(
      padding: EdgeInsets.fromLTRB(isReply ? 46 : 16, 16, 16, 16),
      decoration: isReply
          ? const BoxDecoration(border: Border(left: BorderSide(color: Color(0xFFEFEFEF), width: 3)))
          : null,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Column(
            children: [
              CircleAvatar(
                radius: isReply ? 14 : 18,
                backgroundColor: const Color(0xFFF1F3F5),
                backgroundImage: answererAvatar != null ? NetworkImage(answererAvatar) : null,
                child: answererAvatar == null
                    ? Icon(Icons.person, size: isReply ? 14 : 18, color: Colors.white)
                    : null,
              ),
              if (!isReply) Container(width: 2, height: 40, color: const Color(0xFFE9ECEF)),
            ],
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(answererName, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: Color(0xFF212529))),
                    const Spacer(),
                    Text(formatTimeAgo(answer.createdAt), style: TextStyle(color: Colors.grey[400], fontSize: 12)),
                  ],
                ),
                const SizedBox(height: 4),
                if (answer.isAccepted) ...[
                  Container(
                    margin: const EdgeInsets.symmetric(vertical: 4),
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                    decoration: BoxDecoration(
                      color: Colors.green[50],
                      borderRadius: BorderRadius.circular(6),
                      border: Border.all(color: Colors.green[200]!),
                    ),
                    child: const Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.verified, color: Colors.green, size: 12),
                        SizedBox(width: 4),
                        Text('채택된 답변', style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.green)),
                      ],
                    ),
                  ),
                  const SizedBox(height: 4),
                ],
                if (isReply && answer.replyToNickname != null)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 4),
                    child: Text(
                      '@${answer.replyToNickname}',
                      style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: Color(0xFF3F72C4)),
                    ),
                  ),
                Text(answer.content, style: const TextStyle(fontSize: 15, color: Color(0xFF343A40), height: 1.45)),
                const SizedBox(height: 12),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        IconButton(
                          icon: Icon(
                            provider.likedCommentIds.contains(answer.id) ? Icons.bolt : Icons.bolt_outlined,
                            size: 18,
                            color: provider.likedCommentIds.contains(answer.id) ? Colors.orange[600] : const Color(0xFF65676B),
                          ),
                          onPressed: () {
                            if (currentUser != null) {
                              provider.toggleCommentLike(question.id, answer.id, currentUser.id);
                            } else {
                              ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('로그인이 필요합니다.')));
                            }
                          },
                          padding: EdgeInsets.zero,
                          constraints: const BoxConstraints(),
                        ),
                        const SizedBox(width: 4),
                        Text('${answer.likeCount}', style: TextStyle(color: Colors.grey[500], fontSize: 12)),
                        const SizedBox(width: 12),
                        IconButton(
                          icon: const Icon(Icons.mode_comment_outlined, size: 18, color: Color(0xFF65676B)),
                          onPressed: () {
                            provider.setReplyingTo(answer);
                            onFocusReplyInput();
                          },
                          padding: EdgeInsets.zero,
                          constraints: const BoxConstraints(),
                        ),
                      ],
                    ),
                    if (!isReply && isMe && question.questionStatus == 'waiting' && answer.authorId != currentUser?.id)
                      GestureDetector(
                        onTap: () => onAcceptAnswer(answer),
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                          decoration: BoxDecoration(color: Colors.green[50], borderRadius: BorderRadius.circular(6)),
                          child: const Text('채택하기', style: TextStyle(color: Colors.green, fontSize: 12, fontWeight: FontWeight.bold)),
                        ),
                      ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
