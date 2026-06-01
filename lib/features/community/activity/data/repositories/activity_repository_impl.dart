import 'package:cloud_firestore/cloud_firestore.dart';
import '../../domain/entities/activity_item.dart';
import '../../domain/repositories/activity_repository.dart';
import '../models/activity_model.dart';
import 'package:parrokit/data/models/post.dart';
import 'package:parrokit/data/models/comment.dart';
import 'package:parrokit/core/utils/app_logger.dart';

class ActivityRepositoryImpl implements ActivityRepository {
  final FirebaseFirestore _firestore;

  ActivityRepositoryImpl({FirebaseFirestore? firestore})
      : _firestore = firestore ?? FirebaseFirestore.instance;

  @override
  Future<List<ActivityItem>> getActivities({
    required String userId,
    required String boardType,
    required String activityType,
  }) async {
    if (userId.isEmpty) return [];

    List<ActivityModel> activities = [];

    try {
      if (activityType == 'written') {
        // 내가 쓴 글
        final snapshot = await _firestore
            .collection('posts')
            .where('authorId', isEqualTo: userId)
            .where('postType', isEqualTo: boardType)
            .orderBy('createdAt', descending: true)
            .get();
        
        for (var doc in snapshot.docs) {
          final post = Post.fromJson({'id': doc.id, ...doc.data()});
          activities.add(ActivityModel(
            id: post.id,
            title: post.title,
            content: post.content,
            createdAt: post.createdAt ?? DateTime.now(),
            boardType: post.postType,
            activityType: activityType,
            likeCount: post.likeCount,
            commentCount: post.commentCount,
            viewCount: post.viewCount,
          ));
        }
      } else if (activityType == 'commented' || activityType == 'commented_reply') {
        // 내가 쓴 댓글
        final snapshot = await _firestore
            .collectionGroup('comments')
            .where('authorId', isEqualTo: userId)
            .where('postType', isEqualTo: boardType)
            .orderBy('createdAt', descending: true)
            .get();
        
        for (var doc in snapshot.docs) {
          final comment = Comment.fromJson({'id': doc.id, ...doc.data()});
          activities.add(ActivityModel(
            id: comment.id,
            title: '댓글 작성', 
            content: comment.content,
            createdAt: comment.createdAt ?? DateTime.now(),
            boardType: comment.postType,
            activityType: activityType,
            likeCount: comment.likeCount,
            commentCount: 0,
            viewCount: 0,
          ));
        }
      } else if (activityType == 'liked') {
        // 공감한 글
        final likesSnapshot = await _firestore
            .collection('users')
            .doc(userId)
            .collection('likes')
            .get();
            
        final postIds = likesSnapshot.docs.map((doc) => doc.id).toList();
        
        if (postIds.isNotEmpty) {
          for (var postId in postIds) {
            final doc = await _firestore.collection('posts').doc(postId).get();
            if (doc.exists) {
              final post = Post.fromJson({'id': doc.id, ...doc.data()!});
              if (post.postType == boardType) {
                activities.add(ActivityModel(
                  id: post.id,
                  title: post.title,
                  content: post.content,
                  createdAt: post.createdAt ?? DateTime.now(),
                  boardType: post.postType,
                  activityType: activityType,
                  likeCount: post.likeCount,
                  commentCount: post.commentCount,
                  viewCount: post.viewCount,
                ));
              }
            }
          }
        }
      } else if (activityType == 'scraped') {
        // 스크랩한 글
        final scrapsSnapshot = await _firestore
            .collection('users')
            .doc(userId)
            .collection('scraps')
            .get();
            
        final postIds = scrapsSnapshot.docs.map((doc) => doc.id).toList();
        
        if (postIds.isNotEmpty) {
          for (var postId in postIds) {
            final doc = await _firestore.collection('posts').doc(postId).get();
            if (doc.exists) {
              final post = Post.fromJson({'id': doc.id, ...doc.data()!});
              if (post.postType == boardType) {
                activities.add(ActivityModel(
                  id: post.id,
                  title: post.title,
                  content: post.content,
                  createdAt: post.createdAt ?? DateTime.now(),
                  boardType: post.postType,
                  activityType: activityType,
                  likeCount: post.likeCount,
                  commentCount: post.commentCount,
                  viewCount: post.viewCount,
                ));
              }
            }
          }
        }
      }
      
      activities.sort((a, b) => b.createdAt.compareTo(a.createdAt));
      
    } catch (e) {
      AppLogger.e('Error fetching activities: $e');
    }

    return activities;
  }
}
