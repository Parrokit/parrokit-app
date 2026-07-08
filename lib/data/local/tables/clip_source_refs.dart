import 'package:drift/drift.dart';

import 'clips.dart';

class ClipSourceRefs extends Table {
  IntColumn get clipId => integer().references(Clips, #id)();
  TextColumn get provider => text()(); // server/gdrive
  TextColumn get ownerScope => text()(); // app_account/cloud_account
  TextColumn get ownerKey => text()();
  TextColumn get remoteDocId => text()();
  TextColumn get storagePath => text().nullable()();
  TextColumn get downloadUrl => text().nullable()();
  TextColumn get remoteFileId => text().nullable()();
  TextColumn get cloudFolderId => text().nullable()();
  TextColumn get metadataPath => text().nullable()();
  DateTimeColumn get lastSyncedAt => dateTime().nullable()();

  @override
  Set<Column> get primaryKey => {clipId, provider, ownerScope, ownerKey};
}
