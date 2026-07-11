// ============================================================================
// lib/core/collection_media/data/datasources/remote_doc_id_resolver.dart
// ============================================================================
//
// [역할]
// Clip의 원격 문서 ID(remoteDocId) 생성 담당.
//
// [레이어]
// Core > Collection Media > Data > Datasources
// ============================================================================

import 'package:uuid/uuid.dart';

class RemoteDocIdResolver {
  String newClipDocId() {
    return const Uuid().v4();
  }
}
