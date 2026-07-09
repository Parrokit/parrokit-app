// ============================================================================
// lib/core/collection_media/domain/repositories/collection_repository.dart
// ============================================================================
//
// [역할]
// Collection 조회(가시성 필터 포함)를 위한 추상 계약(Repository 인터페이스).
//
// [레이어]
// Core > Collection Media > Domain > Repositories
// ============================================================================

import 'package:parrokit/data/local/app_database.dart';

abstract class CollectionRepository {
  Future<List<Collection>> getVisibleCollectionsForGroup(int? groupId);

  Future<List<Collection>> getAllVisibleCollections();
}
