// ============================================================================
// lib/core/collection_media/data/datasources/clip_cloud_metadata_datasource.dart
// ============================================================================
//
// [역할]
// Google Drive에 올라가는 clips/{remoteDocId}/metadata.json 내용을 빌드하는
// datasource.
//
// [레이어]
// Core > Collection Media > Data > Datasources
// ============================================================================

import 'package:parrokit/data/local/app_database.dart';
import 'package:parrokit/core/domain/collection_clip/data/constants/clip_storage_constants.dart';
import 'clip_detail_query_datasource.dart';
import 'remote_doc_id_resolver.dart';

class ClipCloudMetadataDatasource {
  final AppDatabase db;
  final RemoteDocIdResolver remoteDocIdResolver;
  final ClipDetailQueryDatasource detailQueryDatasource;

  ClipCloudMetadataDatasource(
    this.db,
    this.remoteDocIdResolver,
    this.detailQueryDatasource,
  );

  Future<Map<String, dynamic>> buildCloudClipMetadata({
    required Clip clip,
    required String remoteDocId,
    required String ownerKey,
    required String storagePath,
    required String? thumbnailStoragePath,
    required int storageBytes,
  }) async {
    final segments = await detailQueryDatasource.segmentsForClip(clip.id);
    final tagNames = await detailQueryDatasource.tagNamesForClip(clip.id);
    final collection = await _collectionMetadataForClip(
      ownerKey: ownerKey,
      collectionId: clip.collectionId,
    );
    final groups = await _groupMetadataForCollection(
      ownerKey: ownerKey,
      collectionId: clip.collectionId,
    );
    final groupCollections = _groupCollectionMetadata(
      collection: collection,
      groups: groups,
    );

    return {
      'schemaVersion': 1,
      'remoteDocId': remoteDocId,
      'localId': clip.id,
      'title': clip.title,
      'durationMs': clip.durationMs,
      'storageBytes': storageBytes,
      'storageMode': ClipStorageConstants.providerGoogleDrive,
      'provider': ClipStorageConstants.providerGoogleDrive,
      'ownerScope': ClipStorageConstants.ownerScopeCloudAccount,
      'ownerKey': ownerKey,
      'storagePath': storagePath,
      'thumbnailStoragePath': thumbnailStoragePath,
      'segments': segments
          .map(
            (segment) => {
              'startMs': segment.startMs,
              'endMs': segment.endMs,
              'original': segment.original,
              'pron': segment.pron,
              'trans': segment.trans,
            },
          )
          .toList(),
      'tags': tagNames,
      'collection': collection,
      'groups': groups,
      'groupCollections': groupCollections,
      'updatedAt': DateTime.now().toUtc().toIso8601String(),
    };
  }

  List<Map<String, dynamic>> _groupCollectionMetadata({
    required Map<String, dynamic>? collection,
    required List<Map<String, dynamic>> groups,
  }) {
    final collectionRemoteId = collection?['remoteDocId'] as String?;
    if (collectionRemoteId == null || collectionRemoteId.isEmpty) {
      return const [];
    }

    return groups
        .map((group) {
          final groupRemoteId = group['remoteDocId'] as String?;
          if (groupRemoteId == null || groupRemoteId.isEmpty) {
            return null;
          }
          return {
            'groupRemoteId': groupRemoteId,
            'collectionRemoteId': collectionRemoteId,
          };
        })
        .whereType<Map<String, dynamic>>()
        .toList();
  }

  Future<Map<String, dynamic>?> _collectionMetadataForClip({
    required String ownerKey,
    required int? collectionId,
  }) async {
    if (collectionId == null) return null;

    final collection = await (db.select(db.collections)
          ..where((c) => c.id.equals(collectionId))
          ..limit(1))
        .getSingleOrNull();
    if (collection == null) return null;

    return {
      'localId': collection.id,
      'remoteDocId': await remoteDocIdResolver.collectionDocId(
        uid: ownerKey,
        collectionId: collection.id,
      ),
      'name': collection.name,
    };
  }

  Future<List<Map<String, dynamic>>> _groupMetadataForCollection({
    required String ownerKey,
    required int? collectionId,
  }) async {
    if (collectionId == null) return const [];

    final mappings = await (db.select(db.groupCollections)
          ..where((gc) => gc.collectionId.equals(collectionId)))
        .get();
    final groups = <Map<String, dynamic>>[];

    for (final mapping in mappings) {
      final group = await (db.select(db.groups)
            ..where((g) => g.id.equals(mapping.groupId))
            ..limit(1))
          .getSingleOrNull();
      if (group == null) continue;

      groups.add({
        'localId': group.id,
        'remoteDocId': await remoteDocIdResolver.groupDocId(
          uid: ownerKey,
          groupId: group.id,
        ),
        'name': group.name,
      });
    }

    groups.sort((a, b) => '${a['name']}'.compareTo('${b['name']}'));
    return groups;
  }
}
