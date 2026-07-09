// ============================================================================
// lib/core/collection_media/data/datasources/clip_firestore_metadata_datasource.dart
// ============================================================================
//
// [역할]
// server 저장 모드 클립의 Firestore('users/{uid}/namespaces/library/...')
// 메타데이터 동기화 전담 datasource.
//
// [레이어]
// Core > Collection Media > Data > Datasources
// ============================================================================

import 'package:cloud_firestore/cloud_firestore.dart';

import 'package:parrokit/data/local/app_database.dart';
import 'remote_doc_id_resolver.dart';

class ClipFirestoreMetadataDatasource {
  final AppDatabase db;
  final RemoteDocIdResolver remoteDocIdResolver;

  ClipFirestoreMetadataDatasource(this.db, this.remoteDocIdResolver);

  Future<String?> upsertServerCollectionMetadata({
    required String uid,
    required int? collectionId,
  }) async {
    if (collectionId == null) return null;

    final collection = await (db.select(db.collections)
          ..where((c) => c.id.equals(collectionId))
          ..limit(1))
        .getSingleOrNull();
    if (collection == null) return null;

    final remoteDocId = await remoteDocIdResolver.collectionDocId(
      uid: uid,
      collectionId: collection.id,
    );
    await _libraryCollectionsRef(uid).doc(remoteDocId).set({
      'localId': collection.id,
      'remoteDocId': remoteDocId,
      'name': collection.name,
      'updatedAt': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));

    await _upsertServerGroupsForCollection(
      uid: uid,
      collectionId: collection.id,
      collectionRemoteId: remoteDocId,
    );

    return remoteDocId;
  }

  Future<void> _upsertServerGroupsForCollection({
    required String uid,
    required int collectionId,
    required String collectionRemoteId,
  }) async {
    final mappings = await (db.select(db.groupCollections)
          ..where((gc) => gc.collectionId.equals(collectionId)))
        .get();

    for (final mapping in mappings) {
      final group = await (db.select(db.groups)
            ..where((g) => g.id.equals(mapping.groupId))
            ..limit(1))
          .getSingleOrNull();
      if (group == null) continue;

      final groupRemoteId = await remoteDocIdResolver.groupDocId(
        uid: uid,
        groupId: group.id,
      );
      await _libraryGroupsRef(uid).doc(groupRemoteId).set({
        'localId': group.id,
        'remoteDocId': groupRemoteId,
        'name': group.name,
        'updatedAt': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));

      final groupCollectionDocId = '${groupRemoteId}_$collectionRemoteId';
      await _libraryGroupCollectionsRef(uid).doc(groupCollectionDocId).set({
        'groupLocalId': group.id,
        'groupRemoteId': groupRemoteId,
        'collectionLocalId': collectionId,
        'collectionRemoteId': collectionRemoteId,
        'updatedAt': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));
    }
  }

  CollectionReference<Map<String, dynamic>> libraryClipsRef(String uid) {
    return FirebaseFirestore.instance
        .collection('users')
        .doc(uid)
        .collection('namespaces')
        .doc('library')
        .collection('clips');
  }

  CollectionReference<Map<String, dynamic>> _libraryCollectionsRef(String uid) {
    return FirebaseFirestore.instance
        .collection('users')
        .doc(uid)
        .collection('namespaces')
        .doc('library')
        .collection('collections');
  }

  CollectionReference<Map<String, dynamic>> _libraryGroupsRef(String uid) {
    return FirebaseFirestore.instance
        .collection('users')
        .doc(uid)
        .collection('namespaces')
        .doc('library')
        .collection('groups');
  }

  CollectionReference<Map<String, dynamic>> _libraryGroupCollectionsRef(
    String uid,
  ) {
    return FirebaseFirestore.instance
        .collection('users')
        .doc(uid)
        .collection('namespaces')
        .doc('library')
        .collection('groupCollections');
  }

  DocumentReference<Map<String, dynamic>> libraryClipDocRef(
    String uid,
    String docId,
  ) {
    return libraryClipsRef(uid).doc(docId);
  }

  Future<void> deleteLibraryClipDoc(String uid, String docId) async {
    if (uid.isEmpty || docId.isEmpty) return;
    await libraryClipDocRef(uid, docId).delete();
  }

  Future<void> cleanupLegacyLibraryClipDocs({
    required String uid,
    required int clipId,
    required String keepDocId,
  }) async {
    if (uid.isEmpty) return;

    final ref = libraryClipsRef(uid);
    final docs = await ref.where('localId', isEqualTo: clipId).get();
    for (final doc in docs.docs) {
      if (doc.id == keepDocId) continue;
      await doc.reference.delete();
    }
  }
}
