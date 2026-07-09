// ============================================================================
// lib/core/collection_media/data/datasources/remote_doc_id_resolver.dart
// ============================================================================
//
// [역할]
// Clip/Collection/Group의 원격 문서 ID(remoteDocId) 생성 및 SharedPreferences
// 캐싱. Firestore 메타데이터 동기화(ClipFirestoreMetadataDatasource)와
// Google Drive metadata.json 빌더(ClipCloudMetadataDatasource)가 공통으로
// 사용합니다 — 두 곳에서 각자 구현하면 같은 컬렉션/그룹에 서로 다른
// remoteDocId가 발급되는 불일치가 생길 수 있어 반드시 이 클래스를 통해서만
// 발급합니다.
//
// [레이어]
// Core > Collection Media > Data > Datasources
// ============================================================================

import 'package:shared_preferences/shared_preferences.dart';
import 'package:uuid/uuid.dart';

class RemoteDocIdResolver {
  static const String _remoteCollectionIdPrefsPrefix =
      'library.remote_collection_id';
  static const String _remoteGroupIdPrefsPrefix = 'library.remote_group_id';

  String newClipDocId() {
    return const Uuid().v4();
  }

  Future<String> collectionDocId({
    required String uid,
    required int collectionId,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    final prefKey = '$_remoteCollectionIdPrefsPrefix.$uid.$collectionId';
    final saved = prefs.getString(prefKey);
    if (saved != null && saved.isNotEmpty) {
      return saved;
    }

    final remoteDocId = const Uuid().v4();
    await prefs.setString(prefKey, remoteDocId);
    return remoteDocId;
  }

  Future<String> groupDocId({
    required String uid,
    required int groupId,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    final prefKey = '$_remoteGroupIdPrefsPrefix.$uid.$groupId';
    final saved = prefs.getString(prefKey);
    if (saved != null && saved.isNotEmpty) {
      return saved;
    }

    final remoteDocId = const Uuid().v4();
    await prefs.setString(prefKey, remoteDocId);
    return remoteDocId;
  }
}
