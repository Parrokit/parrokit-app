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

    final activities = <ActivityModel>[];

    try {
      if (activityType == 'written') {
        if (boardType == 'vote') {
          // 참여한 투표: users/{uid}가 posts/{postId}/voters/{uid}를 가진 투표 글
          final votersSnapshot = await _firestore
              .collectionGroup('voters')
              .where(FieldPath.documentId, isEqualTo: userId)
              .orderBy('votedAt', descending: true)
              .get();

          final latestVotedAtByPostId = <String, DateTime>{};
          for (final doc in votersSnapshot.docs) {
            final postId = doc.reference.parent.parent?.id;
            if (postId == null || postId.isEmpty) continue;
            final votedAt = _parseDateTime(doc.data()['votedAt']);
            final prev = latestVotedAtByPostId[postId];
            if (prev == null || votedAt.isAfter(prev)) {
              latestVotedAtByPostId[postId] = votedAt;
            }
          }

          final votePosts = await _fetchPostsByIds(latestVotedAtByPostId.keys.toList());
          for (final post in votePosts) {
            if (post.postType != 'vote') continue;
            activities.add(_postToActivity(
              post,
              activityType,
              createdAtOverride: latestVotedAtByPostId[post.id],
            ));
          }
        } else {
          // 내가 쓴 글(일반/질문)
          final snapshot = await _firestore
              .collection('posts')
              .where('authorId', isEqualTo: userId)
              .where('postType', isEqualTo: boardType)
              .orderBy('createdAt', descending: true)
              .get();

          for (final doc in snapshot.docs) {
            final post = Post.fromJson({'id': doc.id, ...doc.data()});
            activities.add(_postToActivity(post, activityType));
          }
        }
      } else if (activityType == 'commented' ||
          activityType == 'commented_reply') {
        // 내가 쓴 댓글/답변
        final snapshot = await _firestore
            .collectionGroup('comments')
            .where('authorId', isEqualTo: userId)
            .where('postType', isEqualTo: boardType)
            .orderBy('createdAt', descending: true)
            .get();

        for (final doc in snapshot.docs) {
          final comment = Comment.fromJson({
            'id': doc.id,
            'postId': doc.reference.parent.parent?.id ?? '',
            ...doc.data(),
          });

          final isQuestionAnswer =
              boardType == 'question' && comment.parentId == null;
          final isQuestionReply =
              boardType == 'question' && comment.parentId != null;

          if (activityType == 'commented' &&
              boardType == 'question' &&
              !isQuestionAnswer) {
            continue;
          }
          if (activityType == 'commented_reply' &&
              boardType == 'question' &&
              !isQuestionReply) {
            continue;
          }
          if (activityType == 'commented_reply' && boardType != 'question') {
            continue;
          }

          activities.add(_commentToActivity(comment, activityType));
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
          final posts = await _fetchPostsByIds(postIds);
          for (final post in posts) {
            if (post.postType != boardType) continue;
            activities.add(_postToActivity(post, activityType));
          }
        }
      } else if (activityType == 'liked_comment') {
        // 공감한 댓글/답변
        final likesSnapshot = await _firestore
            .collection('users')
            .doc(userId)
            .collection('comment_likes')
            .get();

        for (final likeDoc in likesSnapshot.docs) {
          final likeData = likeDoc.data();
          final postId = likeData['postId'] as String?;
          final commentId = likeData['commentId'] as String?;
          if (postId == null || commentId == null) {
            continue;
          }
          final commentDoc = await _firestore
              .collection('posts')
              .doc(postId)
              .collection('comments')
              .doc(commentId)
              .get();
          if (!commentDoc.exists) continue;
          final comment = Comment.fromJson({
            'id': commentDoc.id,
            'postId': postId,
            ...commentDoc.data()!,
          });
          if (comment.postType != boardType) continue;
          activities.add(_commentToActivity(comment, activityType));
        }

        final legacyCommentIds = likesSnapshot.docs
            .where((doc) {
              final data = doc.data();
              final postId = data['postId'] as String?;
              final commentId = data['commentId'] as String?;
              return (postId == null || postId.isEmpty) &&
                  (commentId == null || commentId.isEmpty);
            })
            .map((doc) => doc.id)
            .toList();
        if (legacyCommentIds.isNotEmpty) {
          final comments = await _fetchCommentsByIds(legacyCommentIds);
          for (final comment in comments) {
            if (comment.postType != boardType) continue;
            activities.add(_commentToActivity(comment, activityType));
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
          final posts = await _fetchPostsByIds(postIds);
          for (final post in posts) {
            if (post.postType != boardType) continue;
            activities.add(_postToActivity(post, activityType));
          }
        }
      }

      activities.sort((a, b) => b.createdAt.compareTo(a.createdAt));
    } catch (e) {
      AppLogger.e('Error fetching activities: $e');
    }

    return activities;
  }

  ActivityModel _postToActivity(
    Post post,
    String activityType, {
    DateTime? createdAtOverride,
  }) {
    return ActivityModel(
      id: post.id,
      sourcePostId: post.id,
      title: post.title,
      content: post.content,
      createdAt: createdAtOverride ?? post.createdAt ?? DateTime.now(),
      boardType: post.postType,
      activityType: activityType,
      likeCount: post.likeCount,
      commentCount: post.commentCount,
      viewCount: post.viewCount,
    );
  }

  ActivityModel _commentToActivity(Comment comment, String activityType) {
    return ActivityModel(
      id: comment.id,
      sourcePostId: comment.postId,
      title: activityType == 'liked_comment' ? '공감한 댓글' : '댓글 작성',
      content: comment.content,
      createdAt: comment.createdAt ?? DateTime.now(),
      boardType: comment.postType,
      activityType: activityType,
      likeCount: comment.likeCount,
      commentCount: 0,
      viewCount: 0,
    );
  }

  Future<List<Post>> _fetchPostsByIds(List<String> postIds) async {
    final posts = <Post>[];
    for (var i = 0; i < postIds.length; i += 10) {
      final end = (i + 10 < postIds.length) ? i + 10 : postIds.length;
      final chunk = postIds.sublist(i, end);
      final snapshot = await _firestore
          .collection('posts')
          .where(FieldPath.documentId, whereIn: chunk)
          .get();
      for (final doc in snapshot.docs) {
        posts.add(Post.fromJson({'id': doc.id, ...doc.data()}));
      }
    }
    return posts;
  }

  Future<List<Comment>> _fetchCommentsByIds(List<String> commentIds) async {
    final comments = <Comment>[];
    for (var i = 0; i < commentIds.length; i += 10) {
      final end = (i + 10 < commentIds.length) ? i + 10 : commentIds.length;
      final chunk = commentIds.sublist(i, end);
      final snapshot = await _firestore
          .collectionGroup('comments')
          .where(FieldPath.documentId, whereIn: chunk)
          .get();
      for (final doc in snapshot.docs) {
        comments.add(Comment.fromJson({
          'id': doc.id,
          'postId': doc.reference.parent.parent?.id ?? '',
          ...doc.data(),
        }));
      }
    }
    return comments;
  }

  DateTime _parseDateTime(dynamic value) {
    if (value is Timestamp) return value.toDate();
    if (value is DateTime) return value;
    if (value is String) return DateTime.tryParse(value) ?? DateTime.fromMillisecondsSinceEpoch(0);
    return DateTime.fromMillisecondsSinceEpoch(0);
  }
}
