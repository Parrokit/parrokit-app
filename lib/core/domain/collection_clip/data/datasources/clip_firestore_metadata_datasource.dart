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

class ClipFirestoreMetadataDatasource {
  final AppDatabase db;

  ClipFirestoreMetadataDatasource(this.db);

  CollectionReference<Map<String, dynamic>> libraryClipsRef(String uid) {
    return FirebaseFirestore.instance
        .collection('users')
        .doc(uid)
        .collection('namespaces')
        .doc('library')
        .collection('clips');
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
