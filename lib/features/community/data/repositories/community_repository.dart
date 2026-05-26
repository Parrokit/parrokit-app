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

  // Add a new post
  Future<Post> addPost(Post post) async {
    try {
      final docRef = _firestore.collection('posts').doc();
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

  // Fetch posts (basic version, ordered by createdAt desc)
  Future<List<Post>> getPosts({int limit = 10, DocumentSnapshot? startAfter}) async {
    try {
      Query query = _firestore
          .collection('posts')
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

  // Delete a comment
  Future<void> deleteComment(String postId, String commentId) async {
    try {
      await _firestore
          .collection('posts')
          .doc(postId)
          .collection('comments')
          .doc(commentId)
          .delete();
          
      // Update comment count on the post document
      await _firestore.collection('posts').doc(postId).update({
        'commentCount': FieldValue.increment(-1),
      });
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
}
