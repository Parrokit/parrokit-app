// lib/features/community/providers/community_provider.dart
import 'package:flutter/foundation.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:parrokit/data/models/post.dart';
import 'package:parrokit/data/models/comment.dart';
import 'package:parrokit/features/community/data/repositories/community_repository.dart';

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

  // 게시글 추가하기
  Future<bool> addPost(String title, String content, String category) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      // 임시 작성자 데이터 (MVP 용 하드코딩)
      final newPost = Post(
        id: '', // Repository에서 생성됨
        postType: 'board',
        category: category,
        title: title,
        content: content,
        authorId: 'temp_user_id',
        authorNickname: '파로킷테스터',
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

  // 특정 게시글의 댓글 목록 가져오기
  Future<void> fetchComments(String postId) async {
    _currentPostComments.clear();
    try {
      final comments = await _repository.getComments(postId);
      _currentPostComments.addAll(comments);
      notifyListeners();
    } catch (e) {
      _errorMessage = e.toString();
      notifyListeners();
    }
  }

  // 댓글 추가하기
  Future<bool> addComment(String postId, String content) async {
    try {
      final newComment = Comment(
        id: '', // Repository에서 자동 생성
        authorId: 'temp_user_id', // 임시 유저
        authorNickname: '파로킷테스터',
        content: content,
      );

      final createdComment = await _repository.addComment(postId, newComment);
      
      // 낙관적 업데이트: 화면 맨 아래에 즉시 추가
      _currentPostComments.add(createdComment);
      
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
}
