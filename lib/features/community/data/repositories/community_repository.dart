// lib/features/community/data/repositories/community_repository.dart
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:parrokit/data/models/post.dart';

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
}
