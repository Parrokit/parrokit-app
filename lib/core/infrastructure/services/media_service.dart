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
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:video_thumbnail/video_thumbnail.dart';
import '../../../data/local/app_database.dart';
import '../../../data/models/clip_item.dart';
import '../../../data/models/clip_view.dart';
import '../../shared/utils/app_logger.dart';
import 'cloud/google_drive_storage_service.dart';
import 'firebase/sync_status.dart';

typedef ClipServerUploadProgressCallback = void Function(
  int current,
  int total,
  String message,
);

/// 미디어 데이터(Group, Collection, Clip) 조작 및 비즈니스 로직 담당 서비스
/// 추후 Local/Server 동기화를 위해 MediaRepository 인터페이스로 추출될 수 있음.
class MediaService {
  final AppDatabase db;
  final GoogleDriveStorageService _googleDriveStorageService =
      GoogleDriveStorageService();

  MediaService(this.db);

  // ─────────────────────────────────────────────────────────────────
  // Group Operations
  // ─────────────────────────────────────────────────────────────────

  Future<List<Group>> getAllGroups() => db.groupsDao.getAllGroups();

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

    final segments = await (db.select(db.segments)
          ..where((s) => s.clipId.equals(clip.id))
          ..orderBy([(s) => OrderingTerm.asc(s.startMs)]))
        .get();

    final abs = await _absolutePathFor(clip.filePath);
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

      // 1. DB 삭제 트랜잭션
      await db.transaction(() async {
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
      if (target.filePath.isNotEmpty) {
        try {
          final abs = await _absolutePathFor(target.filePath);
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
              storageBytes: Value(storageBytes),
              durationMs: durationMs,
              syncStatus: const Value(SyncStatus.pending),
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
          storageBytes: Value(await _fileSizeFor(filePath)),
          durationMs: Value(durationMs),
          syncStatus: const Value(SyncStatus.pending),
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

    final absPath = await _absolutePathFor(target.filePath);
    final file = File(absPath);
    if (!await file.exists()) {
      throw StateError('업로드할 파일을 찾을 수 없습니다.');
    }

    final remoteDocId = target.remoteId ?? clipId.toString();
    final storagePath = 'users/${user.uid}/clips/$clipId/source';
    final storageRef = FirebaseStorage.instance.ref(storagePath);
    final fileSize = await file.length();
    onProgress?.call(0, fileSize, 'server 업로드 준비 중');

    final uploadTask = storageRef.putFile(file);
    late final StreamSubscription<TaskSnapshot> subscription;
    try {
      subscription = uploadTask.snapshotEvents.listen((snapshot) {
        final total = snapshot.totalBytes > 0 ? snapshot.totalBytes : fileSize;
        onProgress?.call(
          snapshot.bytesTransferred,
          total,
          'server 업로드 중',
        );
      });

      final taskSnapshot = await uploadTask;
      final downloadUrl = await taskSnapshot.ref.getDownloadURL();
      final now = DateTime.now();

      final collectionRemoteId =
          await _collectionRemoteIdForClip(target.collectionId);

      await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .collection('namespaces')
          .doc('library')
          .collection('clips')
          .doc(remoteDocId)
          .set({
        'localId': target.id,
        'collectionLocalId': target.collectionId,
        if (collectionRemoteId != null)
          'collectionRemoteId': collectionRemoteId,
        'title': target.title,
        'storageMode': 'server',
        'storageBytes': target.storageBytes,
        'durationMs': target.durationMs,
        'storagePath': storagePath,
        'downloadUrl': downloadUrl,
        'updatedAt': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));

      await (db.update(db.clips)..where((c) => c.id.equals(clipId))).write(
        ClipsCompanion(
          remoteId: Value(remoteDocId),
          storageMode: const Value('server'),
          syncStatus: const Value(SyncStatus.synced),
          lastSyncedAt: Value(now),
        ),
      );

      AppLogger.i(
        '[Clip][Storage] move-to-server success clipId=$clipId remoteId=$remoteDocId',
      );
    } finally {
      await subscription.cancel();
    }
  }

  /// 클립 파일을 Google Drive로 업로드하고 cloud:gdrive 상태로 전환합니다.
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

    final absPath = await _absolutePathFor(target.filePath);
    final file = File(absPath);
    if (!await file.exists()) {
      throw StateError('업로드할 파일을 찾을 수 없습니다.');
    }

    onProgress?.call(0, 0, 'Google Drive 연결 확인 중');
    final fileName = _buildDriveFileName(target, absPath);
    final result = await _googleDriveStorageService.uploadClipFile(
      file: file,
      fileName: fileName,
      clipId: target.id.toString(),
      title: target.title,
      storageBytes: target.storageBytes,
      durationMs: target.durationMs,
      onProgress: onProgress,
    );

    final user = fb.FirebaseAuth.instance.currentUser;
    if (user != null) {
      final collectionRemoteId =
          await _collectionRemoteIdForClip(target.collectionId);
      await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .collection('namespaces')
          .doc('library')
          .collection('clips')
          .doc(result.fileId)
          .set({
        'localId': target.id,
        'collectionLocalId': target.collectionId,
        if (collectionRemoteId != null)
          'collectionRemoteId': collectionRemoteId,
        'title': target.title,
        'storageMode': 'cloud:gdrive',
        'storageProvider': 'gdrive',
        'storageBytes': target.storageBytes,
        'durationMs': target.durationMs,
        'remoteFileId': result.fileId,
        'cloudFolderId': result.folderId,
        'downloadUrl': result.webContentLink ?? result.webViewLink,
        'updatedAt': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));
    }

    final now = DateTime.now();
    await (db.update(db.clips)..where((c) => c.id.equals(clipId))).write(
      ClipsCompanion(
        remoteId: Value(result.fileId),
        storageMode: const Value('cloud:gdrive'),
        syncStatus: const Value(SyncStatus.synced),
        lastSyncedAt: Value(now),
      ),
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

    final remoteId = target.remoteId;
    if (remoteId == null || remoteId.isEmpty) {
      await _ensureLocalClipFileExists(target);
      await _markClipAsLocal(clipId: clipId, remoteId: null);
      AppLogger.i(
          '[Clip][Storage] move-to-local success clipId=$clipId reason=no-remote-id');
      return;
    }

    if (target.storageMode.startsWith('cloud:')) {
      await _moveCloudClipToLocal(
        clipId: clipId,
        target: target,
        remoteId: remoteId,
      );
      return;
    }

    final remoteDocRef = FirebaseFirestore.instance
        .collection('users')
        .doc(user.uid)
        .collection('namespaces')
        .doc('library')
        .collection('clips')
        .doc(remoteId);
    final remoteDoc = await remoteDocRef.get();
    final remoteData = remoteDoc.data();
    if (remoteData == null) {
      throw StateError('서버 메타데이터를 찾을 수 없습니다.');
    }

    final storagePath = remoteData['storagePath'] as String?;
    final downloadUrl = remoteData['downloadUrl'] as String?;

    await _ensureLocalClipFileExists(
      target,
      storagePath: storagePath,
      downloadUrl: downloadUrl,
    );

    await _deleteRemoteStorageObject(
        storagePath: storagePath, downloadUrl: downloadUrl);

    await remoteDocRef.set({
      'localId': target.id,
      'collectionLocalId': target.collectionId,
      'title': target.title,
      'storageMode': 'local',
      'storageBytes': target.storageBytes,
      'durationMs': target.durationMs,
      'storagePath': FieldValue.delete(),
      'downloadUrl': FieldValue.delete(),
      'updatedAt': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));

    await _markClipAsLocal(clipId: clipId, remoteId: remoteId);

    AppLogger.i(
        '[Clip][Storage] move-to-local success clipId=$clipId remoteId=$remoteId');
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

  Future<String?> _collectionRemoteIdForClip(int? collectionId) async {
    if (collectionId == null) return null;
    final collection = await (db.select(db.collections)
          ..where((c) => c.id.equals(collectionId))
          ..limit(1))
        .getSingleOrNull();
    return collection?.remoteId;
  }

  Future<void> _moveCloudClipToLocal({
    required int clipId,
    required Clip target,
    required String remoteId,
  }) async {
    final absPath = await _absolutePathFor(target.filePath);
    final localFile = File(absPath);
    if (!await localFile.exists() || await localFile.length() == 0) {
      await _googleDriveStorageService.downloadClipFile(
        fileId: remoteId,
        destination: localFile,
      );
    }

    try {
      await _googleDriveStorageService.deleteFile(remoteId);
    } catch (e, st) {
      AppLogger.w(
        '[Clip][Storage] cloud-delete failed remoteId=$remoteId',
        error: e,
        stackTrace: st,
      );
    }

    final user = fb.FirebaseAuth.instance.currentUser;
    if (user != null) {
      final remoteDocRef = FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .collection('namespaces')
          .doc('library')
          .collection('clips')
          .doc(remoteId);
      await remoteDocRef.set({
        'localId': target.id,
        'collectionLocalId': target.collectionId,
        'title': target.title,
        'storageMode': 'local',
        'storageBytes': target.storageBytes,
        'durationMs': target.durationMs,
        'remoteFileId': FieldValue.delete(),
        'cloudFolderId': FieldValue.delete(),
        'downloadUrl': FieldValue.delete(),
        'updatedAt': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));
    }

    await _markClipAsLocal(clipId: clipId, remoteId: null);
    AppLogger.i(
      '[Clip][Storage] move-to-local success clipId=$clipId storage=cloud',
    );
  }

  Future<void> _ensureLocalClipFileExists(
    Clip target, {
    String? storagePath,
    String? downloadUrl,
  }) async {
    final absPath = await _absolutePathFor(target.filePath);
    final file = File(absPath);
    if (await file.exists() && await file.length() > 0) {
      return;
    }

    final ref = storagePath != null && storagePath.isNotEmpty
        ? FirebaseStorage.instance.ref(storagePath)
        : (downloadUrl != null && downloadUrl.isNotEmpty
            ? FirebaseStorage.instance.refFromURL(downloadUrl)
            : null);
    if (ref == null) {
      throw StateError('로컬 파일을 복원할 수 없습니다.');
    }

    await file.parent.create(recursive: true);
    await ref.writeToFile(file);
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

  Future<void> _markClipAsLocal({
    required int clipId,
    required String? remoteId,
  }) async {
    final now = DateTime.now();
    await (db.update(db.clips)..where((c) => c.id.equals(clipId))).write(
      ClipsCompanion(
        remoteId: remoteId == null ? const Value.absent() : Value(remoteId),
        storageMode: const Value('local'),
        syncStatus: const Value(SyncStatus.synced),
        lastSyncedAt: Value(now),
      ),
    );
  }

  String _buildDriveFileName(Clip clip, String absPath) {
    final extension = p.extension(absPath);
    final safeTitle =
        clip.title.replaceAll(RegExp(r'[\\/:*?"<>|]'), '_').trim();
    final baseName = safeTitle.isEmpty ? 'clip_${clip.id}' : safeTitle;
    return 'clip_${clip.id}_$baseName${extension.isEmpty ? '.mp4' : extension}';
  }

  Future<int> getServerStorageUsedBytes() async {
    final rows = await (db.select(db.clips)
          ..where((c) => c.storageMode.equals('server')))
        .get();
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
    final rows = await (db.select(db.clips)
          ..where((c) => c.storageMode.like('cloud:%')))
        .get();
    return rows.fold<int>(
        0, (totalBytes, clip) => totalBytes + clip.storageBytes);
  }

  Future<List<ClipItem>> fetchClipItemsByStorageMode(
    String storageMode,
  ) async {
    final clips = await (db.select(db.clips)
          ..where((c) => c.storageMode.equals(storageMode))
          ..orderBy([(c) => OrderingTerm.desc(c.lastSyncedAt)]))
        .get();
    return _buildClipItems(clips);
  }

  Future<GoogleDriveStorageQuota?> getGoogleDriveStorageQuota() async {
    return _googleDriveStorageService.fetchStorageQuota();
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

      final absPath = await _absolutePathFor(clip.filePath);

      Uint8List? thumbBytes;
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

      items.add(
        ClipItem(
          clip: clip,
          tags: tagsByClip[clip.id] ?? const [],
          segments: segments,
          thumbnail: thumbBytes,
        ),
      );
    }

    return items;
  }
}
