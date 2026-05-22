// lib/features/community/providers/community_provider.dart
import 'package:flutter/foundation.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:parrokit/data/models/post.dart';
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
      
      // 작성 성공 후 목록 새로고침
      await fetchPosts(refresh: true);
      return true;
    } catch (e) {
      _errorMessage = e.toString();
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }
}
