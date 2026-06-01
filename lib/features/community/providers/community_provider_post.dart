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
        postType: postType,
        category: category,
        title: title,
        content: content,
        tags: tags,
        hasImage: uploadedUrls.isNotEmpty,
        imageUrls: uploadedUrls,
        authorId: authorId,
        authorNickname: authorNickname,
        authorAvatarUrl: authorAvatarUrl,
        voteOptions: voteOptions,
        voteEndTime: voteEndTime,
        snippet: content.length > 50 ? '${content.substring(0, 50)}...' : content,
      );
      await _repository.addPost(newPost);

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

      final deletedImageUrls =
          postToEdit.imageUrls.where((url) => !existingImageUrls.contains(url)).toList();
      for (final url in deletedImageUrls) {
        try {
          final ref = FirebaseStorage.instance.refFromURL(url);
          await ref.delete();
        } catch (e) {
          debugPrint('기존 스토리지 이미지 삭제 실패: $url, $e');
        }
      }

      List<String> newUploadedUrls = [];
      for (int i = 0; i < newImageFiles.length; i++) {
        final file = newImageFiles[i];
        final url = await uploadImageToStorage(
          file,
          userId: authorId,
          postId: postId,
          onProgress: (progress) {
            if (onImageProgress != null) {
              onImageProgress(i + 1, newImageFiles.length, progress);
            }
          },
        );
        if (url != null) {
          newUploadedUrls.add(url);
        }
      }

      final finalImageUrls = [...existingImageUrls, ...newUploadedUrls];

      final updateData = {
        'title': title,
        'content': content,
        'category': category,
        'tags': tags,
        'hasImage': finalImageUrls.isNotEmpty,
        'imageUrls': finalImageUrls,
        'snippet': content.length > 50 ? '${content.substring(0, 50)}...' : content,
      };

      await _repository.updatePost(postId, updateData);

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
      try {
        final postToDelete = _posts.firstWhere((p) => p.id == postId);
        if (postToDelete.hasImage) {
          for (final url in postToDelete.imageUrls) {
            try {
              final ref = FirebaseStorage.instance.refFromURL(url);
              await ref.delete();
            } catch (e) {
              debugPrint('스토리지 이미지 삭제 실패: $url, $e');
            }
          }
        }
      } catch (e) {
        debugPrint('로컬에서 게시글을 찾지 못해 이미지 삭제 건너뜀: $e');
      }

      await _repository.deletePost(postId);
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
