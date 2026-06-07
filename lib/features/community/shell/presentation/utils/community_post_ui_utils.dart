import 'package:parrokit/core/state/provider/user_provider.dart';
import 'package:parrokit/data/models/post.dart';
import 'package:parrokit/features/community/shell/presentation/providers/community_provider.dart';

String formatCommunityTimeAgo(DateTime? time) {
  if (time == null) return '';
  final diff = DateTime.now().difference(time);
  if (diff.inDays > 0) return '${diff.inDays}일 전';
  if (diff.inHours > 0) return '${diff.inHours}시간 전';
  if (diff.inMinutes > 0) return '${diff.inMinutes}분 전';
  return '방금 전';
}

String resolveCommunityAuthorName({
  required Post post,
  required CommunityProvider provider,
  required UserProvider userProvider,
}) {
  final currentUser = userProvider.currentUser;
  final isMe = currentUser != null && post.authorId == currentUser.id;
  if (isMe) {
    return currentUser.displayName ?? post.authorNickname;
  }

  return provider.getCachedUser(post.authorId)?.displayName ??
      post.authorNickname;
}

String? resolveCommunityAuthorAvatarUrl({
  required Post post,
  required CommunityProvider provider,
  required UserProvider userProvider,
}) {
  final currentUser = userProvider.currentUser;
  final isMe = currentUser != null && post.authorId == currentUser.id;
  if (isMe) {
    return currentUser.photoUrl ?? post.authorAvatarUrl;
  }

  return provider.getCachedUser(post.authorId)?.photoUrl ??
      post.authorAvatarUrl;
}
