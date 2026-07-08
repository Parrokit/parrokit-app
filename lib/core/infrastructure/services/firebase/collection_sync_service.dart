import 'package:cloud_firestore/cloud_firestore.dart';

import 'package:parrokit/data/local/app_database.dart' as db;
import 'package:parrokit/core/shared/utils/app_logger.dart';

typedef CollectionSyncProgressCallback = void Function(
  int current,
  int total,
  String message,
);

/// 로컬 클립 자동 백필은 최종 v3 스키마에서 비활성화합니다.
///
/// 서버/클라우드 원격 메타데이터는 명시적인 저장 위치 전환 시점에만 생성합니다.
class CollectionSyncService {
  CollectionSyncService({
    db.AppDatabase? database,
    FirebaseFirestore? firestore,
  });

  Future<bool> needsInitialBackfill(String uid) async {
    AppLogger.i(
      '[Collection][Backfill] disabled uid=${_maskUid(uid)}',
    );
    return false;
  }

  Future<void> syncCollectionData({
    required String uid,
    CollectionSyncProgressCallback? onProgress,
    bool force = false,
  }) async {
    AppLogger.i(
      '[Collection][Backfill] skip disabled uid=${_maskUid(uid)} force=$force',
    );
    onProgress?.call(1, 1, '자동 백필은 사용하지 않습니다.');
  }

  String _maskUid(String uid) {
    if (uid.length <= 4) return '****';
    return '***${uid.substring(uid.length - 4)}';
  }
}
