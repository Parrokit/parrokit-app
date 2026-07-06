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

import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:drift/drift.dart';
import 'package:firebase_auth/firebase_auth.dart' as fb;
import 'package:firebase_storage/firebase_storage.dart';
import 'package:path_provider/path_provider.dart';
import '../../../data/local/app_database.dart';
import '../../../data/models/clip_view.dart';
import '../../shared/utils/app_logger.dart';
import 'firebase/sync_status.dart';

/// 미디어 데이터(Group, Collection, Clip) 조작 및 비즈니스 로직 담당 서비스
/// 추후 Local/Server 동기화를 위해 MediaRepository 인터페이스로 추출될 수 있음.
class MediaService {
  final AppDatabase db;

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
  Future<void> moveClipToServer(int clipId) async {
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
    final uploadTask = await storageRef.putFile(file);
    final downloadUrl = await uploadTask.ref.getDownloadURL();
    final now = DateTime.now();

    final collectionRemoteId = await _collectionRemoteIdForClip(target.collectionId);

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
      if (collectionRemoteId != null) 'collectionRemoteId': collectionRemoteId,
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

  Future<int> getServerStorageUsedBytes() async {
    final rows = await (db.select(db.clips)
          ..where((c) => c.storageMode.equals('server')))
        .get();
    return rows.fold<int>(0, (totalBytes, clip) => totalBytes + clip.storageBytes);
  }
}
