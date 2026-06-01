part of 'community_provider.dart';

extension CommunityProviderComment on CommunityProvider {
  // 이미지 업로드 로직 (폴더 구조화 및 진행률 추적)
  Future<String?> uploadImageToStorage(
    File imageFile, {
    required String userId,
    required String postId,
    void Function(double progress)? onProgress,
  }) async {
    try {
      final String fileName = '${DateTime.now().millisecondsSinceEpoch}.jpg';
      final String path = 'users/$userId/posts/$postId/$fileName';
      final Reference ref = FirebaseStorage.instance.ref().child(path);

      final UploadTask uploadTask = ref.putFile(imageFile);

      if (onProgress != null) {
        uploadTask.snapshotEvents.listen((TaskSnapshot snapshot) {
          final double progress = snapshot.totalBytes == 0
              ? 0.0
              : snapshot.bytesTransferred / snapshot.totalBytes;
          onProgress(progress);
        });
      }

      final TaskSnapshot snapshot = await uploadTask;
      final String downloadUrl = await snapshot.ref.getDownloadURL();
      return downloadUrl;
    } catch (e) {
      debugPrint('Error uploading image: $e');
      return null;
    }
  }

  // 이미지 삭제 로직
  Future<bool> deleteImageFromStorage(String imageUrl) async {
    try {
      final Reference ref = FirebaseStorage.instance.refFromURL(imageUrl);
      await ref.delete();
      return true;
    } catch (e) {
      debugPrint('Error deleting image: $e');
      return false;
    }
  }

  // 특정 게시글의 댓글 목록 가져오기 (현재 로그인된 유저 ID도 받아와서 좋아요 상태 셋팅)
  Future<void> fetchComments(String postId, {String? currentUserId}) async {
    _currentPostComments.clear();
    _replyingTo = null;

    try {
      final comments = await _repository.getComments(postId);
      _currentPostComments.addAll(comments);

      await _fetchMissingUsers(comments.map((c) => c.authorId).whereType<String>());

      if (currentUserId != null) {
        _likedCommentIds = await _repository.getLikedCommentIds(currentUserId);
      } else {
        _likedCommentIds.clear();
      }

      _notifyListenersSafe();
    } catch (e) {
      _errorMessage = e.toString();
      _notifyListenersSafe();
    }
  }

  Future<bool> addComment(
    String postId,
    String content, {
    required String authorId,
    required String authorNickname,
    String? authorAvatarUrl,
  }) async {
    try {
      final newComment = Comment(
        id: '',
        authorId: authorId,
        authorNickname: authorNickname,
        authorAvatarUrl: authorAvatarUrl,
        content: content,
        parentId: _replyingTo?.parentId ?? _replyingTo?.id,
        replyToNickname: _replyingTo?.authorNickname,
      );

      final createdComment = await _repository.addComment(postId, newComment);

      _replyingTo = null;
      _currentPostComments = List.from(_currentPostComments)..add(createdComment);

      final postIndex = _posts.indexWhere((p) => p.id == postId);
      if (postIndex != -1) {
        final p = _posts[postIndex];
        _posts[postIndex] = p.copyWith(commentCount: p.commentCount + 1);
      }

      _notifyListenersSafe();
      return true;
    } catch (e) {
      _errorMessage = e.toString();
      _notifyListenersSafe();
      return false;
    }
  }

  Future<bool> deleteComment(String postId, String commentId) async {
    try {
      await _repository.deleteComment(postId, commentId);

      final index = _currentPostComments.indexWhere((c) => c.id == commentId);
      if (index != -1) {
        final deletedComment = _currentPostComments[index].copyWith(
          status: 'deleted',
          content: '이 댓글은 삭제된 댓글입니다.',
        );
        _currentPostComments = List.from(_currentPostComments)..[index] = deletedComment;
      }

      _notifyListenersSafe();
      return true;
    } catch (e) {
      _errorMessage = e.toString();
      _notifyListenersSafe();
      return false;
    }
  }

  Future<void> toggleCommentLike(String postId, String commentId, String userId) async {
    final isLiked = _likedCommentIds.contains(commentId);
    final targetState = !isLiked;

    if (targetState) {
      _likedCommentIds.add(commentId);
    } else {
      _likedCommentIds.remove(commentId);
    }

    final commentIndex = _currentPostComments.indexWhere((c) => c.id == commentId);
    if (commentIndex != -1) {
      final c = _currentPostComments[commentIndex];
      _currentPostComments[commentIndex] =
          c.copyWith(likeCount: c.likeCount + (targetState ? 1 : -1));
    }
    _notifyListenersSafe();

    try {
      await _repository.toggleCommentLike(postId, commentId, userId, targetState);
    } catch (e) {
      if (!targetState) {
        _likedCommentIds.add(commentId);
      } else {
        _likedCommentIds.remove(commentId);
      }
      if (commentIndex != -1) {
        final c = _currentPostComments[commentIndex];
        _currentPostComments[commentIndex] =
            c.copyWith(likeCount: c.likeCount + (!targetState ? 1 : -1));
      }
      _errorMessage = e.toString();
      _notifyListenersSafe();
    }
  }
}
