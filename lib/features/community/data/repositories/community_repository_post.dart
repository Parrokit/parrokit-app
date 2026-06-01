part of 'community_repository.dart';

extension CommunityRepositoryPost on CommunityRepository {
  Future<Post?> getPostById(String postId) async {
    try {
      final doc = await _firestore.collection('posts').doc(postId).get();
      if (!doc.exists) return null;
      return Post.fromJson(doc.data() as Map<String, dynamic>);
    } catch (_) {
      return null;
    }
  }

  String generatePostId() {
    return _firestore.collection('posts').doc().id;
  }

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

  Future<void> deletePost(String postId) async {
    try {
      await _firestore.collection('posts').doc(postId).delete();
    } catch (e) {
      throw Exception('게시글 삭제에 실패했습니다: $e');
    }
  }

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

  Future<List<Post>> getPosts({
    String postType = 'board',
    int limit = 10,
    DocumentSnapshot? startAfter,
  }) async {
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

      final authorIds = <String>{};
      for (final doc in docs) {
        final data = doc.data() as Map<String, dynamic>;
        final authorId = data['authorId'] as String?;
        if (authorId != null) {
          authorIds.add(authorId);
        }
      }

      final nicknames = await _getAuthorNicknames(authorIds);

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
}
