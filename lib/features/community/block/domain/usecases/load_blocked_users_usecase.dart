import 'package:parrokit/features/community/block/domain/entities/blocked_user.dart';
import 'package:parrokit/features/community/block/domain/repositories/block_repository.dart';

class LoadBlockedUsersUseCase {
  final BlockRepository _repository;

  LoadBlockedUsersUseCase(this._repository);

  Future<List<BlockedUser>> execute(List<String> blockedUserIds) {
    return _repository.loadBlockedUsers(blockedUserIds);
  }
}
