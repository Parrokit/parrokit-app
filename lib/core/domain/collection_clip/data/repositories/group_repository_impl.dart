// ============================================================================
// lib/core/collection_media/data/repositories/group_repository_impl.dart
// ============================================================================
//
// [역할]
// GroupRepository 구현체. 다른 repository/datasource에 의존하지 않는
// 독립적인 구현입니다.
//
// [레이어]
// Core > Collection Media > Data > Repositories
// ============================================================================

import 'package:parrokit/data/local/app_database.dart';
import 'package:parrokit/core/domain/collection_clip/domain/repositories/group_repository.dart';

class GroupRepositoryImpl implements GroupRepository {
  final AppDatabase db;

  GroupRepositoryImpl(this.db);

  @override
  Future<List<Group>> getAllGroups(String storageMode) async {
    final allGroups = await db.groupsDao.getAllGroups(storageMode);
    return allGroups.toList()..sort((a, b) => a.name.compareTo(b.name));
  }

  @override
  Future<void> createGroup(String name, String storageMode) =>
      db.groupsDao.insertGroup(name, storageMode);

  @override
  Future<void> deleteGroupById(int id) async {
    await db.transaction(() async {
      // 그룹과 매핑된 연결 정보 삭제
      await (db.delete(db.groupCollections)
            ..where((gc) => gc.groupId.equals(id)))
          .go();
      // 그룹 자체 삭제
      await db.groupsDao.deleteGroupById(id);
    });
  }
}
