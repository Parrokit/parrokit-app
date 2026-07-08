// ============================================================================
// lib/core/services/media_service.dart
// ============================================================================
//
// [역할]
// 미디어 데이터(Collection, Clip) 조작 및 비즈니스 로직 담당 서비스
//
// [레이어]
// Core > Services
// ============================================================================

import 'dart:async';
import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:drift/drift.dart';
import 'package:firebase_auth/firebase_auth.dart' as fb;
import 'package:firebase_storage/firebase_storage.dart';
import 'package:mime/mime.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:video_thumbnail/video_thumbnail.dart';
import 'package:uuid/uuid.dart';
import '../../../data/local/app_database.dart';
import '../../../data/models/clip_item.dart';
import '../../../data/models/clip_view.dart';
import '../../shared/utils/app_logger.dart';
import 'cloud/google_drive_storage_service.dart';

typedef ClipServerUploadProgressCallback = void Function(
  int current,
  int total,
  String message,
);

/// 미디어 데이터(Group, Collection, Clip) 조작 및 비즈니스 로직 담당 서비스
/// 추후 Local/Server 동기화를 위해 MediaRepository 인터페이스로 추출될 수 있음.
class MediaService {
  static const String _legacyAdoptedPrefsPrefix =
      'library.legacy_storage_adopted';
  static const String _ownerScopeDevice = 'device';
  static const String _ownerScopeAppAccount = 'app_account';
  static const String _ownerScopeCloudAccount = 'cloud_account';
  static const String _providerServer = 'server';
  static const String _providerGoogleDrive = 'gdrive';

  final AppDatabase db;
  final GoogleDriveStorageService _googleDriveStorageService =
      GoogleDriveStorageService();

  MediaService(this.db);

  String? get _currentAccountId => fb.FirebaseAuth.instance.currentUser?.uid;

  Future<void> adoptLegacyStorageOwnershipIfNeeded(String accountId) async {
    final prefs = await SharedPreferences.getInstance();
    final prefKey = '$_legacyAdoptedPrefsPrefix.$accountId';
    if (prefs.getBool(prefKey) != true) {
      await prefs.setBool(prefKey, true);
    }
  }

  // ─────────────────────────────────────────────────────────────────
  // Group Operations
  // ─────────────────────────────────────────────────────────────────

  Future<List<Group>> getAllGroups() async {
    final allGroups = await db.groupsDao.getAllGroups();
    final visibleCollectionIds = await _visibleCollectionIds();
    if (visibleCollectionIds.isEmpty) return [];

    final mappings = await (db.select(db.groupCollections)
          ..where((gc) => gc.collectionId.isIn(visibleCollectionIds)))
        .get();
    final visibleGroupIds = mappings.map((m) => m.groupId).toSet();

    return allGroups
        .where((group) => visibleGroupIds.contains(group.id))
        .toList()
      ..sort((a, b) => a.name.compareTo(b.name));
  }

  Future<List<Collection>> getVisibleCollectionsForGroup(int? groupId) async {
    final visibleCollectionIds = await _visibleCollectionIds();
    if (visibleCollectionIds.isEmpty) return const [];

    List<Collection> rows;
    if (groupId == null) {
      final query = db.select(db.collections).join([
        leftOuterJoin(
          db.groupCollections,
          db.groupCollections.collectionId.equalsExp(db.collections.id),
        ),
      ])
        ..where(
          db.groupCollections.groupId.isNull() &
              db.collections.id.isIn(visibleCollectionIds),
        );
      final joined = await query.get();
      rows = joined.map((r) => r.readTable(db.collections)).toList();
    } else if (groupId == -1) {
      rows = await (db.select(db.collections)
            ..where((c) => c.id.isIn(visibleCollectionIds)))
          .get();
    } else {
      final query = db.select(db.collections).join([
        innerJoin(
          db.groupCollections,
          db.groupCollections.collectionId.equalsExp(db.collections.id),
        ),
      ])
        ..where(
          db.groupCollections.groupId.equals(groupId) &
              db.collections.id.isIn(visibleCollectionIds),
        );
      final joined = await query.get();
      rows = joined.map((r) => r.readTable(db.collections)).toList();
    }

    rows.sort((a, b) => a.name.compareTo(b.name));
    return rows;
  }

  Future<List<Collection>> getAllVisibleCollections() async {
    final visibleCollectionIds = await _visibleCollectionIds();
    if (visibleCollectionIds.isEmpty) return const [];
    final rows = await (db.select(db.collections)
          ..where((c) => c.id.isIn(visibleCollectionIds))
          ..orderBy([(c) => OrderingTerm.asc(c.name)]))
        .get();
    return rows;
  }

  Future<List<Clip>> getVisibleClipsForCollection(int? collectionId) async {
    final rows = await _visibleClips();
    final filtered = rows.where((clip) {
      if (collectionId == null) return clip.collectionId == null;
      return clip.collectionId == collectionId;
    }).toList();
    filtered.sort((a, b) => a.id.compareTo(b.id));
    return filtered;
  }

  Future<int> countVisibleClipsInCollection(int collectionId) async {
    final clips = await getVisibleClipsForCollection(collectionId);
    return clips.length;
  }

  Future<void> createGroup(String name) => db.groupsDao.insertGroup(name);

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

  // ─────────────────────────────────────────────────────────────────
  // Clip Operations
  // ─────────────────────────────────────────────────────────────────

  /// Clip ID로 단일 클립 정보(세그먼트 포함) 조회.
  Future<ClipView?> fetchClipById(int clipId) async {
    final clip = await (db.select(db.clips)
          ..where((c) => c.id.equals(clipId))
          ..limit(1))
        .getSingleOrNull();
    if (clip == null) return null;

    if (!await _isClipVisible(clip)) {
      return null;
    }

    final segments = await (db.select(db.segments)
          ..where((s) => s.clipId.equals(clip.id))
          ..orderBy([(s) => OrderingTerm.asc(s.startMs)]))
        .get();

    final abs = await _ensurePlayableClipFile(clip);
    final clipAbs = clip.copyWith(filePath: abs);

    return ClipView(clip: clipAbs, segments: segments);
  }

  /// Clip 삭제 (파일 및 고아 컬렉션 정리 포함).
  Future<bool> deleteClipById(int clipId) async {
    Clip? target;
    try {
      target = await (db.select(db.clips)
            ..where((c) => c.id.equals(clipId))
            ..limit(1))
          .getSingleOrNull();
      if (target == null) return false;

      final oldCollectionId = target.collectionId;

      final sourceRef = await _getCurrentClipSourceRef(target);
      if (sourceRef != null) {
        await _deleteRemoteLinkSource(sourceRef);
        if (sourceRef.provider == _providerServer &&
            sourceRef.ownerScope == _ownerScopeAppAccount) {
          await _deleteLibraryClipDoc(
              sourceRef.ownerKey, sourceRef.remoteDocId);
        }
      }

      final cacheEntries = await (db.select(db.clipCacheEntries)
            ..where((c) => c.clipId.equals(clipId)))
          .get();

      // 1. DB 삭제 트랜잭션
      await db.transaction(() async {
        await (db.delete(db.clipCacheEntries)
              ..where((c) => c.clipId.equals(clipId)))
            .go();
        await (db.delete(db.clipSourceRefs)
              ..where((c) => c.clipId.equals(clipId)))
            .go();
        await (db.delete(db.segments)..where((s) => s.clipId.equals(clipId)))
            .go();
        await (db.delete(db.clipTags)..where((ct) => ct.clipId.equals(clipId)))
            .go();
        await (db.delete(db.clips)..where((c) => c.id.equals(clipId))).go();
      });

      // 2. 고아 컬렉션 정리
      if (oldCollectionId != null) {
        await db.collectionsDao.pruneIfEmpty(oldCollectionId);
      }

      // 3. 파일 삭제 (절대 경로 보정 후)
      final sourcePath = target.sourceFilePath ?? target.filePath;
      if (sourcePath.isNotEmpty) {
        try {
          final abs = await _absolutePathFor(sourcePath);
          final f = File(abs);
          if (await f.exists()) await f.delete();
        } catch (_) {}
      }

      for (final cacheEntry in cacheEntries) {
        try {
          final abs = await _absolutePathFor(cacheEntry.filePath);
          final f = File(abs);
          if (await f.exists()) await f.delete();
        } catch (_) {}
      }

      return true;
    } catch (_) {
      return false;
    }
  }

  /// 미디어 추가 (Collection 선택적 생성 + Clip 삽입).
  Future<void> addMedia({
    required String? collectionName,
    required String clipTitle,
    required String filePath,
    required int durationMs,
    required List<Segment> segments,
    required List<String>? tags,
  }) async {
    final storageBytes = await _fileSizeFor(filePath);
    await db.transaction(() async {
      // 컬렉션 선택적 생성
      int? collectionId;
      if (collectionName != null && collectionName.trim().isNotEmpty) {
        final col = await db.collectionsDao.findOrCreate(collectionName.trim());
        collectionId = col.id;
      }

      final clipId = await db.into(db.clips).insert(
            ClipsCompanion.insert(
              collectionId: Value(collectionId),
              title: clipTitle,
              filePath: filePath,
              sourceFilePath: Value(filePath),
              storageBytes: Value(storageBytes),
              durationMs: durationMs,
              ownerScope: const Value(_ownerScopeDevice),
            ),
          );

      for (final s in segments) {
        await db.into(db.segments).insert(
              SegmentsCompanion.insert(
                clipId: clipId,
                startMs: s.startMs,
                endMs: s.endMs,
                original: s.original,
                pron: s.pron,
                trans: s.trans,
              ),
            );
      }

      if (tags != null) {
        for (final name in tags) {
          final tagId = await _ensureTag(name);
          await db.into(db.clipTags).insert(
                ClipTagsCompanion.insert(clipId: clipId, tagId: tagId),
                mode: InsertMode.insertOrIgnore,
              );
        }
      }
    });
  }

  /// 미디어 정보 수정 (컬렉션 변경 + 고아 컬렉션 정리 포함).
  Future<void> updateMedia({
    required int clipId,
    required String? collectionName,
    required String clipTitle,
    required String filePath,
    required int durationMs,
    required List<Segment> segments,
    required List<String>? tags,
    String? storageMode,
  }) async {
    // 이전 collectionId 확보
    final prevClip = await (db.select(db.clips)
          ..where((c) => c.id.equals(clipId)))
        .getSingle();
    final oldCollectionId = prevClip.collectionId;

    await db.transaction(() async {
      // 새 컬렉션 결정
      int? newCollectionId;
      if (collectionName != null && collectionName.trim().isNotEmpty) {
        final col = await db.collectionsDao.findOrCreate(collectionName.trim());
        newCollectionId = col.id;
      }

      // 클립 갱신
      await (db.update(db.clips)..where((c) => c.id.equals(clipId))).write(
        ClipsCompanion(
          collectionId: Value(newCollectionId),
          title: Value(clipTitle),
          filePath: Value(filePath),
          sourceFilePath: Value(filePath),
          storageBytes: Value(await _fileSizeFor(filePath)),
          durationMs: Value(durationMs),
          storageMode:
              storageMode == null ? const Value.absent() : Value(storageMode),
        ),
      );

      // 세그먼트 재작성 (Full replace)
      await (db.delete(db.segments)..where((s) => s.clipId.equals(clipId)))
          .go();
      for (final s in segments) {
        await db.into(db.segments).insert(
              SegmentsCompanion.insert(
                clipId: clipId,
                startMs: s.startMs,
                endMs: s.endMs,
                original: s.original,
                pron: s.pron,
                trans: s.trans,
              ),
            );
      }

      // 태그 갱신
      if (tags != null) {
        await (db.delete(db.clipTags)..where((ct) => ct.clipId.equals(clipId)))
            .go();
        for (final name in tags.toSet()) {
          final tagId = await _ensureTag(name);
          await db.into(db.clipTags).insert(
                ClipTagsCompanion.insert(clipId: clipId, tagId: tagId),
                mode: InsertMode.insertOrIgnore,
              );
        }
      }
    });

    // 이전 컬렉션 고아 정리 (트랜잭션 밖에서)
    if (oldCollectionId != null) {
      await db.collectionsDao.pruneIfEmpty(oldCollectionId);
    }
  }

  /// 클립 파일을 서버 저장소로 업로드하고 서버 저장 상태로 전환합니다.
  Future<void> moveClipToServer(
    int clipId, {
    ClipServerUploadProgressCallback? onProgress,
  }) async {
    AppLogger.i('[Clip][Storage] move-to-server start clipId=$clipId');

    final target = await (db.select(db.clips)
          ..where((c) => c.id.equals(clipId))
          ..limit(1))
        .getSingleOrNull();
    if (target == null) {
      throw StateError('클립을 찾을 수 없습니다.');
    }

    final user = fb.FirebaseAuth.instance.currentUser;
    if (user == null) {
      throw StateError('서버 저장하려면 로그인이 필요합니다.');
    }

    final previousStorageMode = target.storageMode;
    final previousSourceRef = await _getCurrentClipSourceRef(target);

    final sourcePath = await _resolveUploadSourcePath(target);
    final absPath = await _absolutePathFor(sourcePath);
    final file = File(absPath);
    if (!await file.exists()) {
      throw StateError('업로드할 파일을 찾을 수 없습니다.');
    }

    final remoteDocId = previousSourceRef?.remoteDocId ?? _remoteDocIdForClip();
    final extension = p.extension(absPath);
    final normalizedExtension = extension.isEmpty ? '.mp4' : extension;
    final contentType = lookupMimeType(absPath) ?? 'application/octet-stream';
    final fileSize = await file.length();
    onProgress?.call(0, fileSize, 'server 업로드 준비 중');
    final storagePath =
        'users/${user.uid}/clips/$remoteDocId/video$normalizedExtension';

    Future<({String storagePath, String downloadUrl})> uploadToPath(
      String storagePath,
    ) async {
      final storageRef = FirebaseStorage.instance.ref(storagePath);
      final metadata = SettableMetadata(contentType: contentType);
      AppLogger.d(
        '[Clip][Storage] server-upload start clipId=$clipId path=$storagePath contentType=$contentType bytes=$fileSize',
      );

      Future<({String storagePath, String downloadUrl})> runTask(
        UploadTask uploadTask, {
        required String progressMessage,
      }) async {
        late final StreamSubscription<TaskSnapshot> subscription;
        try {
          subscription = uploadTask.snapshotEvents.listen((snapshot) {
            final total =
                snapshot.totalBytes > 0 ? snapshot.totalBytes : fileSize;
            onProgress?.call(
              snapshot.bytesTransferred,
              total,
              progressMessage,
            );
          });

          final taskSnapshot = await uploadTask;
          AppLogger.d(
            '[Clip][Storage] server-upload-finished clipId=$clipId path=$storagePath mode=$progressMessage',
          );
          final downloadUrl = await taskSnapshot.ref.getDownloadURL();
          return (storagePath: storagePath, downloadUrl: downloadUrl);
        } finally {
          await subscription.cancel();
        }
      }

      try {
        return await runTask(
          storageRef.putFile(file, metadata),
          progressMessage: 'server 업로드 중',
        );
      } on fb.FirebaseException catch (e, st) {
        AppLogger.w(
          '[Clip][Storage] server-upload putFile-failed clipId=$clipId path=$storagePath code=${e.code} message=${e.message}',
          error: e,
          stackTrace: st,
        );

        final bytes = await file.readAsBytes();
        AppLogger.d(
          '[Clip][Storage] server-upload fallback-putData clipId=$clipId path=$storagePath bytes=${bytes.length}',
        );
        return runTask(
          storageRef.putData(bytes, metadata),
          progressMessage: 'server 업로드 재시도 중',
        );
      }
    }

    late final ({String storagePath, String downloadUrl}) uploadResult;
    try {
      uploadResult = await uploadToPath(storagePath);

      final now = DateTime.now();

      final docRef = _libraryClipDocRef(user.uid, remoteDocId);
      await _cleanupLegacyLibraryClipDocs(
        uid: user.uid,
        clipId: clipId,
        keepDocId: remoteDocId,
      );
      await docRef.set({
        'localId': target.id,
        'collectionLocalId': target.collectionId,
        'title': target.title,
        'storageMode': 'server',
        'storageBytes': target.storageBytes,
        'durationMs': target.durationMs,
        'storagePath': uploadResult.storagePath,
        'downloadUrl': uploadResult.downloadUrl,
        'remoteFileId': FieldValue.delete(),
        'cloudFolderId': FieldValue.delete(),
        'storageProvider': FieldValue.delete(),
        'updatedAt': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));

      await _upsertClipSourceRef(
        clipId: clipId,
        provider: _providerServer,
        ownerScope: _ownerScopeAppAccount,
        ownerKey: user.uid,
        remoteDocId: remoteDocId,
        storagePath: uploadResult.storagePath,
        downloadUrl: uploadResult.downloadUrl,
        lastSyncedAt: now,
      );
      await _upsertClipCacheEntry(
        clipId: clipId,
        provider: _providerServer,
        ownerScope: _ownerScopeAppAccount,
        ownerKey: user.uid,
        filePath: sourcePath,
        storageBytes: target.storageBytes,
      );

      await (db.update(db.clips)..where((c) => c.id.equals(clipId))).write(
        ClipsCompanion(
          filePath: const Value(''),
          sourceFilePath: const Value.absent(),
          ownerScope: const Value(_ownerScopeAppAccount),
          ownerKey: Value(user.uid),
          storageMode: const Value('server'),
        ),
      );

      await _cleanupPreviousRemoteSource(
        clipId: clipId,
        previousStorageMode: previousStorageMode,
        previousSourceRef: previousSourceRef,
      );

      AppLogger.i(
        '[Clip][Storage] move-to-server success clipId=$clipId remoteId=$remoteDocId',
      );
    } on fb.FirebaseException catch (e, st) {
      AppLogger.e(
        '[Clip][Storage] server-upload firebase-error clipId=$clipId code=${e.code} message=${e.message}',
        error: e,
        stackTrace: st,
      );
      rethrow;
    } on Exception catch (e, st) {
      AppLogger.e(
        '[Clip][Storage] server-upload error clipId=$clipId',
        error: e,
        stackTrace: st,
      );
      rethrow;
    }
  }

  /// 클립 파일을 Google Drive로 업로드하고 gdrive 상태로 전환합니다.
  Future<void> moveClipToGoogleDrive(
    int clipId, {
    ClipServerUploadProgressCallback? onProgress,
  }) async {
    AppLogger.i('[Clip][Storage] move-to-gdrive start clipId=$clipId');

    final target = await (db.select(db.clips)
          ..where((c) => c.id.equals(clipId))
          ..limit(1))
        .getSingleOrNull();
    if (target == null) {
      throw StateError('클립을 찾을 수 없습니다.');
    }

    final user = fb.FirebaseAuth.instance.currentUser;
    if (user == null) {
      throw StateError('Google Drive 저장하려면 로그인이 필요합니다.');
    }

    final previousStorageMode = target.storageMode;
    final previousSourceRef = await _getCurrentClipSourceRef(target);

    final sourcePath = await _resolveUploadSourcePath(target);
    final absPath = await _absolutePathFor(sourcePath);
    final file = File(absPath);
    if (!await file.exists()) {
      throw StateError('업로드할 파일을 찾을 수 없습니다.');
    }

    final remoteDocId = previousSourceRef?.remoteDocId ?? _remoteDocIdForClip();
    final extension = p.extension(absPath);
    final normalizedExtension = extension.isEmpty ? '.mp4' : extension;
    onProgress?.call(0, 0, 'Google Drive 연결 확인 중');
    final fileName = _buildDriveFileName(absPath);
    final cloudStoragePath = 'clips/$remoteDocId/video$normalizedExtension';
    final result = await _googleDriveStorageService.uploadClipFile(
      file: file,
      fileName: fileName,
      clipId: target.id.toString(),
      storagePath: cloudStoragePath,
      title: target.title,
      storageBytes: target.storageBytes,
      durationMs: target.durationMs,
      onProgress: onProgress,
    );

    final now = DateTime.now();
    await _upsertClipSourceRef(
      clipId: clipId,
      provider: _providerGoogleDrive,
      ownerScope: _ownerScopeCloudAccount,
      ownerKey: result.accountKey,
      remoteDocId: remoteDocId,
      storagePath: cloudStoragePath,
      downloadUrl: result.webContentLink ?? result.webViewLink,
      remoteFileId: result.fileId,
      cloudFolderId: result.folderId,
      lastSyncedAt: now,
    );
    await _upsertClipCacheEntry(
      clipId: clipId,
      provider: _providerGoogleDrive,
      ownerScope: _ownerScopeCloudAccount,
      ownerKey: result.accountKey,
      filePath: sourcePath,
      storageBytes: target.storageBytes,
    );
    await (db.update(db.clips)..where((c) => c.id.equals(clipId))).write(
      ClipsCompanion(
        filePath: const Value(''),
        sourceFilePath: const Value.absent(),
        ownerScope: const Value(_ownerScopeCloudAccount),
        ownerKey: Value(result.accountKey),
        storageMode: const Value(_providerGoogleDrive),
      ),
    );

    await _cleanupPreviousRemoteSource(
      clipId: clipId,
      previousStorageMode: previousStorageMode,
      previousSourceRef: previousSourceRef,
    );

    AppLogger.i(
      '[Clip][Storage] move-to-gdrive success clipId=$clipId remoteId=${result.fileId}',
    );
  }

  /// 서버 저장된 클립을 로컬 저장으로 전환합니다.
  ///
  /// - 로컬 파일이 없으면 서버 파일을 먼저 내려받습니다.
  /// - 그 다음 서버 원본 파일을 삭제합니다.
  /// - 로컬 DB와 Firestore 메타데이터는 local 모드로 갱신합니다.
  Future<void> moveClipToLocal(int clipId) async {
    AppLogger.i('[Clip][Storage] move-to-local start clipId=$clipId');

    final target = await (db.select(db.clips)
          ..where((c) => c.id.equals(clipId))
          ..limit(1))
        .getSingleOrNull();
    if (target == null) {
      throw StateError('클립을 찾을 수 없습니다.');
    }

    final user = fb.FirebaseAuth.instance.currentUser;
    if (user == null) {
      throw StateError('로컬 전환을 위해 로그인 정보가 필요합니다.');
    }

    final sourceRef = await _getCurrentClipSourceRef(target);
    if (sourceRef == null) {
      throw StateError('현재 계정의 원격 원본 정보를 찾을 수 없습니다.');
    }

    final sourcePath = await _ensureLocalSourcePath(
      target: target,
      sourceRef: sourceRef,
    );

    await _deleteRemoteLinkSource(sourceRef);
    if (sourceRef.provider == _providerServer &&
        sourceRef.ownerScope == _ownerScopeAppAccount) {
      await _deleteLibraryClipDoc(sourceRef.ownerKey, sourceRef.remoteDocId);
    }

    await db.transaction(() async {
      await (db.delete(db.clipSourceRefs)
            ..where(
              (c) =>
                  c.clipId.equals(clipId) &
                  c.provider.equals(sourceRef.provider) &
                  c.ownerScope.equals(sourceRef.ownerScope) &
                  c.ownerKey.equals(sourceRef.ownerKey),
            ))
          .go();
      await (db.delete(db.clipCacheEntries)
            ..where(
              (c) =>
                  c.clipId.equals(clipId) &
                  c.provider.equals(sourceRef.provider) &
                  c.ownerScope.equals(sourceRef.ownerScope) &
                  c.ownerKey.equals(sourceRef.ownerKey),
            ))
          .go();
      await (db.update(db.clips)..where((c) => c.id.equals(clipId))).write(
        ClipsCompanion(
          filePath: Value(sourcePath),
          sourceFilePath: Value(sourcePath),
          ownerScope: const Value(_ownerScopeDevice),
          ownerKey: const Value.absent(),
          storageMode: const Value('local'),
        ),
      );
    });

    AppLogger.i(
      '[Clip][Storage] move-to-local success clipId=$clipId remoteId=${sourceRef.remoteDocId}',
    );
  }

  // ─────────────────────────────────────────────────────────────────
  // Helpers (Private logic methods)
  // ─────────────────────────────────────────────────────────────────

  /// clip.filePath가 상대경로라면 App Documents와 합쳐 절대경로로 변환.
  Future<String> _absolutePathFor(String pathFromClip) async {
    if (pathFromClip.startsWith('/')) return pathFromClip;
    final dir = await getApplicationDocumentsDirectory();
    return '${dir.path}/$pathFromClip';
  }

  Future<int> _ensureTag(String name) async {
    final found = await (db.select(db.tags)..where((t) => t.name.equals(name)))
        .getSingleOrNull();
    if (found != null) return found.id;
    return db.into(db.tags).insert(
          TagsCompanion.insert(
            name: name,
          ),
        );
  }

  Future<int> _fileSizeFor(String pathFromClip) async {
    try {
      final abs = await _absolutePathFor(pathFromClip);
      final f = File(abs);
      if (await f.exists()) {
        return await f.length();
      }
    } catch (_) {}
    return 0;
  }

  Future<void> _cleanupPreviousRemoteSource({
    required int clipId,
    required String previousStorageMode,
    required ClipSourceRef? previousSourceRef,
  }) async {
    if (previousSourceRef == null) {
      return;
    }

    if (previousStorageMode == 'local') {
      return;
    }

    try {
      await _deleteRemoteLinkSource(previousSourceRef);
    } catch (e, st) {
      AppLogger.w(
        '[Clip][Storage] previous-remote-delete failed clipId=$clipId remoteDocId=${previousSourceRef.remoteDocId}',
        error: e,
        stackTrace: st,
      );
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

  String _buildDriveFileName(String absPath) {
    final extension = p.extension(absPath);
    return 'video${extension.isEmpty ? '.mp4' : extension}';
  }

  Future<int> getServerStorageUsedBytes() async {
    final rows = await _visibleClipsByStorageMode('server');
    return rows.fold<int>(
        0, (totalBytes, clip) => totalBytes + clip.storageBytes);
  }

  Future<int> getLocalStorageUsedBytes() async {
    final rows = await (db.select(db.clips)
          ..where((c) => c.storageMode.equals('local')))
        .get();
    return rows.fold<int>(
        0, (totalBytes, clip) => totalBytes + clip.storageBytes);
  }

  Future<int> getCloudStorageUsedBytes() async {
    final rows = await _visibleRemoteClips().then(
      (clips) => clips.where((clip) => clip.storageMode == 'gdrive').toList(),
    );
    return rows.fold<int>(
        0, (totalBytes, clip) => totalBytes + clip.storageBytes);
  }

  Future<bool> hasGoogleDriveLinked() async {
    return _googleDriveStorageService.hasConnectedAccount();
  }

  Future<void> connectGoogleDrive() async {
    final account = await _googleDriveStorageService.connect();
    if (account == null) {
      throw StateError('Google Drive 연동이 취소되었습니다.');
    }
  }

  Future<int> moveAllGoogleDriveClipsToLocal({
    void Function(int current, int total, String message)? onProgress,
  }) async {
    final clips = await _visibleClipsByStorageMode('gdrive');

    if (clips.isEmpty) {
      onProgress?.call(0, 0, '이동할 Google Drive 파일이 없습니다.');
      return 0;
    }

    var current = 0;
    for (final clip in clips) {
      onProgress?.call(
        current,
        clips.length,
        'Google Drive 파일을 로컬로 옮기는 중',
      );
      await moveClipToLocal(clip.id);
      current++;
      onProgress?.call(
        current,
        clips.length,
        'Google Drive 파일을 로컬로 옮기는 중',
      );
    }

    return current;
  }

  Future<void> disconnectGoogleDriveAfterLocalMove({
    void Function(int current, int total, String message)? onProgress,
  }) async {
    final moved = await moveAllGoogleDriveClipsToLocal(
      onProgress: onProgress,
    );
    if (moved == 0) {
      await _googleDriveStorageService.disconnect();
      return;
    }

    await _googleDriveStorageService.disconnect();
  }

  Future<int> getCachedRemoteStorageUsedBytes() async {
    final entries = await _currentCacheEntries();
    return entries.fold<int>(
      0,
      (totalBytes, entry) => totalBytes + entry.storageBytes,
    );
  }

  Future<int> getCachedRemoteClipCount() async {
    final entries = await _currentCacheEntries();
    return entries.length;
  }

  Future<List<ClipItem>> fetchClipItemsByStorageMode(
    String storageMode,
  ) async {
    final clips = await _visibleClipsByStorageMode(storageMode);
    return _buildClipItems(clips);
  }

  Future<List<ClipItem>> fetchCachedRemoteClipItems() async {
    final clips = await _fetchCachedRemoteClips();
    return _buildClipItems(clips);
  }

  Future<bool> clearRemoteClipCache(int clipId) async {
    final clip = await (db.select(db.clips)
          ..where((c) => c.id.equals(clipId))
          ..limit(1))
        .getSingleOrNull();
    if (clip == null) {
      throw StateError('클립을 찾을 수 없습니다.');
    }
    if (clip.storageMode == 'local') {
      throw StateError('로컬 저장본은 캐시로 지울 수 없습니다.');
    }

    final cacheEntry = await _getCurrentClipCacheEntry(clip);
    if (cacheEntry == null) {
      return true;
    }

    final absPath = await _absolutePathFor(cacheEntry.filePath);
    final file = File(absPath);
    if (await file.exists()) {
      await file.delete();
      AppLogger.i(
        '[Clip][Cache] clear-cache success clipId=$clipId path=$absPath',
      );
    } else {
      AppLogger.i(
        '[Clip][Cache] clear-cache skip-missing clipId=$clipId path=$absPath',
      );
    }
    await (db.delete(db.clipCacheEntries)
          ..where(
            (c) =>
                c.clipId.equals(clipId) &
                c.provider.equals(cacheEntry.provider) &
                c.ownerScope.equals(cacheEntry.ownerScope) &
                c.ownerKey.equals(cacheEntry.ownerKey),
          ))
        .go();
    return true;
  }

  Future<GoogleDriveStorageQuota?> getGoogleDriveStorageQuota() async {
    return _googleDriveStorageService.fetchStorageQuota();
  }

  Future<List<Clip>> _fetchCachedRemoteClips() async {
    final remoteClips = await _visibleRemoteClips();
    final cachedClips = <Clip>[];

    for (final clip in remoteClips) {
      final cacheEntry = await _getCurrentClipCacheEntry(clip);
      if (cacheEntry == null) continue;
      final absPath = await _absolutePathFor(cacheEntry.filePath);
      final file = File(absPath);
      if (await file.exists() && await file.length() > 0) {
        cachedClips.add(clip);
      }
    }

    return cachedClips;
  }

  Future<List<ClipItem>> _buildClipItems(List<Clip> clips) async {
    final tagsByClip = <int, List<Tag>>{};

    if (clips.isNotEmpty) {
      final clipIds = clips.map((c) => c.id).toList();
      final jt = db.clipTags;
      final rows = await (db.select(db.tags).join([
        innerJoin(jt, jt.tagId.equalsExp(db.tags.id)),
      ])
            ..where(jt.clipId.isIn(clipIds)))
          .get();

      for (final row in rows) {
        final tag = row.readTable(db.tags);
        final ct = row.readTable(jt);
        tagsByClip.putIfAbsent(ct.clipId, () => []).add(tag);
      }
    }

    final items = <ClipItem>[];
    for (final clip in clips) {
      final segments = await (db.select(db.segments)
            ..where((s) => s.clipId.equals(clip.id))
            ..orderBy([(s) => OrderingTerm.asc(s.startMs)]))
          .get();

      final previewPath = await _resolvePreviewPath(clip);

      Uint8List? thumbBytes;
      if (previewPath != null) {
        final absPath = await _absolutePathFor(previewPath);
        try {
          thumbBytes = await VideoThumbnail.thumbnailData(
            video: absPath,
            imageFormat: ImageFormat.JPEG,
            quality: 70,
            timeMs: 500,
          );
        } catch (_) {
          thumbBytes = null;
        }
      }

      final effectivePath = previewPath ?? clip.filePath;

      items.add(
        ClipItem(
          clip: clip.copyWith(filePath: effectivePath),
          tags: tagsByClip[clip.id] ?? const [],
          segments: segments,
          thumbnail: thumbBytes,
        ),
      );
    }

    return items;
  }

  Future<String> _ensurePlayableClipFile(Clip clip) async {
    if (clip.storageMode == 'local') {
      final sourcePath = clip.sourceFilePath ?? clip.filePath;
      final absPath = await _absolutePathFor(sourcePath);
      final file = File(absPath);
      if (await file.exists() && await file.length() > 0) {
        return absPath;
      }
      throw StateError('로컬 파일을 찾을 수 없습니다.');
    }

    final sourceRef = await _requireCurrentClipSourceRef(clip);
    final cacheEntry = await _getClipCacheEntryForSourceRef(sourceRef);
    if (cacheEntry != null) {
      final absPath = await _absolutePathFor(cacheEntry.filePath);
      final file = File(absPath);
      if (await file.exists() && await file.length() > 0) {
        return absPath;
      }
    }

    final relativePath = await _defaultCachePathForClip(
      clipId: clip.id,
      remoteDocId: sourceRef.remoteDocId,
      extensionHint: sourceRef.provider == _providerGoogleDrive
          ? p.extension(sourceRef.storagePath ?? sourceRef.remoteFileId ?? '')
          : p.extension(sourceRef.storagePath ?? ''),
    );
    final absPath = await _absolutePathFor(relativePath);
    final destination = File(absPath);

    if (sourceRef.provider == _providerServer) {
      await _restoreServerClipFile(sourceRef, destination);
    } else if (sourceRef.provider == _providerGoogleDrive) {
      await _restoreCloudClipFile(sourceRef, destination);
    } else {
      throw StateError('원격 저장 방식이 올바르지 않습니다.');
    }

    await _upsertClipCacheEntry(
      clipId: clip.id,
      provider: sourceRef.provider,
      ownerScope: sourceRef.ownerScope,
      ownerKey: sourceRef.ownerKey,
      filePath: relativePath,
      storageBytes: clip.storageBytes,
    );
    return absPath;
  }

  Future<void> _restoreServerClipFile(
    ClipSourceRef sourceRef,
    File destination,
  ) async {
    final ref = sourceRef.storagePath != null &&
            sourceRef.storagePath!.isNotEmpty
        ? FirebaseStorage.instance.ref(sourceRef.storagePath!)
        : (sourceRef.downloadUrl != null && sourceRef.downloadUrl!.isNotEmpty
            ? FirebaseStorage.instance.refFromURL(sourceRef.downloadUrl!)
            : null);
    if (ref == null) {
      throw StateError('서버 파일 경로를 찾을 수 없습니다.');
    }

    await destination.parent.create(recursive: true);
    await ref.writeToFile(destination);
  }

  Future<void> _restoreCloudClipFile(
    ClipSourceRef sourceRef,
    File destination,
  ) async {
    final remoteFileId = sourceRef.remoteFileId;
    if (remoteFileId == null || remoteFileId.isEmpty) {
      throw StateError('클라우드 원본 정보를 찾을 수 없습니다.');
    }

    await destination.parent.create(recursive: true);
    await _googleDriveStorageService.downloadClipFile(
      fileId: remoteFileId,
      destination: destination,
    );
  }

  Future<void> _deleteRemoteLinkSource(ClipSourceRef sourceRef) async {
    if (sourceRef.provider == _providerServer) {
      await _deleteRemoteStorageObject(
        storagePath: sourceRef.storagePath,
        downloadUrl: sourceRef.downloadUrl,
      );
      return;
    }

    if (sourceRef.provider == _providerGoogleDrive) {
      final remoteFileId = sourceRef.remoteFileId;
      if (remoteFileId == null || remoteFileId.isEmpty) return;
      await _googleDriveStorageService.deleteFile(remoteFileId);
    }
  }

  Future<String> _resolveUploadSourcePath(Clip clip) async {
    if (clip.storageMode == 'local') {
      final sourcePath = clip.sourceFilePath ?? clip.filePath;
      final absPath = await _absolutePathFor(sourcePath);
      final file = File(absPath);
      if (!await file.exists()) {
        throw StateError('로컬 원본 파일을 찾을 수 없습니다.');
      }
      return sourcePath;
    }

    final cacheEntry = await _getCurrentClipCacheEntry(clip);
    if (cacheEntry != null) {
      final absPath = await _absolutePathFor(cacheEntry.filePath);
      final file = File(absPath);
      if (await file.exists() && await file.length() > 0) {
        return cacheEntry.filePath;
      }
    }

    await _ensurePlayableClipFile(clip);
    final refreshed = await _getCurrentClipCacheEntry(clip);
    if (refreshed == null) {
      throw StateError('업로드할 재생 캐시를 준비하지 못했습니다.');
    }
    return refreshed.filePath;
  }

  Future<String> _ensureLocalSourcePath({
    required Clip target,
    required ClipSourceRef sourceRef,
  }) async {
    final existingSource = target.sourceFilePath;
    if (existingSource != null && existingSource.isNotEmpty) {
      final absPath = await _absolutePathFor(existingSource);
      final file = File(absPath);
      if (await file.exists() && await file.length() > 0) {
        return existingSource;
      }
    }

    final cacheEntry = await _getClipCacheEntryForSourceRef(sourceRef);
    if (cacheEntry != null) {
      final absPath = await _absolutePathFor(cacheEntry.filePath);
      final file = File(absPath);
      if (await file.exists() && await file.length() > 0) {
        return cacheEntry.filePath;
      }
    }

    final sourcePath = await _defaultSourcePathForClip(
      clipId: target.id,
      title: target.title,
      remoteDocId: sourceRef.remoteDocId,
      extensionHint: p.extension(
        sourceRef.storagePath ??
            sourceRef.remoteFileId ??
            sourceRef.downloadUrl ??
            '',
      ),
    );
    final absPath = await _absolutePathFor(sourcePath);
    final destination = File(absPath);
    if (sourceRef.provider == _providerServer) {
      await _restoreServerClipFile(sourceRef, destination);
    } else {
      await _restoreCloudClipFile(sourceRef, destination);
    }
    return sourcePath;
  }

  Future<String?> _resolvePreviewPath(Clip clip) async {
    if (clip.storageMode == 'local') {
      final sourcePath = clip.sourceFilePath ?? clip.filePath;
      if (sourcePath.isEmpty) return null;
      final absPath = await _absolutePathFor(sourcePath);
      final file = File(absPath);
      return await file.exists() && await file.length() > 0 ? sourcePath : null;
    }

    final cacheEntry = await _getCurrentClipCacheEntry(clip);
    if (cacheEntry == null) return null;

    final absPath = await _absolutePathFor(cacheEntry.filePath);
    final file = File(absPath);
    return await file.exists() && await file.length() > 0
        ? cacheEntry.filePath
        : null;
  }

  Future<List<Clip>> _visibleClipsByStorageMode(String storageMode) async {
    final clips = await _visibleClips();
    return clips.where((clip) => clip.storageMode == storageMode).toList()
      ..sort((a, b) => b.id.compareTo(a.id));
  }

  Future<List<Clip>> _visibleRemoteClips() async {
    final clips = await _visibleClips();
    return clips.where((clip) => clip.storageMode != 'local').toList();
  }

  Future<bool> _isClipVisible(Clip clip) async {
    if (clip.ownerScope == _ownerScopeDevice) return true;
    if (clip.ownerScope == _ownerScopeAppAccount) {
      final accountId = _currentAccountId;
      return accountId != null && clip.ownerKey == accountId;
    }
    if (clip.ownerScope == _ownerScopeCloudAccount) {
      final accountKey = await _googleDriveStorageService.currentAccountKey();
      return accountKey != null && clip.ownerKey == accountKey;
    }
    return false;
  }

  Future<List<Clip>> _visibleClips() async {
    final rows = await db.select(db.clips).get();
    final visible = <Clip>[];
    for (final clip in rows) {
      if (await _isClipVisible(clip)) {
        visible.add(clip);
      }
    }
    return visible;
  }

  Future<List<ClipCacheEntry>> _currentCacheEntries() async {
    final entries = await db.select(db.clipCacheEntries).get();
    final appAccountId = _currentAccountId;
    final googleAccountKey =
        await _googleDriveStorageService.currentAccountKey();

    return entries.where((entry) {
      if (entry.ownerScope == _ownerScopeAppAccount) {
        return appAccountId != null && entry.ownerKey == appAccountId;
      }
      if (entry.ownerScope == _ownerScopeCloudAccount) {
        return googleAccountKey != null && entry.ownerKey == googleAccountKey;
      }
      return false;
    }).toList();
  }

  String _providerForStorageMode(String storageMode) {
    return switch (storageMode) {
      'server' => _providerServer,
      'gdrive' => _providerGoogleDrive,
      _ => throw StateError('원격 저장 방식이 올바르지 않습니다.'),
    };
  }

  String _ownerScopeForProvider(String provider) {
    return switch (provider) {
      _providerServer => _ownerScopeAppAccount,
      _providerGoogleDrive => _ownerScopeCloudAccount,
      _ => throw StateError('원격 저장 제공자가 올바르지 않습니다.'),
    };
  }

  Future<String?> _currentOwnerKeyForProvider(String provider) async {
    return switch (provider) {
      _providerServer => _currentAccountId,
      _providerGoogleDrive => _googleDriveStorageService.currentAccountKey(),
      _ => null,
    };
  }

  Future<Set<int>> _visibleCollectionIds() async {
    final clips = await _visibleClips();
    return clips
        .where((clip) => clip.collectionId != null)
        .map((clip) => clip.collectionId!)
        .toSet();
  }

  Future<ClipSourceRef?> _getClipSourceRef({
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

  Future<ClipSourceRef> _requireCurrentClipSourceRef(Clip clip) async {
    final ref = await _getCurrentClipSourceRef(clip);
    if (ref == null) {
      throw StateError('현재 소유자의 원격 원본 정보를 찾을 수 없습니다.');
    }
    return ref;
  }

  Future<ClipSourceRef?> _getCurrentClipSourceRef(Clip clip) async {
    if (clip.storageMode == 'local') return null;
    final provider = _providerForStorageMode(clip.storageMode);
    final ownerScope = _ownerScopeForProvider(provider);
    final ownerKey = await _currentOwnerKeyForProvider(provider);
    if (ownerKey == null || ownerKey.isEmpty) return null;
    return _getClipSourceRef(
      clipId: clip.id,
      provider: provider,
      ownerScope: ownerScope,
      ownerKey: ownerKey,
    );
  }

  Future<ClipCacheEntry?> _getCurrentClipCacheEntry(Clip clip) async {
    final sourceRef = await _getCurrentClipSourceRef(clip);
    if (sourceRef == null) return null;
    return _getClipCacheEntryForSourceRef(sourceRef);
  }

  Future<ClipCacheEntry?> _getClipCacheEntryForSourceRef(
    ClipSourceRef sourceRef,
  ) {
    return _getClipCacheEntry(
      clipId: sourceRef.clipId,
      provider: sourceRef.provider,
      ownerScope: sourceRef.ownerScope,
      ownerKey: sourceRef.ownerKey,
    );
  }

  Future<ClipCacheEntry?> _getClipCacheEntry({
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

  Future<void> _upsertClipSourceRef({
    required int clipId,
    required String provider,
    required String ownerScope,
    required String ownerKey,
    required String remoteDocId,
    String? storagePath,
    String? downloadUrl,
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
            remoteFileId: Value(remoteFileId),
            cloudFolderId: Value(cloudFolderId),
            metadataPath: Value(metadataPath),
            lastSyncedAt: Value(lastSyncedAt),
          ),
        );
  }

  Future<void> _upsertClipCacheEntry({
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

  Future<String> _defaultCachePathForClip({
    required int clipId,
    required String remoteDocId,
    String? extensionHint,
  }) async {
    final ext = _normalizedVideoExtension(extensionHint);
    return 'media/cache/$remoteDocId/clip_$clipId$ext';
  }

  Future<String> _defaultSourcePathForClip({
    required int clipId,
    required String title,
    required String remoteDocId,
    String? extensionHint,
  }) async {
    final ext = _normalizedVideoExtension(extensionHint);
    final safeTitle = title.trim().isEmpty
        ? 'clip_$clipId'
        : title.replaceAll(RegExp(r'[^A-Za-z0-9가-힣._-]+'), '_');
    return 'media/local/${safeTitle}_$remoteDocId$ext';
  }

  String _normalizedVideoExtension(String? extensionHint) {
    final raw = (extensionHint ?? '').trim();
    if (raw.isEmpty) return '.mp4';
    return raw.startsWith('.') ? raw : '.$raw';
  }

  CollectionReference<Map<String, dynamic>> _libraryClipsRef(String uid) {
    return FirebaseFirestore.instance
        .collection('users')
        .doc(uid)
        .collection('namespaces')
        .doc('library')
        .collection('clips');
  }

  DocumentReference<Map<String, dynamic>> _libraryClipDocRef(
    String uid,
    String docId,
  ) {
    return _libraryClipsRef(uid).doc(docId);
  }

  Future<void> _deleteLibraryClipDoc(String uid, String docId) async {
    if (uid.isEmpty || docId.isEmpty) return;
    await _libraryClipDocRef(uid, docId).delete();
  }

  String _remoteDocIdForClip() {
    return const Uuid().v4();
  }

  Future<void> _cleanupLegacyLibraryClipDocs({
    required String uid,
    required int clipId,
    required String keepDocId,
  }) async {
    if (uid.isEmpty) return;

    final ref = _libraryClipsRef(uid);
    final docs = await ref.where('localId', isEqualTo: clipId).get();
    for (final doc in docs.docs) {
      if (doc.id == keepDocId) continue;
      await doc.reference.delete();
    }
  }
}
