import 'package:parrokit/features/community/shell/data/repositories/community_repository.dart';

class AcceptAnswerUseCase {
  final CommunityRepository _repository;

  AcceptAnswerUseCase(this._repository);

  Future<void> execute({
    required String postId,
    required String commentId,
    required String answererId,
    required int rewardCrackers,
  }) async {
    // Add any complex validation here if needed
    // e.g., verify that the user accepting the answer is the author of the post.

    await _repository.acceptAnswer(
      postId: postId,
      commentId: commentId,
      answererId: answererId,
      rewardCrackers: rewardCrackers,
    );
  }
}
