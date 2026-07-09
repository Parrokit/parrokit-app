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

class ClipCloudMetadataDatasource {
  final AppDatabase db;
  final ClipDetailQueryDatasource detailQueryDatasource;

  ClipCloudMetadataDatasource(this.db, this.detailQueryDatasource);

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
      'updatedAt': DateTime.now().toUtc().toIso8601String(),
    };
  }
}
