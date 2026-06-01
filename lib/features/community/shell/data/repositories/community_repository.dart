import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:parrokit/data/models/comment.dart';
import 'package:parrokit/data/models/post.dart';

part 'community_repository_post.dart';
part 'community_repository_comment.dart';
part 'community_repository_user_action.dart';
part 'community_repository_question_vote.dart';

class CommunityRepository
    with
        CommunityRepositoryPost,
        CommunityRepositoryComment,
        CommunityRepositoryUserAction,
        CommunityRepositoryQuestionVote {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<Map<String, String>> _getAuthorNicknames(Set<String> authorIds) async {
    final nicknames = <String, String>{};
    if (authorIds.isEmpty) return nicknames;

    final idsList = authorIds.toList();
    for (var i = 0; i < idsList.length; i += 10) {
      final end = i + 10 > idsList.length ? idsList.length : i + 10;
      final chunk = idsList.sublist(i, end);
      final snap = await _firestore
          .collection('users')
          .where(FieldPath.documentId, whereIn: chunk)
          .get();

      for (final doc in snap.docs) {
        final displayName = doc.data()['displayName'] as String?;
        if (displayName != null && displayName.isNotEmpty) {
          nicknames[doc.id] = displayName;
        }
      }
    }

    return nicknames;
  }
}
