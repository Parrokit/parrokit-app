import 'package:parrokit/features/community/block/domain/repositories/block_repository.dart';

class UnblockUserUseCase {
  final BlockRepository _repository;

  UnblockUserUseCase(this._repository);

  Future<String> execute({
    required String uid,
    required String blockedUserId,
  }) async {
    if (blockedUserId.isEmpty) {
      throw Exception('차단 해제할 사용자가 필요합니다.');
    }

    await _repository.unblockUser(uid: uid, blockedUserId: blockedUserId);
    return blockedUserId;
  }
}
