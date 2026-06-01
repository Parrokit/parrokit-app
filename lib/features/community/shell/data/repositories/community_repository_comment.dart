part of 'community_repository.dart';

mixin CommunityRepositoryComment {
  FirebaseFirestore get _firestore;
  Future<Map<String, String>> _getAuthorNicknames(Set<String> authorIds);

  Future<List<Comment>> getComments(String postId) async {
    try {
      final snapshot = await _firestore
          .collection('posts')
          .doc(postId)
          .collection('comments')
          .orderBy('createdAt', descending: false)
          .get();

      final docs = snapshot.docs;
      final authorIds = <String>{};
      for (final doc in docs) {
        final data = doc.data();
        final authorId = data['authorId'] as String?;
        if (authorId != null) {
          authorIds.add(authorId);
        }
      }

      final nicknames = await _getAuthorNicknames(authorIds);

      return docs.map((doc) {
        final data = doc.data();
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
      await _firestore.collection('posts').doc(postId).update({
        'commentCount': FieldValue.increment(1),
      });

      return newComment;
    } catch (e) {
      throw Exception('댓글 등록에 실패했습니다: $e');
    }
  }

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
    } catch (e) {
      throw Exception('댓글 삭제에 실패했습니다: $e');
    }
  }

  Future<void> toggleCommentLike(
    String postId,
    String commentId,
    String userId,
    bool isLiked,
  ) async {
    try {
      final commentRef =
          _firestore.collection('posts').doc(postId).collection('comments').doc(commentId);
      final likeDocId = '${postId}_$commentId';
      final likeRef =
          _firestore.collection('users').doc(userId).collection('comment_likes').doc(likeDocId);
      final legacyLikeRef =
          _firestore.collection('users').doc(userId).collection('comment_likes').doc(commentId);

      await _firestore.runTransaction((transaction) async {
        if (isLiked) {
          transaction.set(likeRef, {
            'postId': postId,
            'commentId': commentId,
            'createdAt': FieldValue.serverTimestamp(),
          });
          // Keep backward compatibility for old key format during migration.
          final legacySnapshot = await transaction.get(legacyLikeRef);
          if (legacySnapshot.exists) {
            transaction.delete(legacyLikeRef);
          }
          transaction.update(commentRef, {'likeCount': FieldValue.increment(1)});
        } else {
          transaction.delete(likeRef);
          final legacySnapshot = await transaction.get(legacyLikeRef);
          if (legacySnapshot.exists) {
            transaction.delete(legacyLikeRef);
          }
          transaction.update(commentRef, {'likeCount': FieldValue.increment(-1)});
        }
      });
    } catch (e) {
      throw Exception('댓글 좋아요 처리에 실패했습니다: $e');
    }
  }

  Future<Set<String>> getLikedCommentIds(String userId) async {
    try {
      final snap =
          await _firestore.collection('users').doc(userId).collection('comment_likes').get();
      return snap.docs
          .map((doc) {
            final data = doc.data();
            final commentId = data['commentId'] as String?;
            if (commentId != null && commentId.isNotEmpty) {
              return commentId;
            }
            return doc.id;
          })
          .toSet();
    } catch (_) {
      return {};
    }
  }
}
