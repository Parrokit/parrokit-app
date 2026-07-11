// ============================================================================
// lib/core/collection_media/domain/repositories/group_repository.dart
// ============================================================================
//
// [역할]
// Group CRUD를 위한 추상 계약(Repository 인터페이스).
//
// [레이어]
// Core > Collection Media > Domain > Repositories
// ============================================================================

import 'package:parrokit/data/local/app_database.dart';

abstract class GroupRepository {
  Future<List<Group>> getAllGroups(String storageMode);

  Future<void> createGroup(String name, String storageMode);

  Future<void> deleteGroupById(int id);
}
