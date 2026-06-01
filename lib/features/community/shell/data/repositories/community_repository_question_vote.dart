part of 'community_repository.dart';

mixin CommunityRepositoryQuestionVote {
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

  Future<void> votePost(String postId, String userId, int optionIndex) async {
    final postRef = _firestore.collection('posts').doc(postId);
    final voterRef = postRef.collection('voters').doc(userId);

    try {
      await _firestore.runTransaction((transaction) async {
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

        final updatedOptions = List<Map<String, dynamic>>.from(voteOptionsList);
        if (optionIndex < 0 || optionIndex >= updatedOptions.length) {
          throw Exception('유효하지 않은 투표 항목입니다.');
        }

        updatedOptions[optionIndex]['count'] =
            (updatedOptions[optionIndex]['count'] as int? ?? 0) + 1;

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

  Future<Map<String, int>> getMyVotes(String userId, List<String> postIds) async {
    final myVotes = <String, int>{};
    if (postIds.isEmpty) return myVotes;

    try {
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
    } catch (_) {
      return myVotes;
    }
  }
}
