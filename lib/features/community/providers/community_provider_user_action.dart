part of 'community_provider.dart';

extension CommunityProviderUserAction on CommunityProvider {
  Future<void> loadUserActions(String postId, {String? userId}) async {
    _isCurrentPostLiked = false;
    _isCurrentPostScrapped = false;
    _notifyListenersSafe();

    if (userId == null) return;

    try {
      final actions = await _repository.getUserPostActions(postId, userId);
      _isCurrentPostLiked = actions['isLiked'] ?? false;
      _isCurrentPostScrapped = actions['isScrapped'] ?? false;
      _notifyListenersSafe();
    } catch (e) {
      // noop
    }
  }

  Future<void> incrementViewCount(String postId, {String? userId}) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final key = 'viewed_${userId ?? "guest"}_$postId';
      final lastViewedStr = prefs.getString(key);

      var shouldIncrement = false;

      if (lastViewedStr == null) {
        shouldIncrement = true;
      } else {
        final lastViewed = DateTime.parse(lastViewedStr);
        if (DateTime.now().difference(lastViewed).inHours >= 24) {
          shouldIncrement = true;
        }
      }

      if (shouldIncrement) {
        await _repository.incrementViewCount(postId);
        await prefs.setString(key, DateTime.now().toIso8601String());

        final postIndex = _posts.indexWhere((p) => p.id == postId);
        if (postIndex != -1) {
          final p = _posts[postIndex];
          _posts[postIndex] = p.copyWith(viewCount: p.viewCount + 1);
          _notifyListenersSafe();
        }
      }
    } catch (e) {
      // noop
    }
  }

  Future<void> toggleLike(String postId, String userId) async {
    final originalState = _isCurrentPostLiked;
    _isCurrentPostLiked = !_isCurrentPostLiked;

    final postIndex = _posts.indexWhere((p) => p.id == postId);
    if (postIndex != -1) {
      final p = _posts[postIndex];
      _posts[postIndex] = p.copyWith(likeCount: p.likeCount + (_isCurrentPostLiked ? 1 : -1));
    }
    _notifyListenersSafe();

    try {
      await _repository.toggleLike(postId, userId, _isCurrentPostLiked);
    } catch (e) {
      _isCurrentPostLiked = originalState;
      if (postIndex != -1) {
        final p = _posts[postIndex];
        _posts[postIndex] = p.copyWith(likeCount: p.likeCount + (_isCurrentPostLiked ? 1 : -1));
      }
      _errorMessage = '추천 처리에 실패했습니다.';
      _notifyListenersSafe();
    }
  }

  Future<void> toggleScrap(String postId, String userId) async {
    final originalState = _isCurrentPostScrapped;
    _isCurrentPostScrapped = !_isCurrentPostScrapped;

    final postIndex = _posts.indexWhere((p) => p.id == postId);
    if (postIndex != -1) {
      final p = _posts[postIndex];
      _posts[postIndex] = p.copyWith(
        scrapCount: p.scrapCount + (_isCurrentPostScrapped ? 1 : -1),
      );
    }
    _notifyListenersSafe();

    try {
      await _repository.toggleScrap(postId, userId, _isCurrentPostScrapped);
    } catch (e) {
      _isCurrentPostScrapped = originalState;
      if (postIndex != -1) {
        final p = _posts[postIndex];
        _posts[postIndex] = p.copyWith(
          scrapCount: p.scrapCount + (_isCurrentPostScrapped ? 1 : -1),
        );
      }
      _errorMessage = '스크랩 처리에 실패했습니다.';
      _notifyListenersSafe();
    }
  }
}
