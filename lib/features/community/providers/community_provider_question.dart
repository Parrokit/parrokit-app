part of 'community_provider.dart';

extension CommunityProviderQuestion on CommunityProvider {
  Future<bool> addQuestion({
    required String title,
    required String content,
    required String category,
    required String authorId,
    required String authorNickname,
    required int rewardCrackers,
    required DateTime expireAt,
    String? authorAvatarUrl,
    List<String> tags = const [],
    List<File> imageFiles = const [],
    void Function(int current, int total, double progress)? onImageProgress,
  }) async {
    _isLoading = true;
    _errorMessage = null;
    _notifyListenersSafe();

    try {
      final String postId = _repository.generatePostId();

      List<String> uploadedUrls = [];
      for (int i = 0; i < imageFiles.length; i++) {
        final file = imageFiles[i];
        final url = await uploadImageToStorage(
          file,
          userId: authorId,
          postId: postId,
          onProgress: (progress) {
            if (onImageProgress != null) {
              onImageProgress(i + 1, imageFiles.length, progress);
            }
          },
        );
        if (url != null) {
          uploadedUrls.add(url);
        }
      }

      final newPost = Post(
        id: postId,
        postType: 'question',
        category: category,
        title: title,
        content: content,
        tags: tags,
        hasImage: uploadedUrls.isNotEmpty,
        imageUrls: uploadedUrls,
        authorId: authorId,
        authorNickname: authorNickname,
        authorAvatarUrl: authorAvatarUrl,
        snippet: content.length > 50 ? '${content.substring(0, 50)}...' : content,
        rewardCrackers: rewardCrackers,
        expireAt: expireAt,
        questionStatus: 'waiting',
      );

      await _repository.addQuestion(newPost, authorId, rewardCrackers);

      _isLoading = false;
      await fetchPosts(refresh: true);
      return true;
    } catch (e) {
      _errorMessage = e.toString();
      _isLoading = false;
      _notifyListenersSafe();
      return false;
    }
  }

  Future<bool> acceptAnswer({
    required String postId,
    required String commentId,
    required String answererId,
    required int rewardCrackers,
  }) async {
    _isLoading = true;
    _errorMessage = null;
    _notifyListenersSafe();

    try {
      await _repository.acceptAnswer(
        postId: postId,
        commentId: commentId,
        answererId: answererId,
        rewardCrackers: rewardCrackers,
      );

      _isLoading = false;

      final postIndex = _posts.indexWhere((p) => p.id == postId);
      if (postIndex != -1) {
        _posts[postIndex] = _posts[postIndex].copyWith(
          questionStatus: 'resolved',
          acceptedCommentId: commentId,
        );
      }

      final commentIndex = _currentPostComments.indexWhere((c) => c.id == commentId);
      if (commentIndex != -1) {
        _currentPostComments[commentIndex] = _currentPostComments[commentIndex].copyWith(
          isAccepted: true,
        );
      }

      _notifyListenersSafe();
      return true;
    } catch (e) {
      _errorMessage = e.toString();
      _isLoading = false;
      _notifyListenersSafe();
      return false;
    }
  }
}
