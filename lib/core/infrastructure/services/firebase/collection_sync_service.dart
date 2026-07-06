import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:drift/drift.dart';

import 'package:parrokit/data/local/app_database.dart' as db;

import 'sync_status.dart';

/// 로컬 collection 메타데이터를 Firestore로 동기화하는 서비스.
///
/// - collections 먼저 동기화
/// - clips는 collection remoteId를 참조해 동기화
/// - segments / tags는 clip 문서에 내장해서 초기 구조를 단순화
class CollectionSyncService {
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

  /// 전체 collection 메타데이터를 동기화합니다.
  Future<void> syncCollectionData({required String uid}) async {
    await _syncCollections(uid: uid);
    await _syncClips(uid: uid);
  }

  CollectionReference<Map<String, dynamic>> _collectionsRef(String uid) {
    return _firestore.collection('users').doc(uid).collection('collections');
  }

  CollectionReference<Map<String, dynamic>> _clipsRef(String uid) {
    return _firestore.collection('users').doc(uid).collection('clips');
  }

  Future<void> _syncCollections({required String uid}) async {
    final rows = await _db.select(_db.collections).get();
    final ref = _collectionsRef(uid);
    final now = DateTime.now().toUtc();

    for (final collection in rows) {
      if (collection.remoteId != null &&
          collection.syncStatus == SyncStatus.synced) {
        continue;
      }

      final docRef = collection.remoteId == null
          ? ref.doc()
          : ref.doc(collection.remoteId);

      await docRef.set({
        'name': collection.name,
        'localId': collection.id,
        'updatedAt': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));

      await (_db.update(_db.collections)..where((c) => c.id.equals(collection.id)))
          .write(
        db.CollectionsCompanion(
          remoteId: Value(docRef.id),
          syncStatus: const Value(SyncStatus.synced),
          lastSyncedAt: Value(now),
        ),
      );
    }
  }

  Future<void> _syncClips({required String uid}) async {
    final clips = await _db.select(_db.clips).get();
    final collectionRows = await _db.select(_db.collections).get();
    final collectionRemoteIdByLocalId = <int, String>{
      for (final collection in collectionRows)
        if (collection.remoteId != null) collection.id: collection.remoteId!,
    };
    final ref = _clipsRef(uid);
    final now = DateTime.now().toUtc();

    for (final clip in clips) {
      if (clip.remoteId != null && clip.syncStatus == SyncStatus.synced) {
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

      final docRef =
          clip.remoteId == null ? ref.doc() : ref.doc(clip.remoteId);

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
    }
  }
}
