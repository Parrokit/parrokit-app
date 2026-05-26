// lib/features/community/data/repositories/community_repository.dart
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:parrokit/data/models/post.dart';
import 'package:parrokit/data/models/comment.dart';

class CommunityRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

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
      return snapshot.docs.map((doc) {
        final data = doc.data() as Map<String, dynamic>;
        // 파이어베이스에서 바로 가져온 문서 ID를 주입하여 안전하게 변환
        data['id'] = doc.id;
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

      return snapshot.docs.map((doc) {
        final data = doc.data();
        data['id'] = doc.id;
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
