import 'package:parrokit/features/community/shell/data/repositories/community_repository.dart';

class VotePostUseCase {
  final CommunityRepository _repository;

  VotePostUseCase(this._repository);

  Future<void> execute(String postId, String userId, int optionIndex) async {
    await _repository.votePost(postId, userId, optionIndex);
  }
}
