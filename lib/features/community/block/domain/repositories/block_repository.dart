import 'package:parrokit/features/community/block/domain/entities/blocked_user.dart';

abstract class BlockRepository {
  Future<List<BlockedUser>> loadBlockedUsers(List<String> blockedUserIds);

  Future<String?> resolveUserIdByDisplayName(String displayName);

  Future<String?> resolveUserIdByUid(String uid);

  Future<void> blockUser({
    required String uid,
    required String blockedUserId,
  });

  Future<void> unblockUser({
    required String uid,
    required String blockedUserId,
  });
}
