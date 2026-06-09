// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'collections_dao.dart';

// ignore_for_file: type=lint
mixin _$CollectionsDaoMixin on DatabaseAccessor<AppDatabase> {
  $GroupsTable get groups => attachedDatabase.groups;
  $CollectionsTable get collections => attachedDatabase.collections;
  $ClipsTable get clips => attachedDatabase.clips;
  $SegmentsTable get segments => attachedDatabase.segments;
  $TagsTable get tags => attachedDatabase.tags;
  $ClipTagsTable get clipTags => attachedDatabase.clipTags;
  $RecentClipViewsTable get recentClipViews => attachedDatabase.recentClipViews;
  CollectionsDaoManager get managers => CollectionsDaoManager(this);
}

class CollectionsDaoManager {
  final _$CollectionsDaoMixin _db;
  CollectionsDaoManager(this._db);
  $$GroupsTableTableManager get groups =>
      $$GroupsTableTableManager(_db.attachedDatabase, _db.groups);
  $$CollectionsTableTableManager get collections =>
      $$CollectionsTableTableManager(_db.attachedDatabase, _db.collections);
  $$ClipsTableTableManager get clips =>
      $$ClipsTableTableManager(_db.attachedDatabase, _db.clips);
  $$SegmentsTableTableManager get segments =>
      $$SegmentsTableTableManager(_db.attachedDatabase, _db.segments);
  $$TagsTableTableManager get tags =>
      $$TagsTableTableManager(_db.attachedDatabase, _db.tags);
  $$ClipTagsTableTableManager get clipTags =>
      $$ClipTagsTableTableManager(_db.attachedDatabase, _db.clipTags);
  $$RecentClipViewsTableTableManager get recentClipViews =>
      $$RecentClipViewsTableTableManager(
          _db.attachedDatabase, _db.recentClipViews);
}
