import 'package:parrokit/features/community/shell/data/repositories/community_repository.dart';

class DeleteCommentUseCase {
  final CommunityRepository _repository;

  DeleteCommentUseCase(this._repository);

  Future<void> execute(String postId, String commentId) async {
    await _repository.deleteComment(postId, commentId);
  }
}
