// lib/features/community/providers/community_provider.dart
import 'package:flutter/foundation.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:parrokit/core/services/firebase/firebase_user_service.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:parrokit/data/models/post.dart';
import 'package:parrokit/data/models/comment.dart';
import 'package:parrokit/features/community/data/repositories/community_repository.dart';
import 'package:parrokit/data/models/user.dart';
import 'package:parrokit/data/models/vote_option.dart';
import 'dart:io';
import 'package:firebase_storage/firebase_storage.dart';

class CommunityProvider with ChangeNotifier {
  final CommunityRepository _repository = CommunityRepository();
  final FirebaseUserService _userService = FirebaseUserService();

  final Map<String, AppUser> _userCache = {};

  AppUser? getCachedUser(String uid) => _userCache[uid];

  Future<void> _fetchMissingUsers(Iterable<String> uids) async {
    final missingUids = uids
        .where((uid) => !_userCache.containsKey(uid) && uid.isNotEmpty)
        .toSet();
    if (missingUids.isEmpty) return;

    await Future.wait(missingUids.map((uid) async {
      try {
        final user = await _userService.loadUserDocument(uid: uid);
        if (user != null) {
          _userCache[uid] = user;
        } else {
          // 유저를 찾지 못했어도 계속 호출하는 것을 막기 위해 임시 객체를 캐싱
          _userCache[uid] = AppUser(id: uid, displayName: '알 수 없음', email: '');
        }
      } catch (_) {
        // 에러 발생 시 캐싱 생략 (다음 번에 재시도 가능하도록)
      }
    }));
  }

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

  // 내 투표 기록 캐시 (postId -> 선택한 optionIndex)
  Map<String, int> myVotes = {};

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

  // 로그아웃 시 모든 데이터 초기화
  void clear() {
    _posts.clear();
    _isLoading = false;
    _errorMessage = null;
    _lastDocument = null;
    _currentPostComments.clear();
    _likedCommentIds.clear();
    _replyingTo = null;
    _isCurrentPostLiked = false;
    _isCurrentPostScrapped = false;
    myVotes.clear();
    notifyListeners();
  }

  String _currentPostType = 'board';

  // 게시글 목록 가져오기
  Future<void> fetchPosts({String? postType, bool refresh = false}) async {
    if (_isLoading) return;

    if (postType != null) {
      _currentPostType = postType;
    }

    if (refresh) {
      _lastDocument = null;
      _posts.clear();
      _userCache.clear(); // 새로고침 시 유저 캐시도 비워서 최신 프사를 가져오도록 함
    }

    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final fetchedPosts =
          await _repository.getPosts(postType: _currentPostType, limit: 20, startAfter: _lastDocument);
      _posts.addAll(fetchedPosts);

      // 게시글 목록에 포함된 작성자들의 프로필 정보 동적으로 불러오기 (캐시)
      await _fetchMissingUsers(
          fetchedPosts.map((p) => p.authorId).whereType<String>());

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

        // 단일 게시글 작성자 프로필 정보 동적으로 불러오기
        if (post.authorId != null) {
          await _fetchMissingUsers([post.authorId!]);
        }

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
    notifyListeners();

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
        id: postId, // 발급받은 ID 사용
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
        snippet:
            content.length > 50 ? '${content.substring(0, 50)}...' : content,
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

  // 게시글 수정하기
  Future<bool> editPost(
    String postId, {
    required String title,
    required String content,
    required String category,
    required List<String> tags,
    required List<String> existingImageUrls, // UI에서 삭제되지 않고 남은 기존 네트워크 이미지들
    required List<File> newImageFiles, // 갤러리에서 새로 추가한 로컬 파일들
    required String authorId,
    void Function(int current, int total, double progress)? onImageProgress,
  }) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      // 1. 기존 게시글 데이터를 로컬에서 찾기
      final postToEdit = _posts.firstWhere((p) => p.id == postId);

      // 2. 사용자가 X를 눌러 삭제한 기존 이미지들을 스토리지에서 지우기
      final deletedImageUrls = postToEdit.imageUrls
          .where((url) => !existingImageUrls.contains(url))
          .toList();
      for (final url in deletedImageUrls) {
        try {
          final ref = FirebaseStorage.instance.refFromURL(url);
          await ref.delete();
        } catch (e) {
          debugPrint('기존 스토리지 이미지 삭제 실패: $url, $e');
        }
      }

      // 3. 새로 추가된 이미지 파일 업로드
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

      // 4. 최종 합쳐진 이미지 URL 목록 생성
      final finalImageUrls = [...existingImageUrls, ...newUploadedUrls];

      // 5. 업데이트할 데이터 Map 묶기
      final updateData = {
        'title': title,
        'content': content,
        'category': category,
        'tags': tags,
        'hasImage': finalImageUrls.isNotEmpty,
        'imageUrls': finalImageUrls,
        'snippet':
            content.length > 50 ? '${content.substring(0, 50)}...' : content,
      };

      // 6. 리포지토리를 통해 Firestore 업데이트 (이때 editHistory 타임스탬프가 추가됨)
      await _repository.updatePost(postId, updateData);

      // 로딩 상태를 풀어주어야 fetchPosts 내부의 방어 로직(if isLoading return)을 통과합니다.
      _isLoading = false;

      // 7. 로컬 리스트 다시 가져오기 (데이터 동기화)
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
      // 1. 스토리지에 저장된 이미지 먼저 모두 삭제
      try {
        final postToDelete = _posts.firstWhere((p) => p.id == postId);
        if (postToDelete.hasImage && postToDelete.imageUrls != null) {
          for (final url in postToDelete.imageUrls!) {
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

      // 2. 파이어스토어에서 게시글 데이터 삭제
      await _repository.deletePost(postId);
      // 3. 로컬 리스트에서도 즉시 제거 (낙관적 업데이트)
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

  // =======================================================================
  // 투표(Vote) 관련 기능
  // =======================================================================

  // 여러 투표글에 대한 내 투표 기록 일괄 조회 및 캐싱
  Future<void> fetchMyVotes(String userId) async {
    final votePosts = _posts.where((p) => p.postType == 'vote').map((p) => p.id).toList();
    if (votePosts.isEmpty) return;

    final fetchedVotes = await _repository.getMyVotes(userId, votePosts);
    myVotes.addAll(fetchedVotes);
    notifyListeners();
  }

  // 투표하기 (낙관적 UI 업데이트 포함)
  Future<bool> votePost(String postId, int optionIndex, String userId) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      await _repository.votePost(postId, userId, optionIndex);
      
      // 1. 로컬 캐시에 즉각 반영
      myVotes[postId] = optionIndex;
      
      // 2. 게시글 목록 내의 옵션 카운트를 즉각 1 증가시켜 낙관적 업데이트
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
      notifyListeners();
      return true;
    } catch (e) {
      _isLoading = false;
      _errorMessage = e.toString();
      notifyListeners();
      return false;
    }
  }

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
    _replyingTo = null; // 초기화

    try {
      final comments = await _repository.getComments(postId);
      _currentPostComments.addAll(comments);

      // 댓글 및 대댓글 작성자들의 프로필 정보 동적으로 불러오기
      await _fetchMissingUsers(
          comments.map((c) => c.authorId).whereType<String>());

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
    String? authorAvatarUrl,
  }) async {
    try {
      final newComment = Comment(
        id: '', // Repository에서 자동 생성
        authorId: authorId,
        authorNickname: authorNickname,
        authorAvatarUrl: authorAvatarUrl,
        content: content,
        parentId: _replyingTo?.parentId ?? _replyingTo?.id,
        replyToNickname:
            _replyingTo != null ? _replyingTo!.authorNickname : null,
      );

      final createdComment = await _repository.addComment(postId, newComment);

      // 대댓글 입력 상태 초기화
      _replyingTo = null;

      // 낙관적 업데이트: 화면 리스트에 추가 (새로운 리스트 객체로 할당하여 확실하게 UI 갱신 유도)
      _currentPostComments = List.from(_currentPostComments)
        ..add(createdComment);

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
  Future<void> toggleCommentLike(
      String postId, String commentId, String userId) async {
    final isLiked = _likedCommentIds.contains(commentId);
    final targetState = !isLiked;

    // 낙관적 업데이트 (UI 먼저 즉각 반영)
    if (targetState) {
      _likedCommentIds.add(commentId);
    } else {
      _likedCommentIds.remove(commentId);
    }

    final commentIndex =
        _currentPostComments.indexWhere((c) => c.id == commentId);
    if (commentIndex != -1) {
      final c = _currentPostComments[commentIndex];
      _currentPostComments[commentIndex] =
          c.copyWith(likeCount: c.likeCount + (targetState ? 1 : -1));
    }
    notifyListeners();

    try {
      await _repository.toggleCommentLike(
          postId, commentId, userId, targetState);
    } catch (e) {
      // 롤백
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
      notifyListeners();
    }
  }

  // 뷰 화면 진입 시 사용자 액션(좋아요, 스크랩 여부) 로드
  Future<void> loadUserActions(String postId, {String? userId}) async {
    _isCurrentPostLiked = false;
    _isCurrentPostScrapped = false;
    // UI 초기화를 위해 먼저 리스너 호출
    notifyListeners();

    if (userId == null) return;

    try {
      final actions = await _repository.getUserPostActions(postId, userId);
      _isCurrentPostLiked = actions['isLiked'] ?? false;
      _isCurrentPostScrapped = actions['isScrapped'] ?? false;
      notifyListeners();
    } catch (e) {
      // 조용히 넘어감
    }
  }

  // 조회수 증가 로직 (24시간 로컬 캐싱)
  Future<void> incrementViewCount(String postId, {String? userId}) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final key = 'viewed_${userId ?? "guest"}_$postId';
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
  Future<void> toggleLike(String postId, String userId) async {
    final originalState = _isCurrentPostLiked;
    _isCurrentPostLiked = !_isCurrentPostLiked;

    // 로컬 상태 즉시 업데이트
    final postIndex = _posts.indexWhere((p) => p.id == postId);
    if (postIndex != -1) {
      final p = _posts[postIndex];
      _posts[postIndex] =
          p.copyWith(likeCount: p.likeCount + (_isCurrentPostLiked ? 1 : -1));
    }
    notifyListeners();

    try {
      await _repository.toggleLike(postId, userId, _isCurrentPostLiked);
    } catch (e) {
      // 실패 시 롤백
      _isCurrentPostLiked = originalState;
      if (postIndex != -1) {
        final p = _posts[postIndex];
        _posts[postIndex] =
            p.copyWith(likeCount: p.likeCount + (_isCurrentPostLiked ? 1 : -1));
      }
      _errorMessage = '추천 처리에 실패했습니다.';
      notifyListeners();
    }
  }

  // 스크랩 토글 (낙관적 업데이트 적용)
  Future<void> toggleScrap(String postId, String userId) async {
    final originalState = _isCurrentPostScrapped;
    _isCurrentPostScrapped = !_isCurrentPostScrapped;

    // 로컬 상태 즉시 업데이트
    final postIndex = _posts.indexWhere((p) => p.id == postId);
    if (postIndex != -1) {
      final p = _posts[postIndex];
      _posts[postIndex] = p.copyWith(
          scrapCount: p.scrapCount + (_isCurrentPostScrapped ? 1 : -1));
    }
    notifyListeners();

    try {
      await _repository.toggleScrap(postId, userId, _isCurrentPostScrapped);
    } catch (e) {
      // 실패 시 롤백
      _isCurrentPostScrapped = originalState;
      if (postIndex != -1) {
        final p = _posts[postIndex];
        _posts[postIndex] = p.copyWith(
            scrapCount: p.scrapCount + (_isCurrentPostScrapped ? 1 : -1));
      }
      _errorMessage = '스크랩 처리에 실패했습니다.';
      notifyListeners();
    }
  }

  // --- Q&A 전용 로직 ---
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
    notifyListeners();

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
      notifyListeners();
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
    notifyListeners();

    try {
      await _repository.acceptAnswer(
        postId: postId,
        commentId: commentId,
        answererId: answererId,
        rewardCrackers: rewardCrackers,
      );

      _isLoading = false;
      
      // 로컬 데이터 즉각 갱신
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
      
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = e.toString();
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }
}
