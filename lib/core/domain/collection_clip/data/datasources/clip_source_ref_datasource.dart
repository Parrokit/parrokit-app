// ============================================================================
// lib/core/collection_media/data/datasources/clip_source_ref_datasource.dart
// ============================================================================
//
// [역할]
// clip_source_refs / clip_cache_entries 테이블 접근과 provider·ownerScope
// 판별, 그리고 클립 가시성(현재 로그인 계정/gdrive 계정 기준) 필터링을
// 전담하는 datasource. "이 클립이 지금 보이는지", "이 클립의 현재 계정
// 기준 원격 원본이 무엇인지" 질의를 이 클래스 하나로만 처리해서, 다른
// 곳에서 같은 로직을 복제하다가 생기는 불일치(예: gdrive 클립인데
// app_account로 조회하는 버그)를 막습니다.
//
// [레이어]
// Core > Collection Media > Data > Datasources
// ============================================================================

import 'package:drift/drift.dart';
import 'package:firebase_auth/firebase_auth.dart' as fb;
import 'package:firebase_storage/firebase_storage.dart';

import 'package:parrokit/data/local/app_database.dart';
import 'package:parrokit/core/shared/utils/app_logger.dart';
import 'package:parrokit/core/infrastructure/services/cloud/google_drive_storage_service.dart';
import 'package:parrokit/core/domain/collection_clip/data/constants/clip_storage_constants.dart';

class ClipSourceRefDatasource {
  final AppDatabase db;
  final GoogleDriveStorageService googleDriveStorageService;

  ClipSourceRefDatasource(this.db, this.googleDriveStorageService);

  String? get _currentAccountId => fb.FirebaseAuth.instance.currentUser?.uid;

  // ─────────────────────────────────────────────────────────────────
  // Clip visibility (현재 로그인 계정/gdrive 계정 기준 가시성 필터)
  // ─────────────────────────────────────────────────────────────────

  Future<bool> isClipVisible(Clip clip) async {
    if (clip.ownerScope == ClipStorageConstants.ownerScopeDevice) return true;
    if (clip.ownerScope == ClipStorageConstants.ownerScopeAppAccount) {
      final accountId = _currentAccountId;
      return accountId != null && clip.ownerKey == accountId;
    }
    if (clip.ownerScope == ClipStorageConstants.ownerScopeCloudAccount) {
      final accountKey = await googleDriveStorageService.currentAccountKey();
      return accountKey != null && clip.ownerKey == accountKey;
    }
    return false;
  }

  Future<List<Clip>> visibleClips() async {
    final rows = await db.select(db.clips).get();
    final visible = <Clip>[];
    for (final clip in rows) {
      if (await isClipVisible(clip)) {
        visible.add(clip);
      }
    }
    return visible;
  }

  Future<List<Clip>> visibleClipsByStorageMode(String storageMode) async {
    final clips = await visibleClips();
    return clips.where((clip) => clip.storageMode == storageMode).toList()
      ..sort((a, b) => b.id.compareTo(a.id));
  }

  Future<List<Clip>> visibleRemoteClips() async {
    final clips = await visibleClips();
    return clips
        .where((clip) => clip.storageMode != ClipStorageConstants.storageModeLocal)
        .toList();
  }

  /// 현재 보이는(가시성 필터를 통과한) 클립들이 속한 컬렉션 id 집합.
  /// CollectionRepository가 "보이는 컬렉션 목록"을 계산할 때 사용합니다.
  Future<Set<int>> visibleCollectionIds() async {
    final clips = await visibleClips();
    return clips
        .where((clip) => clip.collectionId != null)
        .map((clip) => clip.collectionId!)
        .toSet();
  }

  String providerForStorageMode(String storageMode) {
    return switch (storageMode) {
      ClipStorageConstants.storageModeServer =>
        ClipStorageConstants.providerServer,
      ClipStorageConstants.storageModeGoogleDrive =>
        ClipStorageConstants.providerGoogleDrive,
      _ => throw StateError('원격 저장 방식이 올바르지 않습니다.'),
    };
  }

  String ownerScopeForProvider(String provider) {
    return switch (provider) {
      ClipStorageConstants.providerServer =>
        ClipStorageConstants.ownerScopeAppAccount,
      ClipStorageConstants.providerGoogleDrive =>
        ClipStorageConstants.ownerScopeCloudAccount,
      _ => throw StateError('원격 저장 제공자가 올바르지 않습니다.'),
    };
  }

  Future<String?> currentOwnerKeyForProvider(String provider) async {
    return switch (provider) {
      ClipStorageConstants.providerServer => _currentAccountId,
      ClipStorageConstants.providerGoogleDrive =>
        googleDriveStorageService.currentAccountKey(),
      _ => null,
    };
  }

  Future<ClipSourceRef?> getClipSourceRef({
    required int clipId,
    required String provider,
    required String ownerScope,
    required String ownerKey,
  }) {
    return (db.select(db.clipSourceRefs)
          ..where(
            (c) =>
                c.clipId.equals(clipId) &
                c.provider.equals(provider) &
                c.ownerScope.equals(ownerScope) &
                c.ownerKey.equals(ownerKey),
          )
          ..limit(1))
        .getSingleOrNull();
  }

  Future<ClipSourceRef> requireCurrentClipSourceRef(Clip clip) async {
    final ref = await getCurrentClipSourceRef(clip);
    if (ref == null) {
      throw StateError('현재 소유자의 원격 원본 정보를 찾을 수 없습니다.');
    }
    return ref;
  }

  Future<ClipSourceRef?> getCurrentClipSourceRef(Clip clip) async {
    if (clip.storageMode == ClipStorageConstants.storageModeLocal) return null;
    final provider = providerForStorageMode(clip.storageMode);
    final ownerScope = ownerScopeForProvider(provider);
    final ownerKey = await currentOwnerKeyForProvider(provider);
    if (ownerKey == null || ownerKey.isEmpty) return null;
    return getClipSourceRef(
      clipId: clip.id,
      provider: provider,
      ownerScope: ownerScope,
      ownerKey: ownerKey,
    );
  }

  Future<ClipCacheEntry?> getCurrentClipCacheEntry(Clip clip) async {
    final sourceRef = await getCurrentClipSourceRef(clip);
    if (sourceRef == null) return null;
    return getClipCacheEntryForSourceRef(sourceRef);
  }

  Future<ClipCacheEntry?> getClipCacheEntryForSourceRef(
    ClipSourceRef sourceRef,
  ) {
    return getClipCacheEntry(
      clipId: sourceRef.clipId,
      provider: sourceRef.provider,
      ownerScope: sourceRef.ownerScope,
      ownerKey: sourceRef.ownerKey,
    );
  }

  Future<ClipCacheEntry?> getClipCacheEntry({
    required int clipId,
    required String provider,
    required String ownerScope,
    required String ownerKey,
  }) async {
    return (db.select(db.clipCacheEntries)
          ..where(
            (c) =>
                c.clipId.equals(clipId) &
                c.provider.equals(provider) &
                c.ownerScope.equals(ownerScope) &
                c.ownerKey.equals(ownerKey),
          )
          ..limit(1))
        .getSingleOrNull();
  }

  Future<void> upsertClipSourceRef({
    required int clipId,
    required String provider,
    required String ownerScope,
    required String ownerKey,
    required String remoteDocId,
    String? storagePath,
    String? downloadUrl,
    String? thumbnailStoragePath,
    String? thumbnailDownloadUrl,
    String? thumbnailRemoteFileId,
    String? remoteFileId,
    String? cloudFolderId,
    String? metadataPath,
    required DateTime lastSyncedAt,
  }) async {
    await db.into(db.clipSourceRefs).insertOnConflictUpdate(
          ClipSourceRefsCompanion.insert(
            clipId: clipId,
            provider: provider,
            ownerScope: ownerScope,
            ownerKey: ownerKey,
            remoteDocId: remoteDocId,
            storagePath: Value(storagePath),
            downloadUrl: Value(downloadUrl),
            thumbnailStoragePath: Value(thumbnailStoragePath),
            thumbnailDownloadUrl: Value(thumbnailDownloadUrl),
            thumbnailRemoteFileId: Value(thumbnailRemoteFileId),
            remoteFileId: Value(remoteFileId),
            cloudFolderId: Value(cloudFolderId),
            metadataPath: Value(metadataPath),
            lastSyncedAt: Value(lastSyncedAt),
          ),
        );
  }

  Future<void> upsertClipCacheEntry({
    required int clipId,
    required String provider,
    required String ownerScope,
    required String ownerKey,
    required String filePath,
    required int storageBytes,
  }) async {
    await db.into(db.clipCacheEntries).insertOnConflictUpdate(
          ClipCacheEntriesCompanion.insert(
            clipId: clipId,
            provider: provider,
            ownerScope: ownerScope,
            ownerKey: ownerKey,
            filePath: filePath,
            storageBytes: Value(storageBytes),
            cachedAt: Value(DateTime.now()),
            lastAccessedAt: Value(DateTime.now()),
          ),
        );
  }

  Future<void> retainOnlyCurrentRemoteRows({
    required int clipId,
    required String provider,
    required String ownerScope,
    required String ownerKey,
  }) async {
    await (db.delete(db.clipSourceRefs)
          ..where(
            (c) =>
                c.clipId.equals(clipId) &
                (c.provider.equals(provider) &
                        c.ownerScope.equals(ownerScope) &
                        c.ownerKey.equals(ownerKey))
                    .not(),
          ))
        .go();
    await (db.delete(db.clipCacheEntries)
          ..where(
            (c) =>
                c.clipId.equals(clipId) &
                (c.provider.equals(provider) &
                        c.ownerScope.equals(ownerScope) &
                        c.ownerKey.equals(ownerKey))
                    .not(),
          ))
        .go();
  }

  Future<void> deleteAllRemoteRowsForClip(int clipId) async {
    await (db.delete(db.clipSourceRefs)..where((c) => c.clipId.equals(clipId)))
        .go();
    await (db.delete(db.clipCacheEntries)
          ..where((c) => c.clipId.equals(clipId)))
        .go();
  }

  Future<List<ClipCacheEntry>> currentCacheEntries() async {
    final entries = await db.select(db.clipCacheEntries).get();
    final appAccountId = _currentAccountId;
    final googleAccountKey = await googleDriveStorageService.currentAccountKey();

    return entries.where((entry) {
      if (entry.ownerScope == ClipStorageConstants.ownerScopeAppAccount) {
        return appAccountId != null && entry.ownerKey == appAccountId;
      }
      if (entry.ownerScope == ClipStorageConstants.ownerScopeCloudAccount) {
        return googleAccountKey != null && entry.ownerKey == googleAccountKey;
      }
      return false;
    }).toList();
  }

  /// 서버(Firebase Storage)/Google Drive에 올라간 원본·썸네일 파일과 metadata.json을
  /// 삭제합니다. Firestore의 library 문서 자체는 호출자가 별도로 지웁니다.
  Future<void> deleteRemoteLinkSource(ClipSourceRef sourceRef) async {
    if (sourceRef.provider == ClipStorageConstants.providerServer) {
      await _deleteRemoteStorageObject(
        storagePath: sourceRef.storagePath,
        downloadUrl: sourceRef.downloadUrl,
      );
      await _deleteRemoteStorageObject(
        storagePath: sourceRef.thumbnailStoragePath,
        downloadUrl: sourceRef.thumbnailDownloadUrl,
      );
      return;
    }

    if (sourceRef.provider == ClipStorageConstants.providerGoogleDrive) {
      final remoteFileId = sourceRef.remoteFileId;
      if (remoteFileId != null && remoteFileId.isNotEmpty) {
        await googleDriveStorageService.deleteFile(remoteFileId);
      }
      final thumbnailRemoteFileId = sourceRef.thumbnailRemoteFileId;
      if (thumbnailRemoteFileId != null && thumbnailRemoteFileId.isNotEmpty) {
        await googleDriveStorageService.deleteFile(thumbnailRemoteFileId);
      }
      final folderId = sourceRef.cloudFolderId;
      if (folderId != null && folderId.isNotEmpty) {
        await googleDriveStorageService.deleteFileNamedInFolder(
          folderId: folderId,
          fileName: 'metadata.json',
        );
      }
    }
  }

  Future<void> _deleteRemoteStorageObject({
    String? storagePath,
    String? downloadUrl,
  }) async {
    final ref = storagePath != null && storagePath.isNotEmpty
        ? FirebaseStorage.instance.ref(storagePath)
        : (downloadUrl != null && downloadUrl.isNotEmpty
            ? FirebaseStorage.instance.refFromURL(downloadUrl)
            : null);
    if (ref == null) return;

    try {
      await ref.delete();
    } catch (e, st) {
      AppLogger.w(
        '[Clip][Storage] remote-delete failed',
        error: e,
        stackTrace: st,
      );
    }
  }
}
