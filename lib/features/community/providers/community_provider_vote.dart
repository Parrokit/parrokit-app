part of 'community_provider.dart';

extension CommunityProviderVote on CommunityProvider {
  // 여러 투표글에 대한 내 투표 기록 일괄 조회 및 캐싱
  Future<void> fetchMyVotes(String userId) async {
    final votePosts = _posts.where((p) => p.postType == 'vote').map((p) => p.id).toList();
    if (votePosts.isEmpty) return;

    final fetchedVotes = await _repository.getMyVotes(userId, votePosts);
    myVotes.addAll(fetchedVotes);
    _notifyListenersSafe();
  }

  // 투표하기 (낙관적 UI 업데이트 포함)
  Future<bool> votePost(String postId, int optionIndex, String userId) async {
    _isLoading = true;
    _errorMessage = null;
    _notifyListenersSafe();

    try {
      await _repository.votePost(postId, userId, optionIndex);

      myVotes[postId] = optionIndex;

      final postIndex = _posts.indexWhere((p) => p.id == postId);
      if (postIndex != -1) {
        final post = _posts[postIndex];
        if (post.voteOptions != null) {
          final newOptions = List<VoteOption>.from(post.voteOptions!);
          if (optionIndex >= 0 && optionIndex < newOptions.length) {
            newOptions[optionIndex] = VoteOption(
              id: newOptions[optionIndex].id,
              text: newOptions[optionIndex].text,
              count: newOptions[optionIndex].count + 1,
            );
            _posts[postIndex] = post.copyWith(voteOptions: newOptions);
          }
        }
      }

      _isLoading = false;
      _notifyListenersSafe();
      return true;
    } catch (e) {
      _isLoading = false;
      _errorMessage = e.toString();
      _notifyListenersSafe();
      return false;
    }
  }
}
