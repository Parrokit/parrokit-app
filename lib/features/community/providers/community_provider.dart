// lib/features/community/providers/community_provider.dart
import 'package:flutter/foundation.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:parrokit/data/models/post.dart';
import 'package:parrokit/data/models/comment.dart';
import 'package:parrokit/features/community/data/repositories/community_repository.dart';
import 'dart:io';
import 'package:firebase_storage/firebase_storage.dart';

class CommunityProvider with ChangeNotifier {
  final CommunityRepository _repository = CommunityRepository();

  List<Post> _posts = [];
  List<Post> get posts => _posts;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  String? _errorMessage;
  String? get errorMessage => _errorMessage;

  DocumentSnapshot? _lastDocument;

  List<Comment> _currentPostComments = [];
  List<Comment> get currentPostComments => _currentPostComments;

  Set<String> _likedCommentIds = {};
  Set<String> get likedCommentIds => _likedCommentIds;

  Comment? _replyingTo;
  Comment? get replyingTo => _replyingTo;

  void setReplyingTo(Comment? comment) {
    _replyingTo = comment;
    notifyListeners();
  }

  bool _isCurrentPostLiked = false;
  bool get isCurrentPostLiked => _isCurrentPostLiked;

  bool _isCurrentPostScrapped = false;
  bool get isCurrentPostScrapped => _isCurrentPostScrapped;

  // 게시글 목록 가져오기
  Future<void> fetchPosts({bool refresh = false}) async {
    if (_isLoading) return;

    if (refresh) {
      _lastDocument = null;
      _posts.clear();
    }

    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final fetchedPosts = await _repository.getPosts(limit: 20, startAfter: _lastDocument);
      _posts.addAll(fetchedPosts);
      // MVP 단계에서는 단순 갱신을 위해 lastDocument를 엄격하게 다루지 않습니다.
    } catch (e) {
      _errorMessage = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // 단일 게시글 1개 로드 (딥링크 등으로 접근했거나 강제 로드 시)
  Future<void> fetchPostDetails(String postId) async {
    if (_posts.any((p) => p.id == postId)) return;
    
    try {
      final post = await _repository.getPostById(postId);
      if (post != null) {
        _posts = List.from(_posts)..add(post);
        notifyListeners();
      }
    } catch (e) {
      _errorMessage = e.toString();
    }
  }

  // 게시글 추가하기
  Future<bool> addPost(
    String title,
    String content,
    String category, {
    required String authorId,
    required String authorNickname,
    List<String> tags = const [],
    List<File> imageFiles = const [],
  }) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final String postId = _repository.generatePostId();

      List<String> uploadedUrls = [];
      for (final file in imageFiles) {
        final url = await uploadImageToStorage(
          file, 
          userId: authorId, 
          postId: postId
        );
        if (url != null) {
          uploadedUrls.add(url);
        }
      }

      final newPost = Post(
        id: postId, // 발급받은 ID 사용
        postType: 'board',
        category: category,
        title: title,
        content: content,
        tags: tags,
        hasImage: uploadedUrls.isNotEmpty,
        imageUrls: uploadedUrls,
        authorId: authorId,
        authorNickname: authorNickname,
        snippet: content.length > 50 ? '${content.substring(0, 50)}...' : content,
      );

      await _repository.addPost(newPost);
      
      // 로딩 상태를 풀어주어야 fetchPosts 내부의 방어 로직(if isLoading return)을 통과합니다.
      _isLoading = false; 
      
      // 최신 데이터를 서버에서 깔끔하게 다시 가져옵니다. (다른 유저의 새 글 포함)
      await fetchPosts(refresh: true);
      
      return true;
    } catch (e) {
      _errorMessage = e.toString();
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  // 게시글 삭제하기
  Future<bool> deletePost(String postId) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      await _repository.deletePost(postId);
      // 로컬 리스트에서도 즉시 제거 (낙관적 업데이트)
      _posts.removeWhere((post) => post.id == postId);
      
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = e.toString();
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  // 이미지 업로드 로직 (폴더 구조화)
  Future<String?> uploadImageToStorage(File imageFile, {required String userId, required String postId}) async {
    try {
      final String fileName = '${DateTime.now().millisecondsSinceEpoch}.jpg';
      final String path = 'users/$userId/posts/$postId/$fileName';
      final Reference ref = FirebaseStorage.instance.ref().child(path);
      final UploadTask uploadTask = ref.putFile(imageFile);
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
    _replyingTo = null; // 초기화
    
    try {
      final comments = await _repository.getComments(postId);
      _currentPostComments.addAll(comments);

      if (currentUserId != null) {
        _likedCommentIds = await _repository.getLikedCommentIds(currentUserId);
      } else {
        _likedCommentIds.clear();
      }

      notifyListeners();
    } catch (e) {
      _errorMessage = e.toString();
      notifyListeners();
    }
  }

  // 댓글 추가하기
  Future<bool> addComment(
    String postId, 
    String content, {
    required String authorId,
    required String authorNickname,
  }) async {
    try {
      final newComment = Comment(
        id: '', // Repository에서 자동 생성
        authorId: authorId,
        authorNickname: authorNickname,
        content: content,
        parentId: _replyingTo?.parentId ?? _replyingTo?.id,
        replyToNickname: _replyingTo != null ? _replyingTo!.authorNickname : null,
      );

      final createdComment = await _repository.addComment(postId, newComment);
      
      // 대댓글 입력 상태 초기화
      _replyingTo = null;

      // 낙관적 업데이트: 화면 리스트에 추가 (새로운 리스트 객체로 할당하여 확실하게 UI 갱신 유도)
      _currentPostComments = List.from(_currentPostComments)..add(createdComment);
      
      // 게시글의 총 댓글 수 로컬 증가
      final postIndex = _posts.indexWhere((p) => p.id == postId);
      if (postIndex != -1) {
        final p = _posts[postIndex];
        _posts[postIndex] = p.copyWith(commentCount: p.commentCount + 1);
      }
      
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = e.toString();
      notifyListeners();
      return false;
    }
  }

  // 댓글 삭제 (소프트 딜리트)
  Future<bool> deleteComment(String postId, String commentId) async {
    try {
      await _repository.deleteComment(postId, commentId);
      
      // 로컬 제거 대신 내용 변경 (새로운 리스트로 재할당)
      final index = _currentPostComments.indexWhere((c) => c.id == commentId);
      if (index != -1) {
        final deletedComment = _currentPostComments[index].copyWith(
          status: 'deleted',
          content: '이 댓글은 삭제된 댓글입니다.',
        );
        _currentPostComments = List.from(_currentPostComments)
          ..[index] = deletedComment;
      }
      
      // Note: 소프트 딜리트이므로 게시글 총 댓글 수(commentCount)는 로컬에서 감소시키지 않음

      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = e.toString();
      notifyListeners();
      return false;
    }
  }

  // 댓글 좋아요 토글
  Future<void> toggleCommentLike(String postId, String commentId, String userId) async {
    final isLiked = _likedCommentIds.contains(commentId);
    final targetState = !isLiked;

    // 낙관적 업데이트 (UI 먼저 즉각 반영)
    if (targetState) {
      _likedCommentIds.add(commentId);
    } else {
      _likedCommentIds.remove(commentId);
    }
    
    final commentIndex = _currentPostComments.indexWhere((c) => c.id == commentId);
    if (commentIndex != -1) {
      final c = _currentPostComments[commentIndex];
      _currentPostComments[commentIndex] = c.copyWith(likeCount: c.likeCount + (targetState ? 1 : -1));
    }
    notifyListeners();

    try {
      await _repository.toggleCommentLike(postId, commentId, userId, targetState);
    } catch (e) {
      // 롤백
      if (!targetState) {
        _likedCommentIds.add(commentId);
      } else {
        _likedCommentIds.remove(commentId);
      }
      if (commentIndex != -1) {
        final c = _currentPostComments[commentIndex];
        _currentPostComments[commentIndex] = c.copyWith(likeCount: c.likeCount + (!targetState ? 1 : -1));
      }
      _errorMessage = e.toString();
      notifyListeners();
    }
  }

  // 뷰 화면 진입 시 사용자 액션(좋아요, 스크랩 여부) 로드
  Future<void> loadUserActions(String postId) async {
    _isCurrentPostLiked = false;
    _isCurrentPostScrapped = false;
    // UI 초기화를 위해 먼저 리스너 호출
    notifyListeners();
    
    try {
      final actions = await _repository.getUserPostActions(postId, 'temp_user_id');
      _isCurrentPostLiked = actions['isLiked'] ?? false;
      _isCurrentPostScrapped = actions['isScrapped'] ?? false;
      notifyListeners();
    } catch (e) {
      // 조용히 넘어감
    }
  }

  // 조회수 증가 로직 (24시간 로컬 캐싱)
  Future<void> incrementViewCount(String postId) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final key = 'viewed_$postId';
      final lastViewedStr = prefs.getString(key);
      
      bool shouldIncrement = false;
      
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
        
        // 로컬 상태 즉시 업데이트
        final postIndex = _posts.indexWhere((p) => p.id == postId);
        if (postIndex != -1) {
          final p = _posts[postIndex];
          _posts[postIndex] = p.copyWith(viewCount: p.viewCount + 1);
          notifyListeners();
        }
      }
    } catch (e) {
      // 조회수 증가는 에러가 나도 조용히 넘어감
    }
  }

  // 좋아요 토글 (낙관적 업데이트 적용)
  Future<void> toggleLike(String postId) async {
    final originalState = _isCurrentPostLiked;
    _isCurrentPostLiked = !_isCurrentPostLiked;
    
    // 로컬 상태 즉시 업데이트
    final postIndex = _posts.indexWhere((p) => p.id == postId);
    if (postIndex != -1) {
      final p = _posts[postIndex];
      _posts[postIndex] = p.copyWith(likeCount: p.likeCount + (_isCurrentPostLiked ? 1 : -1));
    }
    notifyListeners();
    
    try {
      await _repository.toggleLike(postId, 'temp_user_id', _isCurrentPostLiked);
    } catch (e) {
      // 실패 시 롤백
      _isCurrentPostLiked = originalState;
      if (postIndex != -1) {
        final p = _posts[postIndex];
        _posts[postIndex] = p.copyWith(likeCount: p.likeCount + (_isCurrentPostLiked ? 1 : -1));
      }
      _errorMessage = '추천 처리에 실패했습니다.';
      notifyListeners();
    }
  }

  // 스크랩 토글 (낙관적 업데이트 적용)
  Future<void> toggleScrap(String postId) async {
    final originalState = _isCurrentPostScrapped;
    _isCurrentPostScrapped = !_isCurrentPostScrapped;
    
    // 로컬 상태 즉시 업데이트
    final postIndex = _posts.indexWhere((p) => p.id == postId);
    if (postIndex != -1) {
      final p = _posts[postIndex];
      _posts[postIndex] = p.copyWith(scrapCount: p.scrapCount + (_isCurrentPostScrapped ? 1 : -1));
    }
    notifyListeners();
    
    try {
      await _repository.toggleScrap(postId, 'temp_user_id', _isCurrentPostScrapped);
    } catch (e) {
      // 실패 시 롤백
      _isCurrentPostScrapped = originalState;
      if (postIndex != -1) {
        final p = _posts[postIndex];
        _posts[postIndex] = p.copyWith(scrapCount: p.scrapCount + (_isCurrentPostScrapped ? 1 : -1));
      }
      _errorMessage = '스크랩 처리에 실패했습니다.';
      notifyListeners();
    }
  }
}
