// lib/features/community/providers/community_provider.dart
import 'package:flutter/foundation.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:parrokit/core/services/firebase/firebase_user_service.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:parrokit/data/models/post.dart';
import 'package:parrokit/data/models/comment.dart';
import 'package:parrokit/features/community/data/repositories/community_repository.dart';
import 'package:parrokit/data/models/user.dart';
import 'package:parrokit/data/models/vote_option.dart';
import 'dart:io';
import 'package:firebase_storage/firebase_storage.dart';

part 'community_provider_post.dart';
part 'community_provider_vote.dart';
part 'community_provider_comment.dart';
part 'community_provider_user_action.dart';
part 'community_provider_question.dart';

class CommunityProvider with ChangeNotifier {
  final CommunityRepository _repository = CommunityRepository();
  final FirebaseUserService _userService = FirebaseUserService();

  final Map<String, AppUser> _userCache = {};

  AppUser? getCachedUser(String uid) => _userCache[uid];

  Future<void> _fetchMissingUsers(Iterable<String> uids) async {
    final missingUids =
        uids.where((uid) => !_userCache.containsKey(uid) && uid.isNotEmpty).toSet();
    if (missingUids.isEmpty) return;

    await Future.wait(missingUids.map((uid) async {
      try {
        final user = await _userService.loadUserDocument(uid: uid);
        if (user != null) {
          _userCache[uid] = user;
        } else {
          _userCache[uid] = AppUser(id: uid, displayName: '알 수 없음', email: '');
        }
      } catch (_) {
        // noop
      }
    }));
  }

  List<Post> _posts = [];
  List<Post> get posts => _posts;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  String? _errorMessage;
  String? get errorMessage => _errorMessage;

  DocumentSnapshot? _lastDocument;

  List<Comment> _currentPostComments = [];
  List<Comment> get currentPostComments => _currentPostComments;

  Set<String> _likedCommentIds = {};
  Set<String> get likedCommentIds => _likedCommentIds;

  Map<String, int> myVotes = {};

  Comment? _replyingTo;
  Comment? get replyingTo => _replyingTo;

  void setReplyingTo(Comment? comment) {
    _replyingTo = comment;
    notifyListeners();
  }

  bool _isCurrentPostLiked = false;
  bool get isCurrentPostLiked => _isCurrentPostLiked;

  bool _isCurrentPostScrapped = false;
  bool get isCurrentPostScrapped => _isCurrentPostScrapped;

  String _currentPostType = 'board';

  void _notifyListenersSafe() {
    notifyListeners();
  }

  void clear() {
    _posts.clear();
    _isLoading = false;
    _errorMessage = null;
    _lastDocument = null;
    _currentPostComments.clear();
    _likedCommentIds.clear();
    _replyingTo = null;
    _isCurrentPostLiked = false;
    _isCurrentPostScrapped = false;
    myVotes.clear();
    notifyListeners();
  }
}
