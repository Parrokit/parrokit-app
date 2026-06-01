// lib/features/community/shell/providers/community_provider.dart
import 'package:flutter/foundation.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:parrokit/core/services/firebase/firebase_user_service.dart';
import 'package:parrokit/data/models/post.dart';
import 'package:parrokit/data/models/comment.dart';
import 'package:parrokit/data/models/user.dart';
import 'package:parrokit/data/models/vote_option.dart';
import 'package:parrokit/features/community/shell/data/repositories/community_repository.dart';
import 'package:parrokit/features/community/shell/data/services/community_image_service.dart';
import 'package:parrokit/features/community/shell/domain/usecases/post/add_post_usecase.dart';
import 'package:parrokit/features/community/shell/domain/usecases/post/edit_post_usecase.dart';
import 'package:parrokit/features/community/shell/domain/usecases/post/delete_post_usecase.dart';
import 'package:parrokit/features/community/shell/domain/usecases/comment/add_comment_usecase.dart';
import 'package:parrokit/features/community/shell/domain/usecases/comment/delete_comment_usecase.dart';
import 'package:parrokit/features/community/shell/domain/usecases/question/add_question_usecase.dart';
import 'package:parrokit/features/community/shell/domain/usecases/question/accept_answer_usecase.dart';
import 'package:parrokit/features/community/shell/domain/usecases/vote/vote_post_usecase.dart';
import 'package:parrokit/features/community/shell/domain/usecases/user_action/user_action_usecases.dart';
import 'dart:io';

part 'community_provider_post.dart';
part 'community_provider_vote.dart';
part 'community_provider_comment.dart';
part 'community_provider_user_action.dart';
part 'community_provider_question.dart';

class CommunityProvider with ChangeNotifier {
  final CommunityRepository _repository = CommunityRepository();
  final CommunityImageService _imageService = CommunityImageService();
  final FirebaseUserService _userService = FirebaseUserService();

  late final AddPostUseCase addPostUseCase = AddPostUseCase(_repository, _imageService);
  late final EditPostUseCase editPostUseCase = EditPostUseCase(_repository, _imageService);
  late final DeletePostUseCase deletePostUseCase = DeletePostUseCase(_repository, _imageService);
  late final AddCommentUseCase addCommentUseCase = AddCommentUseCase(_repository);
  late final DeleteCommentUseCase deleteCommentUseCase = DeleteCommentUseCase(_repository);
  late final AddQuestionUseCase addQuestionUseCase = AddQuestionUseCase(_repository, _imageService);
  late final AcceptAnswerUseCase acceptAnswerUseCase = AcceptAnswerUseCase(_repository);
  late final VotePostUseCase votePostUseCase = VotePostUseCase(_repository);
  late final ToggleLikeUseCase toggleLikeUseCase = ToggleLikeUseCase(_repository);
  late final ToggleScrapUseCase toggleScrapUseCase = ToggleScrapUseCase(_repository);
  late final ToggleCommentLikeUseCase toggleCommentLikeUseCase = ToggleCommentLikeUseCase(_repository);
  late final LoadUserActionsUseCase loadUserActionsUseCase = LoadUserActionsUseCase(_repository);
  late final IncrementViewCountUseCase incrementViewCountUseCase = IncrementViewCountUseCase(_repository);

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
