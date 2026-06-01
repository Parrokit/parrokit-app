part of 'community_provider.dart';

extension CommunityProviderPost on CommunityProvider {
  List<Post> getBoardPostsByFilter(String selectedFilter) {
    final boardPosts = _posts.where((post) => post.postType == 'board');
    if (selectedFilter == '전체') {
      return boardPosts.toList();
    }
    return boardPosts.where((post) => post.category == selectedFilter).toList();
  }

  Future<void> fetchPosts({String? postType, bool refresh = false}) async {
    if (_isLoading) return;

    if (postType != null) {
      _currentPostType = postType;
    }

    if (refresh) {
      _lastDocument = null;
      _posts.clear();
      _userCache.clear();
    }

    _isLoading = true;
    _errorMessage = null;
    _notifyListenersSafe();

    try {
      final fetchedPosts = await _repository.getPosts(
        postType: _currentPostType,
        limit: 20,
        startAfter: _lastDocument,
      );
      _posts.addAll(fetchedPosts);

      await _fetchMissingUsers(fetchedPosts.map((p) => p.authorId).whereType<String>());
    } catch (e) {
      _errorMessage = e.toString();
    } finally {
      _isLoading = false;
      _notifyListenersSafe();
    }
  }

  Future<void> fetchPostDetails(String postId) async {
    if (_posts.any((p) => p.id == postId)) return;

    try {
      final post = await _repository.getPostById(postId);
      if (post != null) {
        _posts = List.from(_posts)..add(post);

        await _fetchMissingUsers([post.authorId]);

        _notifyListenersSafe();
      }
    } catch (e) {
      _errorMessage = e.toString();
    }
  }

  Future<bool> addPost(
    String title,
    String content,
    String category, {
    String postType = 'board',
    required String authorId,
    required String authorNickname,
    String? authorAvatarUrl,
    List<String> tags = const [],
    List<File> imageFiles = const [],
    List<VoteOption>? voteOptions,
    DateTime? voteEndTime,
    void Function(int current, int total, double progress)? onImageProgress,
  }) async {
    _isLoading = true;
    _errorMessage = null;
    _notifyListenersSafe();

    try {
      await addPostUseCase.execute(
        title: title,
        content: content,
        category: category,
        postType: postType,
        authorId: authorId,
        authorNickname: authorNickname,
        authorAvatarUrl: authorAvatarUrl,
        tags: tags,
        imageFiles: imageFiles,
        voteOptions: voteOptions,
        voteEndTime: voteEndTime,
        onImageProgress: onImageProgress,
      );

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

  Future<bool> editPost(
    String postId, {
    required String title,
    required String content,
    required String category,
    required List<String> tags,
    required List<String> existingImageUrls,
    required List<File> newImageFiles,
    required String authorId,
    void Function(int current, int total, double progress)? onImageProgress,
  }) async {
    _isLoading = true;
    _errorMessage = null;
    _notifyListenersSafe();

    try {
      final postToEdit = _posts.firstWhere((p) => p.id == postId);
      
      await editPostUseCase.execute(
        existingPost: postToEdit,
        title: title,
        content: content,
        category: category,
        tags: tags,
        existingImageUrls: existingImageUrls,
        newImageFiles: newImageFiles,
        authorId: authorId,
        onImageProgress: onImageProgress,
      );

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

  Future<bool> deletePost(String postId) async {
    _isLoading = true;
    _errorMessage = null;
    _notifyListenersSafe();

    try {
      final postToDelete = _posts.firstWhere((p) => p.id == postId);
      await deletePostUseCase.execute(postToDelete);
      
      _posts.removeWhere((post) => post.id == postId);

      _isLoading = false;
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
