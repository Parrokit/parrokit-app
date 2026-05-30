// lib/features/community/data/repositories/community_repository.dart
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:parrokit/data/models/post.dart';
import 'package:parrokit/data/models/comment.dart';

class CommunityRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // 작성자 ID 목록을 받아서 최신 닉네임 Map을 반환하는 헬퍼 함수
  Future<Map<String, String>> _getAuthorNicknames(Set<String> authorIds) async {
    final Map<String, String> nicknames = {};
    if (authorIds.isEmpty) return nicknames;

    // Firestore 'whereIn' 쿼리는 한 번에 최대 10개까지만 가능하므로 분할 처리
    final idsList = authorIds.toList();
    for (var i = 0; i < idsList.length; i += 10) {
      final chunk = idsList.sublist(i, i + 10 > idsList.length ? idsList.length : i + 10);
      final snap = await _firestore.collection('users').where(FieldPath.documentId, whereIn: chunk).get();
      for (var doc in snap.docs) {
        final displayName = doc.data()['displayName'] as String?;
        if (displayName != null && displayName.isNotEmpty) {
          nicknames[doc.id] = displayName;
        }
      }
    }
    return nicknames;
  }

  // 특정 게시글 1개 조회
  Future<Post?> getPostById(String postId) async {
    try {
      final doc = await _firestore.collection('posts').doc(postId).get();
      if (!doc.exists) return null;
      return Post.fromJson(doc.data() as Map<String, dynamic>);
    } catch (e) {
      return null;
    }
  }

  // 빈 문서 ID 미리 발급받기 (스토리지 폴더명 등에 활용)
  String generatePostId() {
    return _firestore.collection('posts').doc().id;
  }

  // Add a new post
  Future<Post> addPost(Post post) async {
    try {
      final docRef = post.id.isEmpty 
          ? _firestore.collection('posts').doc()
          : _firestore.collection('posts').doc(post.id);
          
      final newPost = post.copyWith(
        id: docRef.id,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );
      
      await docRef.set(newPost.toJson());
      return newPost;
    } catch (e) {
      throw Exception('게시글 등록에 실패했습니다: $e');
    }
  }

  // 게시글 삭제
  Future<void> deletePost(String postId) async {
    try {
      await _firestore.collection('posts').doc(postId).delete();
    } catch (e) {
      throw Exception('게시글 삭제에 실패했습니다: $e');
    }
  }

  // 게시글 수정
  Future<void> updatePost(String postId, Map<String, dynamic> data) async {
    try {
      final now = DateTime.now().toIso8601String();
      data['updatedAt'] = now;
      data['editHistory'] = FieldValue.arrayUnion([now]);

      await _firestore.collection('posts').doc(postId).update(data);
    } catch (e) {
      throw Exception('게시글 수정에 실패했습니다: $e');
    }
  }

  // Fetch posts (basic version, ordered by createdAt desc)
  Future<List<Post>> getPosts({String postType = 'board', int limit = 10, DocumentSnapshot? startAfter}) async {
    try {
      Query query = _firestore
          .collection('posts')
          .where('postType', isEqualTo: postType)
          .orderBy('createdAt', descending: true)
          .limit(limit);

      if (startAfter != null) {
        query = query.startAfterDocument(startAfter);
      }

      final snapshot = await query.get();
      final docs = snapshot.docs;

      // 1) 모든 글의 작성자 ID 수집
      final Set<String> authorIds = {};
      for (var doc in docs) {
        final data = doc.data() as Map<String, dynamic>;
        if (data['authorId'] != null) {
          authorIds.add(data['authorId'] as String);
        }
      }

      // 2) 최신 닉네임 일괄 조회
      final nicknames = await _getAuthorNicknames(authorIds);

      // 3) 각 게시글에 최신 닉네임 덮어씌우기
      return docs.map((doc) {
        final data = doc.data() as Map<String, dynamic>;
        data['id'] = doc.id;
        final authorId = data['authorId'] as String?;
        if (authorId != null && nicknames.containsKey(authorId)) {
          data['authorNickname'] = nicknames[authorId];
        }
        return Post.fromJson(data);
      }).toList();
    } catch (e) {
      throw Exception('게시글을 불러오는데 실패했습니다: $e');
    }
  }

  // Fetch comments for a specific post
  Future<List<Comment>> getComments(String postId) async {
    try {
      final snapshot = await _firestore
          .collection('posts')
          .doc(postId)
          .collection('comments')
          .orderBy('createdAt', descending: false) // 오래된 댓글이 위로
          .get();
          
      final docs = snapshot.docs;

      // 1) 모든 댓글의 작성자 ID 수집
      final Set<String> authorIds = {};
      for (var doc in docs) {
        final data = doc.data() as Map<String, dynamic>;
        if (data['authorId'] != null) {
          authorIds.add(data['authorId'] as String);
        }
      }

      // 2) 최신 닉네임 일괄 조회
      final nicknames = await _getAuthorNicknames(authorIds);

      // 3) 각 댓글에 최신 닉네임 덮어씌우기
      return docs.map((doc) {
        final data = doc.data() as Map<String, dynamic>;
        data['id'] = doc.id;
        final authorId = data['authorId'] as String?;
        if (authorId != null && nicknames.containsKey(authorId)) {
          data['authorNickname'] = nicknames[authorId];
        }
        return Comment.fromJson(data);
      }).toList();
    } catch (e) {
      throw Exception('댓글을 불러오는데 실패했습니다: $e');
    }
  }

  // Add a comment to a post
  Future<Comment> addComment(String postId, Comment comment) async {
    try {
      final docRef = _firestore
          .collection('posts')
          .doc(postId)
          .collection('comments')
          .doc();
          
      final newComment = comment.copyWith(
        id: docRef.id,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );
      
      await docRef.set(newComment.toJson());
      
      // Update comment count on the post document
      await _firestore.collection('posts').doc(postId).update({
        'commentCount': FieldValue.increment(1),
      });

      return newComment;
    } catch (e) {
      throw Exception('댓글 등록에 실패했습니다: $e');
    }
  }

  // Delete a comment (Soft delete)
  Future<void> deleteComment(String postId, String commentId) async {
    try {
      await _firestore
          .collection('posts')
          .doc(postId)
          .collection('comments')
          .doc(commentId)
          .update({
        'status': 'deleted',
        'content': '이 댓글은 삭제된 댓글입니다.',
        'updatedAt': DateTime.now().toIso8601String(),
      });
      
      // Note: Soft delete에서는 게시글의 commentCount를 감소시키지 않습니다.
    } catch (e) {
      throw Exception('댓글 삭제에 실패했습니다: $e');
    }
  }

  // Toggle Comment Like
  Future<void> toggleCommentLike(String postId, String commentId, String userId, bool isLiked) async {
    try {
      final commentRef = _firestore.collection('posts').doc(postId).collection('comments').doc(commentId);
      final likeRef = _firestore.collection('users').doc(userId).collection('comment_likes').doc(commentId);

      await _firestore.runTransaction((transaction) async {
        if (isLiked) {
          transaction.set(likeRef, {'createdAt': FieldValue.serverTimestamp()});
          transaction.update(commentRef, {'likeCount': FieldValue.increment(1)});
        } else {
          transaction.delete(likeRef);
          transaction.update(commentRef, {'likeCount': FieldValue.increment(-1)});
        }
      });
    } catch (e) {
      throw Exception('댓글 좋아요 처리에 실패했습니다: $e');
    }
  }

  // Get liked comments for a user in a specific post (for UI state)
  Future<Set<String>> getLikedCommentIds(String userId) async {
    try {
      final snap = await _firestore.collection('users').doc(userId).collection('comment_likes').get();
      return snap.docs.map((doc) => doc.id).toSet();
    } catch (e) {
      return {};
    }
  }

  // Increment view count
  Future<void> incrementViewCount(String postId) async {
    try {
      await _firestore.collection('posts').doc(postId).update({
        'viewCount': FieldValue.increment(1),
      });
    } catch (e) {
      throw Exception('조회수 증가에 실패했습니다: $e');
    }
  }

  // Toggle Like (추천)
  Future<void> toggleLike(String postId, String userId, bool isLiked) async {
    try {
      final postRef = _firestore.collection('posts').doc(postId);
      final likeRef = _firestore.collection('users').doc(userId).collection('likes').doc(postId);

      await _firestore.runTransaction((transaction) async {
        if (isLiked) {
          transaction.set(likeRef, {'createdAt': FieldValue.serverTimestamp()});
          transaction.update(postRef, {'likeCount': FieldValue.increment(1)});
        } else {
          transaction.delete(likeRef);
          transaction.update(postRef, {'likeCount': FieldValue.increment(-1)});
        }
      });
    } catch (e) {
      throw Exception('추천 처리에 실패했습니다: $e');
    }
  }

  // Toggle Scrap (스크랩)
  Future<void> toggleScrap(String postId, String userId, bool isScrapped) async {
    try {
      final postRef = _firestore.collection('posts').doc(postId);
      final scrapRef = _firestore.collection('users').doc(userId).collection('scraps').doc(postId);

      await _firestore.runTransaction((transaction) async {
        if (isScrapped) {
          transaction.set(scrapRef, {'createdAt': FieldValue.serverTimestamp()});
          transaction.update(postRef, {'scrapCount': FieldValue.increment(1)});
        } else {
          transaction.delete(scrapRef);
          transaction.update(postRef, {'scrapCount': FieldValue.increment(-1)});
        }
      });
    } catch (e) {
      throw Exception('스크랩 처리에 실패했습니다: $e');
    }
  }

  // Get User Actions for a specific post (Liked? Scrapped?)
  Future<Map<String, bool>> getUserPostActions(String postId, String userId) async {
    try {
      final likeDoc = await _firestore.collection('users').doc(userId).collection('likes').doc(postId).get();
      final scrapDoc = await _firestore.collection('users').doc(userId).collection('scraps').doc(postId).get();
      
      return {
        'isLiked': likeDoc.exists,
        'isScrapped': scrapDoc.exists,
      };
    } catch (e) {
      // Failed to load, default to false
      return {
        'isLiked': false,
        'isScrapped': false,
      };
    }
  }

  // --- Q&A 특화 트랜잭션 메서드 ---

  // 1. 질문 등록 (크래커 차감 동반)
  Future<Post> addQuestion(Post post, String userId, int requiredCrackers) async {
    try {
      final userRef = _firestore.collection('users').doc(userId);
      final docRef = post.id.isEmpty 
          ? _firestore.collection('posts').doc()
          : _firestore.collection('posts').doc(post.id);

      final newPost = post.copyWith(
        id: docRef.id,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      await _firestore.runTransaction((transaction) async {
        // 유저 문서 읽기
        final userSnapshot = await transaction.get(userRef);
        if (!userSnapshot.exists) {
          throw Exception('유저 정보를 찾을 수 없습니다.');
        }

        final userData = userSnapshot.data()!;
        final currentCrackers = (userData['crackers'] as num?)?.toInt() ?? 0;

        // 크래커 잔액 확인
        if (currentCrackers < requiredCrackers) {
          throw Exception('보유한 크래커가 부족합니다.');
        }

        // 크래커 차감
        transaction.update(userRef, {
          'crackers': FieldValue.increment(-requiredCrackers),
        });

        // 질문글 등록
        transaction.set(docRef, newPost.toJson());
      });

      return newPost;
    } catch (e) {
      throw Exception('질문 등록에 실패했습니다: $e');
    }
  }

  // 2. 답변 채택 (상태 변경 및 크래커 송금)
  Future<void> acceptAnswer({
    required String postId,
    required String commentId,
    required String answererId,
    required int rewardCrackers,
  }) async {
    try {
      final postRef = _firestore.collection('posts').doc(postId);
      final commentRef = postRef.collection('comments').doc(commentId);
      final answererRef = _firestore.collection('users').doc(answererId);

      await _firestore.runTransaction((transaction) async {
        // --- [모든 READ(읽기) 작업 우선 수행] ---
        // 1. 질문글 상태 확인
        final postSnapshot = await transaction.get(postRef);
        if (!postSnapshot.exists) {
          throw Exception('게시글을 찾을 수 없습니다.');
        }

        final postData = postSnapshot.data()!;
        if (postData['questionStatus'] == 'resolved') {
          throw Exception('이미 채택이 완료된 질문입니다.');
        }
        if (postData['questionStatus'] == 'expired') {
          throw Exception('마감 기한이 지난 질문입니다.');
        }

        // 2. 답변자 정보 가져오기
        final answererSnapshot = await transaction.get(answererRef);

        // --- [READ 이후 모든 WRITE(쓰기) 작업 수행] ---
        // 3. 상태 업데이트
        transaction.update(postRef, {
          'questionStatus': 'resolved',
          'acceptedCommentId': commentId,
          'updatedAt': DateTime.now().toIso8601String(),
        });
        
        transaction.update(commentRef, {
          'isAccepted': true,
          'updatedAt': DateTime.now().toIso8601String(),
        });

        // 4. 답변자에게 크래커 지급 (답변자 정보가 존재할 경우에만)
        if (answererSnapshot.exists) {
          transaction.update(answererRef, {
            'crackers': FieldValue.increment(rewardCrackers),
          });
        }
      });
    } catch (e) {
      throw Exception('답변 채택에 실패했습니다: $e');
    }
  }

  // =======================================================================
  // 4. 투표(Vote) 관련 기능
  // =======================================================================

  /// 투표하기 (트랜잭션 기반 동시성 제어 및 중복 방지)
  Future<void> votePost(String postId, String userId, int optionIndex) async {
    final postRef = _firestore.collection('posts').doc(postId);
    final voterRef = postRef.collection('voters').doc(userId);

    try {
      await _firestore.runTransaction((transaction) async {
        // 1. 읽기 작업
        final postSnapshot = await transaction.get(postRef);
        final voterSnapshot = await transaction.get(voterRef);

        if (!postSnapshot.exists) {
          throw Exception('게시글을 찾을 수 없습니다.');
        }
        if (voterSnapshot.exists) {
          throw Exception('이미 투표한 게시글입니다.');
        }

        final postData = postSnapshot.data()!;
        final voteOptionsList = postData['voteOptions'] as List<dynamic>?;
        if (voteOptionsList == null) {
          throw Exception('투표 항목이 존재하지 않습니다.');
        }

        final List<Map<String, dynamic>> updatedOptions = List<Map<String, dynamic>>.from(voteOptionsList);
        if (optionIndex < 0 || optionIndex >= updatedOptions.length) {
          throw Exception('유효하지 않은 투표 항목입니다.');
        }

        // 2. 투표수 1 증가
        updatedOptions[optionIndex]['count'] = (updatedOptions[optionIndex]['count'] as int? ?? 0) + 1;

        // 3. 쓰기 작업 (옵션 업데이트 및 투표자 기록 추가)
        transaction.update(postRef, {'voteOptions': updatedOptions});
        transaction.set(voterRef, {
          'selectedOption': optionIndex,
          'votedAt': FieldValue.serverTimestamp(),
        });
      });
    } catch (e) {
      throw Exception('투표 처리에 실패했습니다: $e');
    }
  }

  /// 특정 유저가 여러 투표글들에 대해 각각 어떤 항목에 투표했는지 캐싱 조회
  Future<Map<String, int>> getMyVotes(String userId, List<String> postIds) async {
    final Map<String, int> myVotes = {};
    if (postIds.isEmpty) return myVotes;

    try {
      // 투표글 수가 많지 않으므로 Future.wait 로 일괄 병렬 조회 (Firestore 에서는 다중 get 이 비용 효율적임)
      await Future.wait(postIds.map((postId) async {
        final voterDoc = await _firestore
            .collection('posts')
            .doc(postId)
            .collection('voters')
            .doc(userId)
            .get();

        if (voterDoc.exists) {
          myVotes[postId] = voterDoc.data()?['selectedOption'] as int;
        }
      }));
      return myVotes;
    } catch (e) {
      // 오류가 발생해도 앱이 터지지 않도록 로그만 찍고 빈 Map 반환
      print('내 투표 기록 조회 실패: $e');
      return myVotes;
    }
  }
}
