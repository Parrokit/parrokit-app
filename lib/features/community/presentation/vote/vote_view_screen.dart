// ============================================================================
// lib/features/community/presentation/vote_view_screen.dart
// ============================================================================
//
// [역할]
// 투표 상세 보기 및 토론 피드 화면.
// 상단에 투표 카드(VoteCard)를 그대로 노출하여 직관성을 유지하고,
// 하단에 해당 주제에 대한 의견/토론 댓글 리스트와 스티키 입력 창을 배치.
//
// [레이어]
// Presentation Layer > Screens
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:parrokit/features/community/providers/community_provider.dart';
import 'package:parrokit/core/provider/user_provider.dart';
import 'package:parrokit/data/models/comment.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'vote_screen.dart';

class VoteViewScreen extends StatefulWidget {
  final String voteId;

  const VoteViewScreen({super.key, required this.voteId});

  @override
  State<VoteViewScreen> createState() => _VoteViewScreenState();
}

class _VoteViewScreenState extends State<VoteViewScreen> {
  // ─────────────────────────────────────────────────────────────────
  // 상태 & 데이터
  // ─────────────────────────────────────────────────────────────────
  final TextEditingController _commentController = TextEditingController();
  final FocusNode _commentFocusNode = FocusNode();

  bool get _canSubmitComment => _commentController.text.trim().isNotEmpty;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      final user = context.read<UserProvider>().currentUser;
      final provider = context.read<CommunityProvider>();
      await provider.fetchPostDetails(widget.voteId);
      if (user != null) {
        await provider.fetchMyVotes(user.id);
      }
      await provider.fetchComments(widget.voteId, currentUserId: user?.id);
    });
  }

  @override
  void dispose() {
    _commentController.dispose();
    _commentFocusNode.dispose();
    super.dispose();
  }

  void _focusCommentInput() {
    FocusScope.of(context).requestFocus(_commentFocusNode);
  }

  void _submitComment() async {
    final text = _commentController.text.trim();
    if (text.isEmpty) return;

    final user = context.read<UserProvider>().currentUser;
    if (user == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('로그인이 필요합니다.')),
      );
      return;
    }

    final provider = context.read<CommunityProvider>();

    _commentController.clear();
    _commentFocusNode.unfocus();

    final success = await provider.addComment(
      widget.voteId,
      text,
      authorId: user.id,
      authorNickname: user.displayName ?? '',
      authorAvatarUrl: user.photoUrl,
    );

    if (success) {
      provider.fetchComments(widget.voteId, currentUserId: user.id);
    } else {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(provider.errorMessage ?? '댓글 등록 실패')),
        );
      }
    }
  }

  // ─────────────────────────────────────────────────────────────────
  // Build
  // ─────────────────────────────────────────────────────────────────
  @override
  Widget build(BuildContext context) {
    final provider = context.watch<CommunityProvider>();
    final voteItem =
        provider.posts.where((p) => p.id == widget.voteId).firstOrNull;

    if (voteItem == null) {
      return const Scaffold(
        backgroundColor: Colors.white,
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        scrolledUnderElevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded,
              color: Colors.black, size: 20),
          onPressed: () => Navigator.maybePop(context),
        ),
        title: const Text(
          '투표 상세 토론',
          style: TextStyle(
              color: Colors.black, fontWeight: FontWeight.bold, fontSize: 16),
        ),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Container(color: const Color(0xFFF1F3F5), height: 1),
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // 투표 카드 표시
                  Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: VoteCard(
                      item: voteItem,
                      selectedOption: provider.myVotes[voteItem.id],
                      showResult: false,
                      showToggleResultButton: false,
                      onSelect: (idx) {
                        final user = context.read<UserProvider>().currentUser;
                        if (user != null) {
                          provider.votePost(voteItem.id, idx, user.id);
                        }
                      },
                      onToggleResult: () {},
                    ),
                  ),

                  // Divider
                  Container(
                    height: 8,
                    color: const Color(0xFFF1F3F5),
                  ),

                  // Comments section header
                  Padding(
                    padding: const EdgeInsets.fromLTRB(16, 20, 16, 8),
                    child: Text(
                      '토론 & 의견 (${provider.currentPostComments.length})',
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF212529),
                      ),
                    ),
                  ),

                  // List of comments
                  if (provider.currentPostComments.isEmpty)
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 40.0),
                      child: Center(
                        child: Text(
                          '첫 의견을 작성해 투표 토론에 참여해보세요!',
                          style:
                              TextStyle(color: Colors.grey[500], fontSize: 14),
                        ),
                      ),
                    )
                  else
                    ..._buildStructuredComments(
                        provider.currentPostComments, voteItem.authorId),
                ],
              ),
            ),
          ),

          // Sticky Reply Input Bar
          _buildStickyReplyBar(),
        ],
      ),
    );
  }

  String _formatTimeAgo(DateTime? time) {
    if (time == null) return '';
    final diff = DateTime.now().difference(time);
    if (diff.inDays > 0) return '${diff.inDays}일 전';
    if (diff.inHours > 0) return '${diff.inHours}시간 전';
    if (diff.inMinutes > 0) return '${diff.inMinutes}분 전';
    return '방금 전';
  }

  List<Widget> _buildStructuredComments(
      List<Comment> allComments, String postAuthorId) {
    final parentComments =
        allComments.where((c) => c.parentId == null).toList();
    final childComments = allComments.where((c) => c.parentId != null).toList();

    final List<Widget> widgets = [];
    for (var i = 0; i < parentComments.length; i++) {
      final parent = parentComments[i];
      widgets.add(_buildCommentItem(parent, postAuthorId, isReply: false));

      final children =
          childComments.where((c) => c.parentId == parent.id).toList();
      for (var child in children) {
        widgets.add(_buildCommentItem(child, postAuthorId, isReply: true));
      }

      if (i < parentComments.length - 1) {
        widgets.add(const Divider(color: Color(0xFFF1F3F5), height: 1));
      }
    }
    return widgets;
  }

  Widget _buildCommentItem(Comment comment, String postAuthorId,
      {required bool isReply}) {
    final currentUser = context.read<UserProvider>().currentUser;
    final isMyComment =
        currentUser != null && comment.authorId == currentUser.id;
    final isDeleted = comment.status == 'deleted';
    final provider = context.watch<CommunityProvider>();
    final isLiked = provider.likedCommentIds.contains(comment.id);

    return GestureDetector(
      onLongPress: () => _showCommentOptionsSheet(comment),
      behavior: HitTestBehavior.opaque,
      child: Container(
        padding: EdgeInsets.fromLTRB(isReply ? 48 : 16, 16, 16, 16),
        decoration: isReply
            ? const BoxDecoration(
                border: Border(
                  left: BorderSide(color: Color(0xFFEFEFEF), width: 3),
                ),
              )
            : null,
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            CircleAvatar(
              radius: 18,
              backgroundColor: const Color(0xFFF1F3F5),
              backgroundImage: (comment.authorAvatarUrl != null &&
                      comment.authorAvatarUrl!.isNotEmpty &&
                      !isDeleted)
                  ? CachedNetworkImageProvider(comment.authorAvatarUrl!)
                  : null,
              child: (comment.authorAvatarUrl == null ||
                      comment.authorAvatarUrl!.isEmpty ||
                      isDeleted)
                  ? const Icon(Icons.person, color: Color(0xFF9E9E9E), size: 20)
                  : null,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.baseline,
                    textBaseline: TextBaseline.alphabetic,
                    children: [
                      Text(
                        isDeleted ? '알 수 없음' : comment.authorNickname,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                          color: Color(0xFF212529),
                        ),
                      ),
                      if (comment.authorId == postAuthorId && !isDeleted) ...[
                        const SizedBox(width: 4),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 4, vertical: 1),
                          decoration: BoxDecoration(
                            color: Colors.blue[50],
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(
                            '작성자',
                            style: TextStyle(
                              color: Colors.blue[600],
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                      const Spacer(),
                      if (comment.createdAt != null)
                        Text(
                          _formatTimeAgo(comment.createdAt),
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey[400],
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  if (isReply && comment.replyToNickname != null && !isDeleted)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 4),
                      child: Text(
                        '@${comment.replyToNickname}',
                        style: const TextStyle(
                          color: Colors.blue,
                          fontSize: 13,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  Text(
                    isDeleted ? '삭제된 댓글입니다.' : comment.content,
                    style: TextStyle(
                      fontSize: 14,
                      color: isDeleted
                          ? const Color(0xFF9E9E9E)
                          : const Color(0xFF495057),
                      height: 1.45,
                    ),
                  ),
                  const SizedBox(height: 12),
                  if (!isDeleted)
                    Row(
                      children: [
                        GestureDetector(
                          onTap: () {
                            if (currentUser == null) return;
                            provider.toggleCommentLike(
                                widget.voteId, comment.id, currentUser.id);
                          },
                          child: Row(
                            children: [
                              Icon(
                                isLiked
                                    ? Icons.favorite_rounded
                                    : Icons.favorite_border_rounded,
                                size: 15,
                                color: isLiked ? Colors.red : Colors.grey[400],
                              ),
                              const SizedBox(width: 4),
                              Text(
                                '${comment.likeCount}',
                                style: TextStyle(
                                  fontSize: 12,
                                  color:
                                      isLiked ? Colors.red : Colors.grey[500],
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 16),
                        GestureDetector(
                          onTap: () {
                            provider.setReplyingTo(comment);
                            _focusCommentInput();
                          },
                          child: Text(
                            '답글 달기',
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey[500],
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ],
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showCommentOptionsSheet(Comment comment) {
    if (comment.status == 'deleted') return;

    final currentUser = context.read<UserProvider>().currentUser;
    final isMyComment =
        currentUser != null && comment.authorId == currentUser.id;
    final provider = context.read<CommunityProvider>();

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const SizedBox(height: 8),
              Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(height: 16),
              if (isMyComment)
                ListTile(
                  leading: const Icon(Icons.delete_outline, color: Colors.red),
                  title:
                      const Text('삭제하기', style: TextStyle(color: Colors.red)),
                  onTap: () async {
                    Navigator.pop(context);
                    final confirm = await showDialog<bool>(
                      context: context,
                      builder: (ctx) => AlertDialog(
                        title: const Text('댓글 삭제'),
                        content: const Text('정말로 이 댓글을 삭제하시겠습니까?'),
                        actions: [
                          TextButton(
                            onPressed: () => Navigator.pop(ctx, false),
                            child: const Text('취소'),
                          ),
                          TextButton(
                            onPressed: () => Navigator.pop(ctx, true),
                            child: const Text('삭제',
                                style: TextStyle(color: Colors.red)),
                          ),
                        ],
                      ),
                    );
                    if (confirm == true) {
                      await provider.deleteComment(widget.voteId, comment.id);
                    }
                  },
                ),
              if (!isMyComment)
                ListTile(
                  leading: const Icon(Icons.reply_rounded),
                  title: const Text('답글 달기'),
                  onTap: () {
                    Navigator.pop(context);
                    provider.setReplyingTo(comment);
                    _focusCommentInput();
                  },
                ),
              if (!isMyComment)
                ListTile(
                  leading: const Icon(Icons.report_problem_outlined),
                  title: const Text('신고하기'),
                  onTap: () {
                    Navigator.pop(context);
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('신고가 접수되었습니다.')),
                    );
                  },
                ),
              const SizedBox(height: 16),
            ],
          ),
        );
      },
    );
  }

  Widget _buildStickyReplyBar() {
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
                    style:
                        const TextStyle(fontSize: 13, color: Color(0xFF495057)),
                  ),
                ),
                GestureDetector(
                  onTap: () => provider.setReplyingTo(null),
                  child: const Icon(Icons.close,
                      size: 16, color: Color(0xFF868E96)),
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
            border: const Border(
              top: BorderSide(color: Color(0xFFE9ECEF), width: 1),
            ),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
          child: SafeArea(
            child: Row(
              children: [
                CircleAvatar(
                  radius: 16,
                  backgroundColor: const Color(0xFFF1F3F5),
                  backgroundImage: (currentUser?.photoUrl != null &&
                          currentUser!.photoUrl!.isNotEmpty)
                      ? CachedNetworkImageProvider(currentUser.photoUrl!)
                      : null,
                  child: (currentUser?.photoUrl == null ||
                          currentUser!.photoUrl!.isEmpty)
                      ? const Icon(Icons.person,
                          color: Color(0xFF9E9E9E), size: 18)
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
                      controller: _commentController,
                      focusNode: _commentFocusNode,
                      onChanged: (_) => setState(() {}),
                      onSubmitted: (_) => _submitComment(),
                      decoration: InputDecoration(
                        hintText: '투표 의견 남기기...',
                        fillColor: Colors.grey[100],
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
                    color:
                        _canSubmitComment ? Colors.blue[600] : Colors.grey[400],
                    size: 22,
                  ),
                  onPressed: _canSubmitComment ? _submitComment : null,
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
