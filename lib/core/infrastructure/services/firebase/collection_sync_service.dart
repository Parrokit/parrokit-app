import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:drift/drift.dart';

import 'package:parrokit/data/local/app_database.dart' as db;
import 'package:parrokit/core/shared/utils/app_logger.dart';

import 'sync_status.dart';

typedef CollectionSyncProgressCallback = void Function(
  int current,
  int total,
  String message,
);

/// 로컬 collection 메타데이터를 Firestore로 동기화하는 서비스.
///
/// - collections 먼저 동기화
/// - clips는 collection remoteId를 참조해 동기화
/// - segments / tags는 clip 문서에 내장해서 초기 구조를 단순화
class CollectionSyncService {
  static const String _namespacesCollectionName = 'namespaces';
  static const String _libraryNamespaceId = 'library';
  static const String _syncNamespaceId = 'sync';
  static const String _syncMetaCollectionName = 'meta';
  static const String _syncMetaDocId = 'collectionData';

  CollectionSyncService({
    db.AppDatabase? database,
    FirebaseFirestore? firestore,
  })  : _database = database,
        _firestore = firestore ?? FirebaseFirestore.instance;

  final db.AppDatabase? _database;
  final FirebaseFirestore _firestore;

  db.AppDatabase get _db {
    final database = _database;
    if (database == null) {
      throw StateError('AppDatabase가 초기화되지 않았습니다.');
    }
    return database;
  }

  DocumentReference<Map<String, dynamic>> _collectionDataSyncDoc(String uid) {
    return _firestore
        .collection('users')
        .doc(uid)
        .collection(_namespacesCollectionName)
        .doc(_syncNamespaceId)
        .collection(_syncMetaCollectionName)
        .doc(_syncMetaDocId);
  }

  DocumentReference<Map<String, dynamic>> _libraryNamespaceDoc(String uid) {
    return _firestore
        .collection('users')
        .doc(uid)
        .collection(_namespacesCollectionName)
        .doc(_libraryNamespaceId);
  }

  CollectionReference<Map<String, dynamic>> _groupsRef(String uid) {
    return _libraryNamespaceDoc(uid).collection('groups');
  }

  CollectionReference<Map<String, dynamic>> _groupCollectionsRef(String uid) {
    return _libraryNamespaceDoc(uid).collection('groupCollections');
  }

  Future<bool> needsInitialBackfill(String uid) async {
    AppLogger.d(
      '[Collection][Backfill] check-remote-meta uid=${_maskUid(uid)}',
    );
    try {
      final metaSnap = await _collectionDataSyncDoc(uid).get();
      final metaDone = metaSnap.data()?['initialBackfillDone'] == true;
      if (metaDone) return false;

      final counts = await _countPendingItems();
      AppLogger.d(
        '[Collection][Backfill] check-local-pending uid=${_maskUid(uid)} groups=${counts.groups} groupCollections=${counts.groupCollections} collections=${counts.collections} clips=${counts.clips} total=${counts.total}',
      );
      return counts.total > 0;
    } catch (e, st) {
      AppLogger.e(
        '[Collection][Backfill] check-failed uid=${_maskUid(uid)}',
        error: e,
        stackTrace: st,
      );
      rethrow;
    }
  }

  /// 전체 collection 메타데이터를 동기화합니다.
  Future<void> syncCollectionData({
    required String uid,
    CollectionSyncProgressCallback? onProgress,
    bool force = false,
  }) async {
    AppLogger.i(
      '[Collection][Backfill] service-start uid=${_maskUid(uid)} force=$force',
    );
    try {
      if (!force && !await needsInitialBackfill(uid)) {
        AppLogger.i(
          '[Collection][Backfill] service-skip uid=${_maskUid(uid)} reason=no-pending',
        );
        onProgress?.call(1, 1, '이미 백필이 완료되었습니다.');
        return;
      }

      final counts = await _countPendingItems(force: force);
      AppLogger.d(
        '[Collection][Backfill] service-counts uid=${_maskUid(uid)} groups=${counts.groups} groupCollections=${counts.groupCollections} collections=${counts.collections} clips=${counts.clips} total=${counts.total}',
      );
      if (counts.total == 0) {
        await _markInitialBackfillDone(uid);
        onProgress?.call(1, 1, '동기화할 collection 데이터가 없습니다.');
        AppLogger.i(
          '[Collection][Backfill] service-empty uid=${_maskUid(uid)}',
        );
        return;
      }

      var current = 0;
      onProgress?.call(current, counts.total, 'collection 동기화 준비');

      current = await _syncGroups(
        uid: uid,
        current: current,
        total: counts.total,
        onProgress: onProgress,
      );
      current = await _syncCollections(
        uid: uid,
        force: force,
        current: current,
        total: counts.total,
        onProgress: onProgress,
      );
      current = await _syncGroupCollections(
        uid: uid,
        current: current,
        total: counts.total,
        onProgress: onProgress,
      );
      current = await _syncClips(
        uid: uid,
        force: force,
        current: current,
        total: counts.total,
        onProgress: onProgress,
      );

      await _markInitialBackfillDone(uid);
      onProgress?.call(current, counts.total, 'collection 백필 완료');
      AppLogger.i(
        '[Collection][Backfill] service-success uid=${_maskUid(uid)} total=${counts.total}',
      );
    } catch (e, st) {
      AppLogger.e(
        '[Collection][Backfill] service-failed uid=${_maskUid(uid)}',
        error: e,
        stackTrace: st,
      );
      rethrow;
    }
  }

  CollectionReference<Map<String, dynamic>> _collectionsRef(String uid) {
    return _libraryNamespaceDoc(uid).collection('collections');
  }

  CollectionReference<Map<String, dynamic>> _clipsRef(String uid) {
    return _libraryNamespaceDoc(uid).collection('clips');
  }

  Future<_SyncCounts> _countPendingItems({bool force = false}) async {
    try {
      final groups = await _db.select(_db.groups).get();
      final groupCollections = await _db.select(_db.groupCollections).get();
      final collections = await _db.select(_db.collections).get();
      final clips = await _db.select(_db.clips).get();

      return _SyncCounts(
        groups: groups.length,
        groupCollections: groupCollections.length,
        collections: force
            ? collections.length
            : collections.where(_needsCollectionSync).length,
        clips: force ? clips.length : clips.where(_needsClipSync).length,
      );
    } catch (e, st) {
      AppLogger.e(
        '[Collection][Backfill] count-failed',
        error: e,
        stackTrace: st,
      );
      rethrow;
    }
  }

  Future<int> _syncGroups({
    required String uid,
    required int current,
    required int total,
    CollectionSyncProgressCallback? onProgress,
  }) async {
    final rows = await _db.select(_db.groups).get();
    final ref = _groupsRef(uid);
    AppLogger.d(
      '[Collection][Backfill] groups-start uid=${_maskUid(uid)} rows=${rows.length}',
    );

    for (final group in rows) {
      final docRef = ref.doc(group.id.toString());
      await docRef.set({
        'localId': group.id,
        'name': group.name,
        'updatedAt': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));

      current++;
      onProgress?.call(current, total, 'group $current / $total 동기화 중');
    }

    AppLogger.d(
      '[Collection][Backfill] groups-end uid=${_maskUid(uid)} current=$current total=$total',
    );
    return current;
  }

  bool _needsCollectionSync(db.Collection row) {
    return row.remoteId != row.id.toString() ||
        row.syncStatus != SyncStatus.synced;
  }

  bool _needsClipSync(db.Clip row) {
    return row.remoteId != row.id.toString() ||
        row.syncStatus != SyncStatus.synced;
  }

  Future<int> _syncCollections({
    required String uid,
    required bool force,
    required int current,
    required int total,
    CollectionSyncProgressCallback? onProgress,
  }) async {
    final rows = await _db.select(_db.collections).get();
    final ref = _collectionsRef(uid);
    final now = DateTime.now().toUtc();
    AppLogger.d(
      '[Collection][Backfill] collections-start uid=${_maskUid(uid)} rows=${rows.length}',
    );

    for (final collection in rows) {
      if (!force && !_needsCollectionSync(collection)) {
        continue;
      }

      final docId = collection.id.toString();
      final docRef = ref.doc(docId);
      await _cleanupLegacyDocs(
        ref: ref,
        localId: collection.id,
        stableDocId: docId,
      );

      await docRef.set({
        'name': collection.name,
        'localId': collection.id,
        'updatedAt': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));

      await (_db.update(_db.collections)
            ..where((c) => c.id.equals(collection.id)))
          .write(
        db.CollectionsCompanion(
          remoteId: Value(docRef.id),
          syncStatus: const Value(SyncStatus.synced),
          lastSyncedAt: Value(now),
        ),
      );

      current++;
      onProgress?.call(
        current,
        total,
        'collection $current / $total 동기화 중',
      );
    }

    AppLogger.d(
      '[Collection][Backfill] collections-end uid=${_maskUid(uid)} current=$current total=$total',
    );
    return current;
  }

  Future<int> _syncGroupCollections({
    required String uid,
    required int current,
    required int total,
    CollectionSyncProgressCallback? onProgress,
  }) async {
    final rows = await _db.select(_db.groupCollections).get();
    final collectionRows = await _db.select(_db.collections).get();
    final collectionRemoteIdByLocalId = <int, String>{
      for (final collection in collectionRows)
        if (collection.remoteId != null) collection.id: collection.remoteId!,
    };
    final ref = _groupCollectionsRef(uid);
    AppLogger.d(
      '[Collection][Backfill] groupCollections-start uid=${_maskUid(uid)} rows=${rows.length}',
    );

    for (final row in rows) {
      final collectionRemoteId = collectionRemoteIdByLocalId[row.collectionId];
      if (collectionRemoteId == null) {
        throw StateError(
          '그룹(${row.groupId})의 컬렉션(${row.collectionId})이 아직 서버에 동기화되지 않았습니다.',
        );
      }

      final docId = '${row.groupId}_${row.collectionId}';
      final docRef = ref.doc(docId);
      await docRef.set({
        'groupLocalId': row.groupId,
        'collectionLocalId': row.collectionId,
        'collectionRemoteId': collectionRemoteId,
        'updatedAt': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));

      current++;
      onProgress?.call(
        current,
        total,
        'groupCollection $current / $total 동기화 중',
      );
    }

    AppLogger.d(
      '[Collection][Backfill] groupCollections-end uid=${_maskUid(uid)} current=$current total=$total',
    );
    return current;
  }

  Future<int> _syncClips({
    required String uid,
    required bool force,
    required int current,
    required int total,
    CollectionSyncProgressCallback? onProgress,
  }) async {
    final clips = await _db.select(_db.clips).get();
    final collectionRows = await _db.select(_db.collections).get();
    final collectionRemoteIdByLocalId = <int, String>{
      for (final collection in collectionRows)
        if (collection.remoteId != null) collection.id: collection.remoteId!,
    };
    final ref = _clipsRef(uid);
    final now = DateTime.now().toUtc();
    AppLogger.d(
      '[Collection][Backfill] clips-start uid=${_maskUid(uid)} rows=${clips.length}',
    );

    for (final clip in clips) {
      if (!force && !_needsClipSync(clip)) {
        continue;
      }

      final segments = await (_db.select(_db.segments)
            ..where((s) => s.clipId.equals(clip.id))
            ..orderBy([(s) => OrderingTerm.asc(s.startMs)]))
          .get();

      final tagRows = await (_db.select(_db.tags).join([
        innerJoin(
          _db.clipTags,
          _db.clipTags.tagId.equalsExp(_db.tags.id),
        ),
      ])
            ..where(_db.clipTags.clipId.equals(clip.id)))
          .get();

      final tagNames = tagRows
          .map((row) => row.readTable(_db.tags).name)
          .where((name) => name.isNotEmpty)
          .toList();

      final collectionRemoteId = clip.collectionId == null
          ? null
          : collectionRemoteIdByLocalId[clip.collectionId!];
      if (clip.collectionId != null && collectionRemoteId == null) {
        throw StateError(
          '클립(${clip.id})의 컬렉션이 아직 서버에 동기화되지 않았습니다.',
        );
      }

      final docId = clip.id.toString();
      final docRef = ref.doc(docId);
      await _cleanupLegacyDocs(
        ref: ref,
        localId: clip.id,
        stableDocId: docId,
      );

      await docRef.set({
        'localId': clip.id,
        'collectionRemoteId': collectionRemoteId,
        'collectionLocalId': clip.collectionId,
        'title': clip.title,
        'storageMode': clip.storageMode,
        'storageBytes': clip.storageBytes,
        'durationMs': clip.durationMs,
        'tags': tagNames,
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
        'updatedAt': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));

      await (_db.update(_db.clips)..where((c) => c.id.equals(clip.id))).write(
        db.ClipsCompanion(
          remoteId: Value(docRef.id),
          syncStatus: const Value(SyncStatus.synced),
          lastSyncedAt: Value(now),
        ),
      );

      current++;
      onProgress?.call(
        current,
        total,
        'clip $current / $total 동기화 중',
      );
    }

    AppLogger.d(
      '[Collection][Backfill] clips-end uid=${_maskUid(uid)} current=$current total=$total',
    );
    return current;
  }

  Future<void> _cleanupLegacyDocs({
    required CollectionReference<Map<String, dynamic>> ref,
    required int localId,
    required String stableDocId,
  }) async {
    final legacyDocs = await ref.where('localId', isEqualTo: localId).get();
    for (final doc in legacyDocs.docs) {
      if (doc.id == stableDocId) continue;
      await doc.reference.delete();
    }
  }

  Future<void> _markInitialBackfillDone(String uid) async {
    AppLogger.i(
      '[Collection][Backfill] mark-done uid=${_maskUid(uid)}',
    );
    await _collectionDataSyncDoc(uid).set(
      {
        'initialBackfillDone': true,
        'lastBackfillAt': FieldValue.serverTimestamp(),
      },
      SetOptions(merge: true),
    );
  }

  String _maskUid(String uid) {
    if (uid.length <= 4) return '****';
    return '***${uid.substring(uid.length - 4)}';
  }
}

class _SyncCounts {
  final int groups;
  final int groupCollections;
  final int collections;
  final int clips;

  const _SyncCounts({
    required this.groups,
    required this.groupCollections,
    required this.collections,
    required this.clips,
  });

  int get total => groups + groupCollections + collections + clips;
}
