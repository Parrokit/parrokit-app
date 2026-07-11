import 'package:drift/drift.dart';

import 'clips.dart';

class ClipCacheEntries extends Table {
  IntColumn get clipId => integer().references(Clips, #id)();
  TextColumn get provider => text()(); // server/gdrive
  TextColumn get ownerScope => text()(); // app_account/cloud_account
  TextColumn get ownerKey => text()();
  TextColumn get filePath => text()();
  IntColumn get storageBytes => integer().withDefault(const Constant(0))();
  DateTimeColumn get cachedAt => dateTime().nullable()();
  DateTimeColumn get lastAccessedAt => dateTime().nullable()();

  @override
  Set<Column> get primaryKey => {clipId, provider, ownerScope, ownerKey};
}
