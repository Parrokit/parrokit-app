import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:parrokit/features/community/providers/community_provider.dart';
import 'package:parrokit/data/models/post.dart';
import 'package:parrokit/data/models/comment.dart';
import 'package:go_router/go_router.dart';
import 'package:parrokit/core/provider/user_provider.dart';
import 'package:parrokit/features/community/presentation/board/board_write_screen.dart';
import 'package:parrokit/features/community/presentation/board/widgets/board_action_tile.dart';
import 'package:parrokit/features/community/presentation/board/widgets/board_sheet_action.dart';
import 'package:parrokit/features/community/presentation/board/widgets/board_comment_input_bar.dart';
import 'package:parrokit/features/community/presentation/board/widgets/board_comment_item.dart';
import 'package:parrokit/features/community/presentation/board/widgets/board_post_meta_row.dart';
import 'package:parrokit/features/community/presentation/board/widgets/board_post_author_row.dart';
import 'package:parrokit/features/community/presentation/board/widgets/board_post_content_section.dart';
import 'package:parrokit/features/community/presentation/board/widgets/board_comments_empty_state.dart';

class BoardViewScreen extends StatefulWidget {
  final String postId;

  const BoardViewScreen({super.key, required this.postId});

  @override
  State<BoardViewScreen> createState() => _BoardViewScreenState();
}

class _BoardViewScreenState extends State<BoardViewScreen> {
  final TextEditingController _commentController = TextEditingController();
  final FocusNode _commentFocusNode = FocusNode();
  final ScrollController _scrollController = ScrollController();

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

    if (success) {
      _scrollToBottom();
    } else if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(provider.errorMessage ?? '댓글 등록에 실패했습니다.')),
      );
    }
  }

  void _scrollToBottom({bool animated = true}) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted || !_scrollController.hasClients) return;
      final target = _scrollController.position.maxScrollExtent;
      if (animated) {
        _scrollController.animateTo(
          target,
          duration: const Duration(milliseconds: 240),
          curve: Curves.easeOut,
        );
      } else {
        _scrollController.jumpTo(target);
      }
    });
  }

  void _showCommentOptionsSheet(Comment comment) {
    final currentUser = context.read<UserProvider>().currentUser;
    final isMyComment =
        currentUser != null && comment.authorId == currentUser.id;

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
                  BoardSheetAction(
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
                          title: const Text('댓글 삭제',
                              style: TextStyle(fontWeight: FontWeight.bold)),
                          content: const Text(
                              '정말로 이 댓글을 삭제하시겠습니까?\n삭제 후에는 복구할 수 없습니다.'),
                          actions: [
                            TextButton(
                              onPressed: () => Navigator.pop(ctx, false),
                              child: const Text('취소',
                                  style: TextStyle(color: Colors.grey)),
                            ),
                            TextButton(
                              onPressed: () => Navigator.pop(ctx, true),
                              child: const Text('삭제',
                                  style: TextStyle(
                                      color: Colors.red,
                                      fontWeight: FontWeight.bold)),
                            ),
                          ],
                        ),
                      );

                      if (confirm != true) return;

                      if (!context.mounted) return;
                      final provider = context.read<CommunityProvider>();
                      final success = await provider.deleteComment(
                          widget.postId, comment.id);

                      if (!context.mounted) return;
                      if (success) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('댓글이 삭제되었습니다.')),
                        );
                      } else {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                              content:
                                  Text(provider.errorMessage ?? '삭제에 실패했습니다.')),
                        );
                      }
                    },
                  ),
                if (!isMyComment)
                  BoardSheetAction(
                    label: '신고',
                    onTap: () {
                      Navigator.pop(sheetContext);
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('신고가 접수되었습니다.')),
                      );
                    },
                  ),
                BoardSheetAction(
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
                  BoardSheetAction(
                    label: '수정',
                    onTap: () {
                      Navigator.pop(sheetContext); // 바텀시트 닫기
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) =>
                              BoardWriteScreen(editPost: post),
                        ),
                      );
                    },
                  ),
                  BoardSheetAction(
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
                          title: const Text('게시글 삭제',
                              style: TextStyle(fontWeight: FontWeight.bold)),
                          content: const Text(
                              '정말로 이 게시글을 삭제하시겠습니까?\n삭제 후에는 복구할 수 없습니다.'),
                          actions: [
                            TextButton(
                              onPressed: () => Navigator.pop(ctx, false),
                              child: const Text('취소',
                                  style: TextStyle(color: Colors.grey)),
                            ),
                            TextButton(
                              onPressed: () => Navigator.pop(ctx, true),
                              child: const Text('삭제',
                                  style: TextStyle(
                                      color: Colors.red,
                                      fontWeight: FontWeight.bold)),
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
                          SnackBar(
                              content:
                                  Text(provider.errorMessage ?? '삭제에 실패했습니다.')),
                        );
                      }
                    },
                  ),
                ],
                BoardSheetAction(
                  label: '신고',
                  onTap: () {
                    Navigator.pop(sheetContext);
                    // TODO: 게시글 신고 기능 구현
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('신고가 접수되었습니다.')),
                    );
                  },
                ),
                BoardSheetAction(
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
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    const backgroundColor = Color(0xFFFFFFFF);
    const likeAccent = Color(0xFF3F72C4); // blue[600] 느낌
    const scrapAccent = Color(0xFFC9AE58); // 부드러운 노랑 느낌
    final sendAccent = Colors.blue[600]!;

    final provider = context.watch<CommunityProvider>();
    final liked = provider.isCurrentPostLiked;
    final scrapped = provider.isCurrentPostScrapped;

    final likeMetaColor = liked ? likeAccent : const Color(0xFF9F9F9F);
    final likeIconColor = liked ? likeAccent : const Color(0xFFB2B2B2);

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
    final cachedAuthor = provider.getCachedUser(post.authorId);

    final comments = provider.currentPostComments;
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
                controller: _scrollController,
                keyboardDismissBehavior:
                    ScrollViewKeyboardDismissBehavior.onDrag,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 28),
                    BoardPostMetaRow(
                      post: post,
                      likeMetaColor: likeMetaColor,
                      likeIconColor: likeIconColor,
                    ),
                    const SizedBox(height: 26),
                    BoardPostAuthorRow(
                      post: post,
                      currentUser: currentUser,
                      cachedAuthor: cachedAuthor,
                      isMe: isMe,
                      timeAgoText:
                          '${_formatTimeAgo(post.createdAt)}${post.editHistory.isNotEmpty ? ' (수정됨)' : ''}',
                    ),
                    const SizedBox(height: 28),
                    BoardPostContentSection(post: post),
                    const SizedBox(height: 44),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        BoardActionTile(
                          icon:
                              liked ? Icons.thumb_up : Icons.thumb_up_outlined,
                          label: '공감',
                          selected: liked,
                          accentColor: likeAccent,
                          onTap: () {
                            final user =
                                context.read<UserProvider>().currentUser;
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
                        BoardActionTile(
                          icon: scrapped
                              ? Icons.bookmark
                              : Icons.bookmark_outline,
                          label: '스크랩',
                          selected: scrapped,
                          accentColor: scrapAccent,
                          onTap: () {
                            final user =
                                context.read<UserProvider>().currentUser;
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
                      BoardCommentsEmptyState(onTap: _focusCommentInput),
                    ] else ...[
                      const SizedBox(height: 8),
                      ..._buildStructuredComments(comments, post.authorId),
                    ],
                    const SizedBox(height: 280),
                  ],
                ),
              ),
            ),
            BoardCommentInputBar(
              replyingTo: provider.replyingTo,
              onCancelReply: () => provider.setReplyingTo(null),
              controller: _commentController,
              focusNode: _commentFocusNode,
              onFocusInput: _focusCommentInput,
              onChanged: (_) => setState(() {}),
              onSubmit: _submitComment,
              canSubmit: _canSubmitComment,
              sendAccent: sendAccent,
              backgroundColor: backgroundColor,
            ),
          ],
        ),
      ),
    );
  }

  List<Widget> _buildStructuredComments(
      List<Comment> allComments, String postAuthorId) {
    // 1-Depth 구조 만들기
    final parentComments =
        allComments.where((c) => c.parentId == null).toList();
    final childComments = allComments.where((c) => c.parentId != null).toList();

    final List<Widget> widgets = [];
    for (var parent in parentComments) {
      widgets.add(_buildCommentItem(parent, postAuthorId, isReply: false));

      final children =
          childComments.where((c) => c.parentId == parent.id).toList();
      for (var child in children) {
        widgets.add(_buildCommentItem(child, postAuthorId, isReply: true));
      }
    }
    return widgets;
  }

  Widget _buildCommentItem(Comment comment, String postAuthorId,
      {required bool isReply}) {
    final currentUser = context.read<UserProvider>().currentUser;
    final isMyComment =
        currentUser != null && comment.authorId == currentUser.id;
    final provider = context.watch<CommunityProvider>();
    final isLiked = provider.likedCommentIds.contains(comment.id);

    return BoardCommentItem(
      comment: comment,
      isReply: isReply,
      isAuthor: comment.authorId == postAuthorId,
      isMyComment: isMyComment,
      isLiked: isLiked,
      currentUser: currentUser,
      cachedUser: provider.getCachedUser(comment.authorId),
      onLike: () {
        if (currentUser == null) return;
        context
            .read<CommunityProvider>()
            .toggleCommentLike(widget.postId, comment.id, currentUser.id);
      },
      onReply: () {
        context.read<CommunityProvider>().setReplyingTo(comment);
        _focusCommentInput();
      },
      onMore: () => _showCommentOptionsSheet(comment),
      formatTimeAgo: _formatTimeAgo,
    );
  }
}
