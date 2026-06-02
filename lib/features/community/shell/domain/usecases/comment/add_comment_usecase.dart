import 'package:parrokit/data/models/comment.dart';
import 'package:parrokit/features/community/shell/data/repositories/community_repository.dart';
import 'package:parrokit/features/community/shell/domain/validators/comment_validator.dart';

class AddCommentUseCase {
  final CommunityRepository _repository;

  AddCommentUseCase(this._repository);

  Future<Comment> execute(
    String postId,
    String content, {
    required String postType,
    required String authorId,
    required String authorNickname,
    String? authorAvatarUrl,
    Comment? replyingTo,
  }) async {
    CommentValidator.validateForCreate(content);

    final newComment = Comment(
      id: '',
      authorId: authorId,
      authorNickname: authorNickname,
      authorAvatarUrl: authorAvatarUrl,
      content: content,
      parentId: replyingTo?.parentId ?? replyingTo?.id,
      replyToNickname: replyingTo?.authorNickname,
      postId: postId,
      postType: postType,
    );

    final createdComment = await _repository.addComment(postId, newComment);
    return createdComment;
  }
}
