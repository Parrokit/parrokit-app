part of 'community_repository.dart';

mixin CommunityRepositoryQuestion {
  FirebaseFirestore get _firestore;

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
        final userSnapshot = await transaction.get(userRef);
        if (!userSnapshot.exists) {
          throw Exception('유저 정보를 찾을 수 없습니다.');
        }

        final userData = userSnapshot.data()!;
        final currentCrackers = (userData['crackers'] as num?)?.toInt() ?? 0;
        if (currentCrackers < requiredCrackers) {
          throw Exception('보유한 크래커가 부족합니다.');
        }

        transaction.update(userRef, {
          'crackers': FieldValue.increment(-requiredCrackers),
        });
        transaction.set(docRef, newPost.toJson());
      });

      return newPost;
    } catch (e) {
      throw Exception('질문 등록에 실패했습니다: $e');
    }
  }

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

        final answererSnapshot = await transaction.get(answererRef);

        transaction.update(postRef, {
          'questionStatus': 'resolved',
          'acceptedCommentId': commentId,
          'updatedAt': DateTime.now().toIso8601String(),
        });

        transaction.update(commentRef, {
          'isAccepted': true,
          'updatedAt': DateTime.now().toIso8601String(),
        });

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
}
