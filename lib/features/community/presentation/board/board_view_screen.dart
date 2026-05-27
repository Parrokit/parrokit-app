import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:parrokit/features/community/providers/community_provider.dart';
import 'package:parrokit/data/models/post.dart';
import 'package:parrokit/data/models/comment.dart';
import 'package:go_router/go_router.dart';
import 'package:parrokit/core/provider/user_provider.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:parrokit/features/community/presentation/board/board_write_screen.dart';

class BoardViewScreen extends StatefulWidget {
  final String postId;

  const BoardViewScreen({super.key, required this.postId});

  @override
  State<BoardViewScreen> createState() => _BoardViewScreenState();
}

class _BoardViewScreenState extends State<BoardViewScreen> {
  final TextEditingController _commentController = TextEditingController();
  final FocusNode _commentFocusNode = FocusNode();

  bool get _canSubmitComment => _commentController.text.trim().isNotEmpty;

  bool _isFetchingDetails = true;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      final user = context.read<UserProvider>().currentUser;
      final provider = context.read<CommunityProvider>();
      
      await Future.wait([
        provider.fetchPostDetails(widget.postId),
        provider.fetchComments(widget.postId, currentUserId: user?.id),
        provider.loadUserActions(widget.postId, userId: user?.id),
      ]);
      
      provider.incrementViewCount(widget.postId, userId: user?.id);
      
      if (mounted) {
        setState(() {
          _isFetchingDetails = false;
        });
      }
    });
  }

  void _focusCommentInput() {
    FocusScope.of(context).requestFocus(_commentFocusNode);
    Future<void>.delayed(const Duration(milliseconds: 20), () {
      if (!mounted) return;
      SystemChannels.textInput.invokeMethod<void>('TextInput.show');
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

  void _submitComment() async {
    final text = _commentController.text.trim();
    if (text.isEmpty) return;

    final currentUser = context.read<UserProvider>().currentUser;
    if (currentUser == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('로그인이 필요합니다.')),
      );
      return;
    }

    _commentController.clear();
    _commentFocusNode.unfocus();

    final provider = context.read<CommunityProvider>();
    final success = await provider.addComment(
      widget.postId, 
      text,
      authorId: currentUser.id,
      authorNickname: currentUser.displayName ?? '알 수 없음',
      authorAvatarUrl: currentUser.photoUrl,
    );
    
    if (!success && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(provider.errorMessage ?? '댓글 등록에 실패했습니다.')),
      );
    }
  }

  void _showCommentOptionsSheet(Comment comment) {
    final currentUser = context.read<UserProvider>().currentUser;
    final isMyComment = currentUser != null && comment.authorId == currentUser.id;

    showModalBottomSheet<void>(
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
                  _CommentSheetAction(
                    label: '삭제',
                    isDestructive: true,
                    onTap: () async {
                      Navigator.pop(sheetContext); // 바텀시트 닫기

                      // 확인 팝업
                      final confirm = await showDialog<bool>(
                        context: context,
                        builder: (ctx) => AlertDialog(
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                          title: const Text('댓글 삭제', style: TextStyle(fontWeight: FontWeight.bold)),
                          content: const Text('정말로 이 댓글을 삭제하시겠습니까?\n삭제 후에는 복구할 수 없습니다.'),
                          actions: [
                            TextButton(
                              onPressed: () => Navigator.pop(ctx, false),
                              child: const Text('취소', style: TextStyle(color: Colors.grey)),
                            ),
                            TextButton(
                              onPressed: () => Navigator.pop(ctx, true),
                              child: const Text('삭제', style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold)),
                            ),
                          ],
                        ),
                      );

                      if (confirm != true) return;

                      if (!context.mounted) return;
                      final provider = context.read<CommunityProvider>();
                      final success = await provider.deleteComment(widget.postId, comment.id);

                      if (!context.mounted) return;
                      if (success) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('댓글이 삭제되었습니다.')),
                        );
                      } else {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text(provider.errorMessage ?? '삭제에 실패했습니다.')),
                        );
                      }
                    },
                  ),
                if (!isMyComment)
                  _CommentSheetAction(
                    label: '신고',
                    onTap: () {
                      Navigator.pop(sheetContext);
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('신고가 접수되었습니다.')),
                      );
                    },
                  ),
                _CommentSheetAction(
                  label: '닫기',
                  onTap: () => Navigator.pop(sheetContext),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _showPostOptionsSheet(Post post) {
    final currentUser = context.read<UserProvider>().currentUser;
    final isMyPost = currentUser != null && post.authorId == currentUser.id;

    showModalBottomSheet<void>(
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
                  _CommentSheetAction(
                    label: '수정',
                    onTap: () {
                      Navigator.pop(sheetContext); // 바텀시트 닫기
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => BoardWriteScreen(editPost: post),
                        ),
                      );
                    },
                  ),
                  _CommentSheetAction(
                    label: '삭제',
                    isDestructive: true,
                    onTap: () async {
                      Navigator.pop(sheetContext); // 바텀시트만 안전하게 닫기
                      
                      // 1. 확인 다이얼로그 띄우기 (부모 화면의 context 사용)
                      final confirm = await showDialog<bool>(
                        context: context,
                        builder: (ctx) => AlertDialog(
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                          title: const Text('게시글 삭제', style: TextStyle(fontWeight: FontWeight.bold)),
                          content: const Text('정말로 이 게시글을 삭제하시겠습니까?\n삭제 후에는 복구할 수 없습니다.'),
                          actions: [
                            TextButton(
                              onPressed: () => Navigator.pop(ctx, false),
                              child: const Text('취소', style: TextStyle(color: Colors.grey)),
                            ),
                            TextButton(
                              onPressed: () => Navigator.pop(ctx, true),
                              child: const Text('삭제', style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold)),
                            ),
                          ],
                        ),
                      );

                      if (confirm != true) return; // 취소했거나 그냥 닫은 경우 중단
                      
                      // 2. 삭제 실행 (부모 화면의 context 사용)
                      if (!context.mounted) return;
                      final provider = context.read<CommunityProvider>();
                      final success = await provider.deletePost(post.id);
                      
                      if (!context.mounted) return;
                      if (success) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('게시글이 삭제되었습니다.')),
                        );
                        context.pop(); // 게시글 상세 화면 닫기 (이전 화면으로)
                      } else {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text(provider.errorMessage ?? '삭제에 실패했습니다.')),
                        );
                      }
                    },
                  ),
                ],
                _CommentSheetAction(
                  label: '신고',
                  onTap: () {
                    Navigator.pop(sheetContext);
                    // TODO: 게시글 신고 기능 구현
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('신고가 접수되었습니다.')),
                    );
                  },
                ),
                _CommentSheetAction(
                  label: '닫기',
                  onTap: () => Navigator.pop(sheetContext),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  void dispose() {
    _commentController.dispose();
    _commentFocusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    const backgroundColor = Color(0xFFFFFFFF);
    const textMuted = Color(0xFF8B8B8B);
    const likeAccent = Color(0xFF3F72C4); // blue[600] 느낌
    const scrapAccent = Color(0xFFC9AE58); // 부드러운 노랑 느낌
    final sendAccent = Colors.blue[600]!;

    final provider = context.watch<CommunityProvider>();
    final _liked = provider.isCurrentPostLiked;
    final _scrapped = provider.isCurrentPostScrapped;

    final likeMetaColor = _liked ? likeAccent : const Color(0xFF9F9F9F);
    final likeIconColor = _liked ? likeAccent : const Color(0xFFB2B2B2);
    
    final post = provider.posts.firstWhere(
      (p) => p.id == widget.postId,
      orElse: () => Post(
        id: widget.postId,
        postType: 'board',
        category: '알 수 없음',
        title: '게시글을 찾을 수 없습니다.',
        content: '삭제되었거나 접근할 수 없는 게시글입니다.',
        authorId: '',
        authorNickname: '알 수 없음',
        snippet: '',
        createdAt: DateTime.now(),
      ),
    );

    final currentUser = context.watch<UserProvider>().currentUser;
    final isMe = currentUser != null && post.authorId == currentUser.id;

    final comments = provider.currentPostComments;
    final commentCount = comments.length;

    if (_isFetchingDetails) {
      return Scaffold(
        backgroundColor: backgroundColor,
        body: const Center(
          child: CircularProgressIndicator(color: likeAccent),
        ),
      );
    }

    return Scaffold(
      backgroundColor: backgroundColor,
      resizeToAvoidBottomInset: true,
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(8, 10, 8, 0),
              child: Row(
                children: [
                  IconButton(
                    onPressed: () => Navigator.maybePop(context),
                    icon: const Icon(Icons.arrow_back_ios_new, size: 24),
                  ),
                  const Spacer(),
                  IconButton(
                    onPressed: () {},
                    icon:
                        const Icon(Icons.notifications_off_outlined, size: 24),
                  ),
                  IconButton(
                    onPressed: () => _showPostOptionsSheet(post),
                    icon: const Icon(Icons.more_vert, size: 24),
                  ),
                ],
              ),
            ),
            Expanded(
              child: SingleChildScrollView(
                keyboardDismissBehavior:
                    ScrollViewKeyboardDismissBehavior.onDrag,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 28),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 18),
                      child: Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 16, vertical: 8),
                            decoration: BoxDecoration(
                              color: const Color.fromARGB(255, 245, 245, 245),
                              borderRadius: BorderRadius.circular(24),
                            ),
                            child: Row(
                              children: [
                                Text(
                                  post.category,
                                  style: const TextStyle(
                                    fontSize: 30 / 2,
                                    fontWeight: FontWeight.w700,
                                    color: Color(0xFF6E6E6E),
                                  ),
                                ),
                                SizedBox(width: 4),
                                Icon(Icons.chevron_right,
                                    size: 20, color: Color(0xFF7E7E7E)),
                              ],
                            ),
                          ),
                          const Spacer(),
                          const Icon(Icons.remove_red_eye_outlined,
                              color: Color(0xFFB2B2B2), size: 24),
                          const SizedBox(width: 6),
                          Text(
                            '${post.viewCount}',
                            style: const TextStyle(
                                color: Color(0xFF9F9F9F),
                                fontSize: 30 / 2,
                                fontWeight: FontWeight.w700),
                          ),
                          const SizedBox(width: 18),
                          Icon(Icons.thumb_up_outlined,
                              color: likeIconColor, size: 24),
                          const SizedBox(width: 6),
                          Text(
                            '${post.likeCount}',
                            style: TextStyle(
                                color: likeMetaColor,
                                fontSize: 30 / 2,
                                fontWeight: FontWeight.w700),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 26),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 18),
                      child: Row(
                        children: [
                          Container(
                            width: 48,
                            height: 48,
                            decoration: const BoxDecoration(
                              shape: BoxShape.circle,
                              color: Color.fromARGB(255, 220, 220, 220),
                            ),
                            child: ClipOval(
                              child: ((isMe ? currentUser?.photoUrl : (post.authorId != null ? provider.getCachedUser(post.authorId!)?.photoUrl : null)) ?? post.authorAvatarUrl) != null && 
                                     ((isMe ? currentUser?.photoUrl : (post.authorId != null ? provider.getCachedUser(post.authorId!)?.photoUrl : null)) ?? post.authorAvatarUrl)!.isNotEmpty
                                  ? Image.network(
                                      (isMe ? currentUser?.photoUrl : (post.authorId != null ? provider.getCachedUser(post.authorId!)?.photoUrl : null)) ?? post.authorAvatarUrl!,
                                      fit: BoxFit.cover,
                                      errorBuilder: (context, error, stackTrace) => const Icon(
                                          Icons.person,
                                          size: 30,
                                          color: Color.fromARGB(255, 255, 255, 255)),
                                    )
                                  : const Icon(Icons.person,
                                      size: 30,
                                      color: Color.fromARGB(255, 255, 255, 255)),
                            ),
                          ),
                          const SizedBox(width: 10),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                (isMe ? currentUser?.displayName : (post.authorId != null ? provider.getCachedUser(post.authorId!)?.displayName : null)) ?? post.authorNickname,
                                style: const TextStyle(
                                  fontSize: 34 / 2,
                                  fontWeight: FontWeight.w800,
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                '${_formatTimeAgo(post.createdAt)}${post.editHistory.isNotEmpty ? ' (수정됨)' : ''}',
                                style: const TextStyle(
                                  fontSize: 15,
                                  fontWeight: FontWeight.w700,
                                  color: Color(0xFF6E6E6E),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 28),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: Text(
                        post.title,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w800,
                          height: 1.25,
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: Text(
                        // 과거 마크다운 이미지 태그가 남아있다면 깔끔하게 제거
                        post.content.replaceAll(RegExp(r'!\[.*?\]\(.*?\)'), '').trim(),
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w400,
                          height: 1.6,
                          color: Colors.black87,
                        ),
                      ),
                    ),
                    if (post.hasImage && post.imageUrls.isNotEmpty) ...[
                      const SizedBox(height: 24),
                      SizedBox(
                        height: 240,
                        child: ListView.separated(
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          scrollDirection: Axis.horizontal,
                          itemCount: post.imageUrls.length,
                          separatorBuilder: (context, index) => const SizedBox(width: 12),
                          itemBuilder: (context, index) {
                            return ClipRRect(
                              borderRadius: BorderRadius.circular(12),
                              child: AspectRatio(
                                aspectRatio: 1,
                                child: Image.network(
                                  post.imageUrls[index],
                                  fit: BoxFit.cover,
                                  errorBuilder: (context, error, stackTrace) =>
                                      Container(
                                        color: Colors.grey[200],
                                        child: const Icon(Icons.broken_image, color: Colors.grey),
                                      ),
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                    ],
                    if (post.tags.isNotEmpty) ...[
                      const SizedBox(height: 24),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        child: Wrap(
                          spacing: 8,
                          runSpacing: 8,
                          alignment: WrapAlignment.start,
                          children: post.tags.map((tag) => Text(
                            '#$tag',
                            style: const TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w600,
                              color: Color(0xFF8F96A3),
                            ),
                          )).toList(),
                        ),
                      ),
                    ],
                    const SizedBox(height: 44),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        _ActionTile(
                          icon:
                              _liked ? Icons.thumb_up : Icons.thumb_up_outlined,
                          label: '공감',
                          selected: _liked,
                          accentColor: likeAccent,
                          onTap: () {
                            final user = context.read<UserProvider>().currentUser;
                            if (user == null) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(content: Text('로그인이 필요합니다.')),
                              );
                              return;
                            }
                            provider.toggleLike(widget.postId, user.id);
                          },
                        ),
                        const SizedBox(width: 26),
                        _ActionTile(
                          icon: _scrapped
                              ? Icons.bookmark
                              : Icons.bookmark_outline,
                          label: '스크랩',
                          selected: _scrapped,
                          accentColor: scrapAccent,
                          onTap: () {
                            final user = context.read<UserProvider>().currentUser;
                            if (user == null) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(content: Text('로그인이 필요합니다.')),
                              );
                              return;
                            }
                            provider.toggleScrap(widget.postId, user.id);
                          },
                        ),
                      ],
                    ),
                    const SizedBox(height: 40),
                    const Divider(
                        height: 1,
                        thickness: 5,
                        color: Color.fromARGB(255, 239, 239, 239)),
                    Padding(
                      padding: const EdgeInsets.fromLTRB(18, 18, 28, 0),
                      child: Text(
                        '댓글 ${comments.length}',
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w800,
                          color: Color(0xFF6A6A6A),
                        ),
                      ),
                    ),
                    if (comments.isEmpty) ...[
                      const SizedBox(height: 130),
                      const Center(
                        child: Text(
                          '첫 댓글을 남겨보세요',
                          style: TextStyle(
                            fontSize: 16,
                            color: textMuted,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                      const SizedBox(height: 24),
                      Center(
                        child: InkWell(
                          onTap: _focusCommentInput,
                          borderRadius: BorderRadius.circular(12),
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 24, vertical: 12),
                            decoration: BoxDecoration(
                              color: const Color.fromARGB(255, 250, 250, 250),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: const Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(Icons.edit_outlined,
                                    size: 24,
                                    color: Color.fromARGB(255, 188, 188, 188)),
                                SizedBox(width: 10),
                                Text(
                                  '댓글 쓰기',
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w800,
                                    color: Color(0xFF3F3F3F),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ] else ...[
                      const SizedBox(height: 8),
                      ..._buildStructuredComments(comments, post.authorId),
                    ],
                    const SizedBox(height: 280),
                  ],
                ),
              ),
            ),
            Container(
              decoration: const BoxDecoration(
                color: backgroundColor,
                border: Border(top: BorderSide(color: Color(0xFFDCDCDC))),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (provider.replyingTo != null)
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                      color: const Color(0xFFF6F6F6),
                      child: Row(
                        children: [
                          Expanded(
                            child: Text(
                              '${provider.replyingTo!.authorNickname}님에게 답글 남기는 중',
                              style: const TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                                color: Color(0xFF666666),
                              ),
                            ),
                          ),
                          GestureDetector(
                            onTap: () => provider.setReplyingTo(null),
                            child: const Icon(Icons.close, size: 18, color: Color(0xFF888888)),
                          ),
                        ],
                      ),
                    ),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
                    child: Row(
                      children: [
                        IconButton(
                          onPressed: () {},
                          icon: const Icon(Icons.photo_outlined, size: 32),
                          color: const Color(0xFF707070),
                        ),
                        const SizedBox(width: 6),
                        Expanded(
                          child: GestureDetector(
                            onTap: _focusCommentInput,
                            child: Container(
                              height: 52,
                              padding: const EdgeInsets.symmetric(horizontal: 18),
                              decoration: BoxDecoration(
                                color: const Color.fromARGB(255, 250, 250, 250),
                                borderRadius: BorderRadius.circular(30),
                              ),
                              child: Row(
                                children: [
                                  Expanded(
                                    child: TextField(
                                      controller: _commentController,
                                      focusNode: _commentFocusNode,
                                      onChanged: (_) => setState(() {}),
                                      onSubmitted: (_) => _submitComment(),
                                      style: const TextStyle(
                                        color: Color(0xFF3F3F3F),
                                        fontSize: 16,
                                        fontWeight: FontWeight.w500,
                                      ),
                                      decoration: const InputDecoration(
                                        hintText: '댓글을 입력해주세요.',
                                        fillColor: Color.fromARGB(255, 250, 250, 250),
                                        hintStyle: TextStyle(
                                          color: Color(0xFF9B9B9B),
                                          fontSize: 18,
                                          fontWeight: FontWeight.w500,
                                        ),
                                        isDense: true,
                                        contentPadding: EdgeInsets.zero,
                                        border: InputBorder.none,
                                        enabledBorder: InputBorder.none,
                                        focusedBorder: InputBorder.none,
                                      ),
                                      textInputAction: TextInputAction.send,
                                    ),
                                  ),
                                  GestureDetector(
                                    onTap: _canSubmitComment ? _submitComment : null,
                                    child: Icon(
                                      Icons.keyboard_return_rounded,
                                      color: _canSubmitComment
                                          ? sendAccent
                                          : const Color(0xFF8A8A8A),
                                      size: 30,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  List<Widget> _buildStructuredComments(List<Comment> allComments, String postAuthorId) {
    // 1-Depth 구조 만들기
    final parentComments = allComments.where((c) => c.parentId == null).toList();
    final childComments = allComments.where((c) => c.parentId != null).toList();
    
    final List<Widget> widgets = [];
    for (var parent in parentComments) {
      widgets.add(_buildCommentItem(parent, postAuthorId, isReply: false));
      
      final children = childComments.where((c) => c.parentId == parent.id).toList();
      for (var child in children) {
        widgets.add(_buildCommentItem(child, postAuthorId, isReply: true));
      }
    }
    return widgets;
  }

  Widget _buildCommentItem(Comment comment, String postAuthorId, {required bool isReply}) {
    final currentUser = context.read<UserProvider>().currentUser;
    final isMyComment = currentUser != null && comment.authorId == currentUser.id;
    final isAuthor = comment.authorId == postAuthorId;
    final isDeleted = comment.status == 'deleted';
    
    final provider = context.watch<CommunityProvider>();
    final isLiked = provider.likedCommentIds.contains(comment.id);

    return Container(
      padding: EdgeInsets.fromLTRB(isReply ? 18 + 22 + 12 : 18, 18, 18, 0),
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
          Container(
            width: isReply ? 36 : 44,
            height: isReply ? 36 : 44,
            decoration: const BoxDecoration(
              shape: BoxShape.circle,
              color: Color(0xFFE5E5E5),
            ),
            child: ClipOval(
              child: ((isMyComment ? currentUser?.photoUrl : (comment.authorId != null ? provider.getCachedUser(comment.authorId!)?.photoUrl : null)) ?? comment.authorAvatarUrl) != null && 
                     ((isMyComment ? currentUser?.photoUrl : (comment.authorId != null ? provider.getCachedUser(comment.authorId!)?.photoUrl : null)) ?? comment.authorAvatarUrl)!.isNotEmpty && 
                     !isDeleted
                  ? Image.network(
                      (isMyComment ? currentUser?.photoUrl : (comment.authorId != null ? provider.getCachedUser(comment.authorId!)?.photoUrl : null)) ?? comment.authorAvatarUrl!,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) => Center(
                        child: Icon(
                          Icons.person,
                          size: isReply ? 20 : 26,
                          color: const Color(0xFF9E9E9E), // 조금 더 진한 회색
                        ),
                      ),
                    )
                  : Center(
                      child: isDeleted
                          ? const SizedBox() // 삭제된 댓글이면 아무것도 안 보여줌
                          : Icon(
                              Icons.person,
                              size: isReply ? 20 : 26,
                              color: const Color(0xFF9E9E9E),
                            ),
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
                      isDeleted ? '(삭제됨)' : ((isMyComment ? currentUser?.displayName : (comment.authorId != null ? provider.getCachedUser(comment.authorId!)?.displayName : null)) ?? comment.authorNickname),
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
                        decoration: BoxDecoration(
                          color: const Color(0xFFE6F0FF),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: const Text('작성자', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: Color(0xFF3F72C4))),
                      ),
                    ],
                    if (!isDeleted && isMyComment && !isAuthor) ...[
                      const SizedBox(width: 6),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: const Color(0xFFF0F0F0),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: const Text('내 댓글', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: Color(0xFF7A7A7A))),
                      ),
                    ],
                  ],
                ),
                const SizedBox(height: 2),
                if (!isDeleted)
                  Text(
                    _formatTimeAgo(comment.createdAt),
                    style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF8F96A3),
                    ),
                  ),
                const SizedBox(height: 8),
                if (!isDeleted && isReply && comment.replyToNickname != null)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 4),
                    child: Text(
                      '@${comment.replyToNickname}',
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFF3F72C4),
                      ),
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
                        onTap: () {
                          if (currentUser == null) return;
                          context.read<CommunityProvider>().toggleCommentLike(widget.postId, comment.id, currentUser.id);
                        },
                        child: Row(
                          children: [
                            Icon(
                              isLiked ? Icons.favorite : Icons.favorite_border,
                              size: 18,
                              color: isLiked ? Colors.redAccent : const Color(0xFF8F96A3),
                            ),
                            const SizedBox(width: 4),
                            Text(
                              comment.likeCount > 0 ? '${comment.likeCount}' : '좋아요',
                              style: TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                                color: isLiked ? Colors.redAccent : const Color(0xFF8F96A3),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 20),
                      GestureDetector(
                        onTap: () {
                          context.read<CommunityProvider>().setReplyingTo(comment);
                          _focusCommentInput();
                        },
                        child: Row(
                          children: const [
                            Icon(Icons.chat_bubble_outline,
                                size: 16, color: Color(0xFF8F96A3)),
                            SizedBox(width: 4),
                            Text(
                              '답글쓰기',
                              style: TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                                color: Color(0xFF8F96A3),
                              ),
                            ),
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
              onPressed: () => _showCommentOptionsSheet(comment),
              icon: const Icon(Icons.more_vert, color: Color(0xFF8F96A3), size: 20),
            )
          else
            const SizedBox(width: 48), // 메뉴 버튼 공간 비워두기
        ],
      ),
    );
  }
}

class _CommentSheetAction extends StatelessWidget {
  final String label;
  final bool isDestructive;
  final VoidCallback onTap;

  const _CommentSheetAction({
    required this.label,
    required this.onTap,
    this.isDestructive = false,
  });

  @override
  Widget build(BuildContext context) {
    final textColor =
        isDestructive ? const Color(0xFFD34B4B) : const Color(0xFF222222);

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 18),
        alignment: Alignment.center,
        child: Text(
          label,
          style: TextStyle(
            fontSize: 17,
            fontWeight: FontWeight.w700,
            color: textColor,
          ),
        ),
      ),
    );
  }
}

class _ActionTile extends StatefulWidget {
  final IconData icon;
  final String label;
  final bool selected;
  final Color accentColor;
  final VoidCallback onTap;

  const _ActionTile({
    required this.icon,
    required this.label,
    required this.selected,
    required this.accentColor,
    required this.onTap,
  });

  @override
  State<_ActionTile> createState() => _ActionTileState();
}

class _ActionTileState extends State<_ActionTile> {
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    final borderColor =
        widget.selected ? widget.accentColor : const Color(0xFFD8D8D8);
    final borderWidth = _pressed ? 2.0 : 1.4;
    final contentColor = widget.selected
        ? widget.accentColor
        : const Color.fromARGB(255, 193, 193, 193);
    final labelColor =
        widget.selected ? widget.accentColor : const Color(0xFF5E5E5E);

    return AnimatedScale(
      scale: _pressed ? 0.94 : 1,
      duration: const Duration(milliseconds: 110),
      curve: Curves.easeOutCubic,
      child: InkWell(
        onTap: widget.onTap,
        onTapDown: (_) => setState(() => _pressed = true),
        onTapUp: (_) => setState(() => _pressed = false),
        onTapCancel: () => setState(() => _pressed = false),
        borderRadius: BorderRadius.circular(8),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          curve: Curves.easeOutCubic,
          width: 55,
          height: 55,
          decoration: BoxDecoration(
            color: Colors.transparent,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: borderColor, width: borderWidth),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(widget.icon, size: 18, color: contentColor),
              const SizedBox(height: 2),
              Text(
                widget.label,
                style: TextStyle(
                  color: labelColor,
                  fontWeight: FontWeight.w700,
                  fontSize: 12,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
