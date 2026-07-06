// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'app_database.dart';

// ignore_for_file: type=lint
class $GroupsTable extends Groups with TableInfo<$GroupsTable, Group> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $GroupsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
      'id', aliasedName, false,
      hasAutoIncrement: true,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('PRIMARY KEY AUTOINCREMENT'));
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
      'name', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  @override
  List<GeneratedColumn> get $columns => [id, name];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'groups';
  @override
  VerificationContext validateIntegrity(Insertable<Group> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('name')) {
      context.handle(
          _nameMeta, name.isAcceptableOrUnknown(data['name']!, _nameMeta));
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Group map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Group(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}id'])!,
      name: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}name'])!,
    );
  }

  @override
  $GroupsTable createAlias(String alias) {
    return $GroupsTable(attachedDatabase, alias);
  }
}

class Group extends DataClass implements Insertable<Group> {
  final int id;
  final String name;
  const Group({required this.id, required this.name});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['name'] = Variable<String>(name);
    return map;
  }

  GroupsCompanion toCompanion(bool nullToAbsent) {
    return GroupsCompanion(
      id: Value(id),
      name: Value(name),
    );
  }

  factory Group.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Group(
      id: serializer.fromJson<int>(json['id']),
      name: serializer.fromJson<String>(json['name']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'name': serializer.toJson<String>(name),
    };
  }

  Group copyWith({int? id, String? name}) => Group(
        id: id ?? this.id,
        name: name ?? this.name,
      );
  Group copyWithCompanion(GroupsCompanion data) {
    return Group(
      id: data.id.present ? data.id.value : this.id,
      name: data.name.present ? data.name.value : this.name,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Group(')
          ..write('id: $id, ')
          ..write('name: $name')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, name);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Group && other.id == this.id && other.name == this.name);
}

class GroupsCompanion extends UpdateCompanion<Group> {
  final Value<int> id;
  final Value<String> name;
  const GroupsCompanion({
    this.id = const Value.absent(),
    this.name = const Value.absent(),
  });
  GroupsCompanion.insert({
    this.id = const Value.absent(),
    required String name,
  }) : name = Value(name);
  static Insertable<Group> custom({
    Expression<int>? id,
    Expression<String>? name,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (name != null) 'name': name,
    });
  }

  GroupsCompanion copyWith({Value<int>? id, Value<String>? name}) {
    return GroupsCompanion(
      id: id ?? this.id,
      name: name ?? this.name,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('GroupsCompanion(')
          ..write('id: $id, ')
          ..write('name: $name')
          ..write(')'))
        .toString();
  }
}

class $CollectionsTable extends Collections
    with TableInfo<$CollectionsTable, Collection> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $CollectionsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
      'id', aliasedName, false,
      hasAutoIncrement: true,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('PRIMARY KEY AUTOINCREMENT'));
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
      'name', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _remoteIdMeta =
      const VerificationMeta('remoteId');
  @override
  late final GeneratedColumn<String> remoteId = GeneratedColumn<String>(
      'remote_id', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _syncStatusMeta =
      const VerificationMeta('syncStatus');
  @override
  late final GeneratedColumn<String> syncStatus = GeneratedColumn<String>(
      'sync_status', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: false,
      defaultValue: const Constant('pending'));
  static const VerificationMeta _lastSyncedAtMeta =
      const VerificationMeta('lastSyncedAt');
  @override
  late final GeneratedColumn<DateTime> lastSyncedAt = GeneratedColumn<DateTime>(
      'last_synced_at', aliasedName, true,
      type: DriftSqlType.dateTime, requiredDuringInsert: false);
  @override
  List<GeneratedColumn> get $columns =>
      [id, name, remoteId, syncStatus, lastSyncedAt];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'collections';
  @override
  VerificationContext validateIntegrity(Insertable<Collection> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('name')) {
      context.handle(
          _nameMeta, name.isAcceptableOrUnknown(data['name']!, _nameMeta));
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('remote_id')) {
      context.handle(_remoteIdMeta,
          remoteId.isAcceptableOrUnknown(data['remote_id']!, _remoteIdMeta));
    }
    if (data.containsKey('sync_status')) {
      context.handle(
          _syncStatusMeta,
          syncStatus.isAcceptableOrUnknown(
              data['sync_status']!, _syncStatusMeta));
    }
    if (data.containsKey('last_synced_at')) {
      context.handle(
          _lastSyncedAtMeta,
          lastSyncedAt.isAcceptableOrUnknown(
              data['last_synced_at']!, _lastSyncedAtMeta));
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Collection map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Collection(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}id'])!,
      name: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}name'])!,
      remoteId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}remote_id']),
      syncStatus: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}sync_status'])!,
      lastSyncedAt: attachedDatabase.typeMapping.read(
          DriftSqlType.dateTime, data['${effectivePrefix}last_synced_at']),
    );
  }

  @override
  $CollectionsTable createAlias(String alias) {
    return $CollectionsTable(attachedDatabase, alias);
  }
}

class Collection extends DataClass implements Insertable<Collection> {
  final int id;
  final String name;
  final String? remoteId;
  final String syncStatus;
  final DateTime? lastSyncedAt;
  const Collection(
      {required this.id,
      required this.name,
      this.remoteId,
      required this.syncStatus,
      this.lastSyncedAt});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['name'] = Variable<String>(name);
    if (!nullToAbsent || remoteId != null) {
      map['remote_id'] = Variable<String>(remoteId);
    }
    map['sync_status'] = Variable<String>(syncStatus);
    if (!nullToAbsent || lastSyncedAt != null) {
      map['last_synced_at'] = Variable<DateTime>(lastSyncedAt);
    }
    return map;
  }

  CollectionsCompanion toCompanion(bool nullToAbsent) {
    return CollectionsCompanion(
      id: Value(id),
      name: Value(name),
      remoteId: remoteId == null && nullToAbsent
          ? const Value.absent()
          : Value(remoteId),
      syncStatus: Value(syncStatus),
      lastSyncedAt: lastSyncedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(lastSyncedAt),
    );
  }

  factory Collection.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Collection(
      id: serializer.fromJson<int>(json['id']),
      name: serializer.fromJson<String>(json['name']),
      remoteId: serializer.fromJson<String?>(json['remoteId']),
      syncStatus: serializer.fromJson<String>(json['syncStatus']),
      lastSyncedAt: serializer.fromJson<DateTime?>(json['lastSyncedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'name': serializer.toJson<String>(name),
      'remoteId': serializer.toJson<String?>(remoteId),
      'syncStatus': serializer.toJson<String>(syncStatus),
      'lastSyncedAt': serializer.toJson<DateTime?>(lastSyncedAt),
    };
  }

  Collection copyWith(
          {int? id,
          String? name,
          Value<String?> remoteId = const Value.absent(),
          String? syncStatus,
          Value<DateTime?> lastSyncedAt = const Value.absent()}) =>
      Collection(
        id: id ?? this.id,
        name: name ?? this.name,
        remoteId: remoteId.present ? remoteId.value : this.remoteId,
        syncStatus: syncStatus ?? this.syncStatus,
        lastSyncedAt:
            lastSyncedAt.present ? lastSyncedAt.value : this.lastSyncedAt,
      );
  Collection copyWithCompanion(CollectionsCompanion data) {
    return Collection(
      id: data.id.present ? data.id.value : this.id,
      name: data.name.present ? data.name.value : this.name,
      remoteId: data.remoteId.present ? data.remoteId.value : this.remoteId,
      syncStatus:
          data.syncStatus.present ? data.syncStatus.value : this.syncStatus,
      lastSyncedAt: data.lastSyncedAt.present
          ? data.lastSyncedAt.value
          : this.lastSyncedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Collection(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('remoteId: $remoteId, ')
          ..write('syncStatus: $syncStatus, ')
          ..write('lastSyncedAt: $lastSyncedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, name, remoteId, syncStatus, lastSyncedAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Collection &&
          other.id == this.id &&
          other.name == this.name &&
          other.remoteId == this.remoteId &&
          other.syncStatus == this.syncStatus &&
          other.lastSyncedAt == this.lastSyncedAt);
}

class CollectionsCompanion extends UpdateCompanion<Collection> {
  final Value<int> id;
  final Value<String> name;
  final Value<String?> remoteId;
  final Value<String> syncStatus;
  final Value<DateTime?> lastSyncedAt;
  const CollectionsCompanion({
    this.id = const Value.absent(),
    this.name = const Value.absent(),
    this.remoteId = const Value.absent(),
    this.syncStatus = const Value.absent(),
    this.lastSyncedAt = const Value.absent(),
  });
  CollectionsCompanion.insert({
    this.id = const Value.absent(),
    required String name,
    this.remoteId = const Value.absent(),
    this.syncStatus = const Value.absent(),
    this.lastSyncedAt = const Value.absent(),
  }) : name = Value(name);
  static Insertable<Collection> custom({
    Expression<int>? id,
    Expression<String>? name,
    Expression<String>? remoteId,
    Expression<String>? syncStatus,
    Expression<DateTime>? lastSyncedAt,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (name != null) 'name': name,
      if (remoteId != null) 'remote_id': remoteId,
      if (syncStatus != null) 'sync_status': syncStatus,
      if (lastSyncedAt != null) 'last_synced_at': lastSyncedAt,
    });
  }

  CollectionsCompanion copyWith(
      {Value<int>? id,
      Value<String>? name,
      Value<String?>? remoteId,
      Value<String>? syncStatus,
      Value<DateTime?>? lastSyncedAt}) {
    return CollectionsCompanion(
      id: id ?? this.id,
      name: name ?? this.name,
      remoteId: remoteId ?? this.remoteId,
      syncStatus: syncStatus ?? this.syncStatus,
      lastSyncedAt: lastSyncedAt ?? this.lastSyncedAt,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (remoteId.present) {
      map['remote_id'] = Variable<String>(remoteId.value);
    }
    if (syncStatus.present) {
      map['sync_status'] = Variable<String>(syncStatus.value);
    }
    if (lastSyncedAt.present) {
      map['last_synced_at'] = Variable<DateTime>(lastSyncedAt.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('CollectionsCompanion(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('remoteId: $remoteId, ')
          ..write('syncStatus: $syncStatus, ')
          ..write('lastSyncedAt: $lastSyncedAt')
          ..write(')'))
        .toString();
  }
}

class $ClipsTable extends Clips with TableInfo<$ClipsTable, Clip> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $ClipsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
      'id', aliasedName, false,
      hasAutoIncrement: true,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('PRIMARY KEY AUTOINCREMENT'));
  static const VerificationMeta _collectionIdMeta =
      const VerificationMeta('collectionId');
  @override
  late final GeneratedColumn<int> collectionId = GeneratedColumn<int>(
      'collection_id', aliasedName, true,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('REFERENCES collections (id)'));
  static const VerificationMeta _titleMeta = const VerificationMeta('title');
  @override
  late final GeneratedColumn<String> title = GeneratedColumn<String>(
      'title', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _filePathMeta =
      const VerificationMeta('filePath');
  @override
  late final GeneratedColumn<String> filePath = GeneratedColumn<String>(
      'file_path', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _remoteIdMeta =
      const VerificationMeta('remoteId');
  @override
  late final GeneratedColumn<String> remoteId = GeneratedColumn<String>(
      'remote_id', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _storageModeMeta =
      const VerificationMeta('storageMode');
  @override
  late final GeneratedColumn<String> storageMode = GeneratedColumn<String>(
      'storage_mode', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: false,
      defaultValue: const Constant('local'));
  static const VerificationMeta _storageBytesMeta =
      const VerificationMeta('storageBytes');
  @override
  late final GeneratedColumn<int> storageBytes = GeneratedColumn<int>(
      'storage_bytes', aliasedName, false,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultValue: const Constant(0));
  static const VerificationMeta _durationMsMeta =
      const VerificationMeta('durationMs');
  @override
  late final GeneratedColumn<int> durationMs = GeneratedColumn<int>(
      'duration_ms', aliasedName, false,
      type: DriftSqlType.int, requiredDuringInsert: true);
  static const VerificationMeta _syncStatusMeta =
      const VerificationMeta('syncStatus');
  @override
  late final GeneratedColumn<String> syncStatus = GeneratedColumn<String>(
      'sync_status', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: false,
      defaultValue: const Constant('pending'));
  static const VerificationMeta _lastSyncedAtMeta =
      const VerificationMeta('lastSyncedAt');
  @override
  late final GeneratedColumn<DateTime> lastSyncedAt = GeneratedColumn<DateTime>(
      'last_synced_at', aliasedName, true,
      type: DriftSqlType.dateTime, requiredDuringInsert: false);
  @override
  List<GeneratedColumn> get $columns => [
        id,
        collectionId,
        title,
        filePath,
        remoteId,
        storageMode,
        storageBytes,
        durationMs,
        syncStatus,
        lastSyncedAt
      ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'clips';
  @override
  VerificationContext validateIntegrity(Insertable<Clip> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('collection_id')) {
      context.handle(
          _collectionIdMeta,
          collectionId.isAcceptableOrUnknown(
              data['collection_id']!, _collectionIdMeta));
    }
    if (data.containsKey('title')) {
      context.handle(
          _titleMeta, title.isAcceptableOrUnknown(data['title']!, _titleMeta));
    } else if (isInserting) {
      context.missing(_titleMeta);
    }
    if (data.containsKey('file_path')) {
      context.handle(_filePathMeta,
          filePath.isAcceptableOrUnknown(data['file_path']!, _filePathMeta));
    } else if (isInserting) {
      context.missing(_filePathMeta);
    }
    if (data.containsKey('remote_id')) {
      context.handle(_remoteIdMeta,
          remoteId.isAcceptableOrUnknown(data['remote_id']!, _remoteIdMeta));
    }
    if (data.containsKey('storage_mode')) {
      context.handle(
          _storageModeMeta,
          storageMode.isAcceptableOrUnknown(
              data['storage_mode']!, _storageModeMeta));
    }
    if (data.containsKey('storage_bytes')) {
      context.handle(
          _storageBytesMeta,
          storageBytes.isAcceptableOrUnknown(
              data['storage_bytes']!, _storageBytesMeta));
    }
    if (data.containsKey('duration_ms')) {
      context.handle(
          _durationMsMeta,
          durationMs.isAcceptableOrUnknown(
              data['duration_ms']!, _durationMsMeta));
    } else if (isInserting) {
      context.missing(_durationMsMeta);
    }
    if (data.containsKey('sync_status')) {
      context.handle(
          _syncStatusMeta,
          syncStatus.isAcceptableOrUnknown(
              data['sync_status']!, _syncStatusMeta));
    }
    if (data.containsKey('last_synced_at')) {
      context.handle(
          _lastSyncedAtMeta,
          lastSyncedAt.isAcceptableOrUnknown(
              data['last_synced_at']!, _lastSyncedAtMeta));
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Clip map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Clip(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}id'])!,
      collectionId: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}collection_id']),
      title: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}title'])!,
      filePath: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}file_path'])!,
      remoteId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}remote_id']),
      storageMode: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}storage_mode'])!,
      storageBytes: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}storage_bytes'])!,
      durationMs: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}duration_ms'])!,
      syncStatus: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}sync_status'])!,
      lastSyncedAt: attachedDatabase.typeMapping.read(
          DriftSqlType.dateTime, data['${effectivePrefix}last_synced_at']),
    );
  }

  @override
  $ClipsTable createAlias(String alias) {
    return $ClipsTable(attachedDatabase, alias);
  }
}

class Clip extends DataClass implements Insertable<Clip> {
  final int id;
  final int? collectionId;
  final String title;
  final String filePath;
  final String? remoteId;
  final String storageMode;
  final int storageBytes;
  final int durationMs;
  final String syncStatus;
  final DateTime? lastSyncedAt;
  const Clip(
      {required this.id,
      this.collectionId,
      required this.title,
      required this.filePath,
      this.remoteId,
      required this.storageMode,
      required this.storageBytes,
      required this.durationMs,
      required this.syncStatus,
      this.lastSyncedAt});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    if (!nullToAbsent || collectionId != null) {
      map['collection_id'] = Variable<int>(collectionId);
    }
    map['title'] = Variable<String>(title);
    map['file_path'] = Variable<String>(filePath);
    if (!nullToAbsent || remoteId != null) {
      map['remote_id'] = Variable<String>(remoteId);
    }
    map['storage_mode'] = Variable<String>(storageMode);
    map['storage_bytes'] = Variable<int>(storageBytes);
    map['duration_ms'] = Variable<int>(durationMs);
    map['sync_status'] = Variable<String>(syncStatus);
    if (!nullToAbsent || lastSyncedAt != null) {
      map['last_synced_at'] = Variable<DateTime>(lastSyncedAt);
    }
    return map;
  }

  ClipsCompanion toCompanion(bool nullToAbsent) {
    return ClipsCompanion(
      id: Value(id),
      collectionId: collectionId == null && nullToAbsent
          ? const Value.absent()
          : Value(collectionId),
      title: Value(title),
      filePath: Value(filePath),
      remoteId: remoteId == null && nullToAbsent
          ? const Value.absent()
          : Value(remoteId),
      storageMode: Value(storageMode),
      storageBytes: Value(storageBytes),
      durationMs: Value(durationMs),
      syncStatus: Value(syncStatus),
      lastSyncedAt: lastSyncedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(lastSyncedAt),
    );
  }

  factory Clip.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Clip(
      id: serializer.fromJson<int>(json['id']),
      collectionId: serializer.fromJson<int?>(json['collectionId']),
      title: serializer.fromJson<String>(json['title']),
      filePath: serializer.fromJson<String>(json['filePath']),
      remoteId: serializer.fromJson<String?>(json['remoteId']),
      storageMode: serializer.fromJson<String>(json['storageMode']),
      storageBytes: serializer.fromJson<int>(json['storageBytes']),
      durationMs: serializer.fromJson<int>(json['durationMs']),
      syncStatus: serializer.fromJson<String>(json['syncStatus']),
      lastSyncedAt: serializer.fromJson<DateTime?>(json['lastSyncedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'collectionId': serializer.toJson<int?>(collectionId),
      'title': serializer.toJson<String>(title),
      'filePath': serializer.toJson<String>(filePath),
      'remoteId': serializer.toJson<String?>(remoteId),
      'storageMode': serializer.toJson<String>(storageMode),
      'storageBytes': serializer.toJson<int>(storageBytes),
      'durationMs': serializer.toJson<int>(durationMs),
      'syncStatus': serializer.toJson<String>(syncStatus),
      'lastSyncedAt': serializer.toJson<DateTime?>(lastSyncedAt),
    };
  }

  Clip copyWith(
          {int? id,
          Value<int?> collectionId = const Value.absent(),
          String? title,
          String? filePath,
          Value<String?> remoteId = const Value.absent(),
          String? storageMode,
          int? storageBytes,
          int? durationMs,
          String? syncStatus,
          Value<DateTime?> lastSyncedAt = const Value.absent()}) =>
      Clip(
        id: id ?? this.id,
        collectionId:
            collectionId.present ? collectionId.value : this.collectionId,
        title: title ?? this.title,
        filePath: filePath ?? this.filePath,
        remoteId: remoteId.present ? remoteId.value : this.remoteId,
        storageMode: storageMode ?? this.storageMode,
        storageBytes: storageBytes ?? this.storageBytes,
        durationMs: durationMs ?? this.durationMs,
        syncStatus: syncStatus ?? this.syncStatus,
        lastSyncedAt:
            lastSyncedAt.present ? lastSyncedAt.value : this.lastSyncedAt,
      );
  Clip copyWithCompanion(ClipsCompanion data) {
    return Clip(
      id: data.id.present ? data.id.value : this.id,
      collectionId: data.collectionId.present
          ? data.collectionId.value
          : this.collectionId,
      title: data.title.present ? data.title.value : this.title,
      filePath: data.filePath.present ? data.filePath.value : this.filePath,
      remoteId: data.remoteId.present ? data.remoteId.value : this.remoteId,
      storageMode:
          data.storageMode.present ? data.storageMode.value : this.storageMode,
      storageBytes: data.storageBytes.present
          ? data.storageBytes.value
          : this.storageBytes,
      durationMs:
          data.durationMs.present ? data.durationMs.value : this.durationMs,
      syncStatus:
          data.syncStatus.present ? data.syncStatus.value : this.syncStatus,
      lastSyncedAt: data.lastSyncedAt.present
          ? data.lastSyncedAt.value
          : this.lastSyncedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Clip(')
          ..write('id: $id, ')
          ..write('collectionId: $collectionId, ')
          ..write('title: $title, ')
          ..write('filePath: $filePath, ')
          ..write('remoteId: $remoteId, ')
          ..write('storageMode: $storageMode, ')
          ..write('storageBytes: $storageBytes, ')
          ..write('durationMs: $durationMs, ')
          ..write('syncStatus: $syncStatus, ')
          ..write('lastSyncedAt: $lastSyncedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, collectionId, title, filePath, remoteId,
      storageMode, storageBytes, durationMs, syncStatus, lastSyncedAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Clip &&
          other.id == this.id &&
          other.collectionId == this.collectionId &&
          other.title == this.title &&
          other.filePath == this.filePath &&
          other.remoteId == this.remoteId &&
          other.storageMode == this.storageMode &&
          other.storageBytes == this.storageBytes &&
          other.durationMs == this.durationMs &&
          other.syncStatus == this.syncStatus &&
          other.lastSyncedAt == this.lastSyncedAt);
}

class ClipsCompanion extends UpdateCompanion<Clip> {
  final Value<int> id;
  final Value<int?> collectionId;
  final Value<String> title;
  final Value<String> filePath;
  final Value<String?> remoteId;
  final Value<String> storageMode;
  final Value<int> storageBytes;
  final Value<int> durationMs;
  final Value<String> syncStatus;
  final Value<DateTime?> lastSyncedAt;
  const ClipsCompanion({
    this.id = const Value.absent(),
    this.collectionId = const Value.absent(),
    this.title = const Value.absent(),
    this.filePath = const Value.absent(),
    this.remoteId = const Value.absent(),
    this.storageMode = const Value.absent(),
    this.storageBytes = const Value.absent(),
    this.durationMs = const Value.absent(),
    this.syncStatus = const Value.absent(),
    this.lastSyncedAt = const Value.absent(),
  });
  ClipsCompanion.insert({
    this.id = const Value.absent(),
    this.collectionId = const Value.absent(),
    required String title,
    required String filePath,
    this.remoteId = const Value.absent(),
    this.storageMode = const Value.absent(),
    this.storageBytes = const Value.absent(),
    required int durationMs,
    this.syncStatus = const Value.absent(),
    this.lastSyncedAt = const Value.absent(),
  })  : title = Value(title),
        filePath = Value(filePath),
        durationMs = Value(durationMs);
  static Insertable<Clip> custom({
    Expression<int>? id,
    Expression<int>? collectionId,
    Expression<String>? title,
    Expression<String>? filePath,
    Expression<String>? remoteId,
    Expression<String>? storageMode,
    Expression<int>? storageBytes,
    Expression<int>? durationMs,
    Expression<String>? syncStatus,
    Expression<DateTime>? lastSyncedAt,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (collectionId != null) 'collection_id': collectionId,
      if (title != null) 'title': title,
      if (filePath != null) 'file_path': filePath,
      if (remoteId != null) 'remote_id': remoteId,
      if (storageMode != null) 'storage_mode': storageMode,
      if (storageBytes != null) 'storage_bytes': storageBytes,
      if (durationMs != null) 'duration_ms': durationMs,
      if (syncStatus != null) 'sync_status': syncStatus,
      if (lastSyncedAt != null) 'last_synced_at': lastSyncedAt,
    });
  }

  ClipsCompanion copyWith(
      {Value<int>? id,
      Value<int?>? collectionId,
      Value<String>? title,
      Value<String>? filePath,
      Value<String?>? remoteId,
      Value<String>? storageMode,
      Value<int>? storageBytes,
      Value<int>? durationMs,
      Value<String>? syncStatus,
      Value<DateTime?>? lastSyncedAt}) {
    return ClipsCompanion(
      id: id ?? this.id,
      collectionId: collectionId ?? this.collectionId,
      title: title ?? this.title,
      filePath: filePath ?? this.filePath,
      remoteId: remoteId ?? this.remoteId,
      storageMode: storageMode ?? this.storageMode,
      storageBytes: storageBytes ?? this.storageBytes,
      durationMs: durationMs ?? this.durationMs,
      syncStatus: syncStatus ?? this.syncStatus,
      lastSyncedAt: lastSyncedAt ?? this.lastSyncedAt,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (collectionId.present) {
      map['collection_id'] = Variable<int>(collectionId.value);
    }
    if (title.present) {
      map['title'] = Variable<String>(title.value);
    }
    if (filePath.present) {
      map['file_path'] = Variable<String>(filePath.value);
    }
    if (remoteId.present) {
      map['remote_id'] = Variable<String>(remoteId.value);
    }
    if (storageMode.present) {
      map['storage_mode'] = Variable<String>(storageMode.value);
    }
    if (storageBytes.present) {
      map['storage_bytes'] = Variable<int>(storageBytes.value);
    }
    if (durationMs.present) {
      map['duration_ms'] = Variable<int>(durationMs.value);
    }
    if (syncStatus.present) {
      map['sync_status'] = Variable<String>(syncStatus.value);
    }
    if (lastSyncedAt.present) {
      map['last_synced_at'] = Variable<DateTime>(lastSyncedAt.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('ClipsCompanion(')
          ..write('id: $id, ')
          ..write('collectionId: $collectionId, ')
          ..write('title: $title, ')
          ..write('filePath: $filePath, ')
          ..write('remoteId: $remoteId, ')
          ..write('storageMode: $storageMode, ')
          ..write('storageBytes: $storageBytes, ')
          ..write('durationMs: $durationMs, ')
          ..write('syncStatus: $syncStatus, ')
          ..write('lastSyncedAt: $lastSyncedAt')
          ..write(')'))
        .toString();
  }
}

class $SegmentsTable extends Segments with TableInfo<$SegmentsTable, Segment> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $SegmentsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
      'id', aliasedName, false,
      hasAutoIncrement: true,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('PRIMARY KEY AUTOINCREMENT'));
  static const VerificationMeta _clipIdMeta = const VerificationMeta('clipId');
  @override
  late final GeneratedColumn<int> clipId = GeneratedColumn<int>(
      'clip_id', aliasedName, false,
      type: DriftSqlType.int,
      requiredDuringInsert: true,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('REFERENCES clips (id)'));
  static const VerificationMeta _startMsMeta =
      const VerificationMeta('startMs');
  @override
  late final GeneratedColumn<int> startMs = GeneratedColumn<int>(
      'start_ms', aliasedName, false,
      type: DriftSqlType.int, requiredDuringInsert: true);
  static const VerificationMeta _endMsMeta = const VerificationMeta('endMs');
  @override
  late final GeneratedColumn<int> endMs = GeneratedColumn<int>(
      'end_ms', aliasedName, false,
      type: DriftSqlType.int, requiredDuringInsert: true);
  static const VerificationMeta _originalMeta =
      const VerificationMeta('original');
  @override
  late final GeneratedColumn<String> original = GeneratedColumn<String>(
      'original', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _pronMeta = const VerificationMeta('pron');
  @override
  late final GeneratedColumn<String> pron = GeneratedColumn<String>(
      'pron', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _transMeta = const VerificationMeta('trans');
  @override
  late final GeneratedColumn<String> trans = GeneratedColumn<String>(
      'trans', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  @override
  List<GeneratedColumn> get $columns =>
      [id, clipId, startMs, endMs, original, pron, trans];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'segments';
  @override
  VerificationContext validateIntegrity(Insertable<Segment> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('clip_id')) {
      context.handle(_clipIdMeta,
          clipId.isAcceptableOrUnknown(data['clip_id']!, _clipIdMeta));
    } else if (isInserting) {
      context.missing(_clipIdMeta);
    }
    if (data.containsKey('start_ms')) {
      context.handle(_startMsMeta,
          startMs.isAcceptableOrUnknown(data['start_ms']!, _startMsMeta));
    } else if (isInserting) {
      context.missing(_startMsMeta);
    }
    if (data.containsKey('end_ms')) {
      context.handle(
          _endMsMeta, endMs.isAcceptableOrUnknown(data['end_ms']!, _endMsMeta));
    } else if (isInserting) {
      context.missing(_endMsMeta);
    }
    if (data.containsKey('original')) {
      context.handle(_originalMeta,
          original.isAcceptableOrUnknown(data['original']!, _originalMeta));
    } else if (isInserting) {
      context.missing(_originalMeta);
    }
    if (data.containsKey('pron')) {
      context.handle(
          _pronMeta, pron.isAcceptableOrUnknown(data['pron']!, _pronMeta));
    } else if (isInserting) {
      context.missing(_pronMeta);
    }
    if (data.containsKey('trans')) {
      context.handle(
          _transMeta, trans.isAcceptableOrUnknown(data['trans']!, _transMeta));
    } else if (isInserting) {
      context.missing(_transMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Segment map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Segment(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}id'])!,
      clipId: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}clip_id'])!,
      startMs: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}start_ms'])!,
      endMs: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}end_ms'])!,
      original: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}original'])!,
      pron: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}pron'])!,
      trans: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}trans'])!,
    );
  }

  @override
  $SegmentsTable createAlias(String alias) {
    return $SegmentsTable(attachedDatabase, alias);
  }
}

class Segment extends DataClass implements Insertable<Segment> {
  final int id;
  final int clipId;
  final int startMs;
  final int endMs;
  final String original;
  final String pron;
  final String trans;
  const Segment(
      {required this.id,
      required this.clipId,
      required this.startMs,
      required this.endMs,
      required this.original,
      required this.pron,
      required this.trans});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['clip_id'] = Variable<int>(clipId);
    map['start_ms'] = Variable<int>(startMs);
    map['end_ms'] = Variable<int>(endMs);
    map['original'] = Variable<String>(original);
    map['pron'] = Variable<String>(pron);
    map['trans'] = Variable<String>(trans);
    return map;
  }

  SegmentsCompanion toCompanion(bool nullToAbsent) {
    return SegmentsCompanion(
      id: Value(id),
      clipId: Value(clipId),
      startMs: Value(startMs),
      endMs: Value(endMs),
      original: Value(original),
      pron: Value(pron),
      trans: Value(trans),
    );
  }

  factory Segment.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Segment(
      id: serializer.fromJson<int>(json['id']),
      clipId: serializer.fromJson<int>(json['clipId']),
      startMs: serializer.fromJson<int>(json['startMs']),
      endMs: serializer.fromJson<int>(json['endMs']),
      original: serializer.fromJson<String>(json['original']),
      pron: serializer.fromJson<String>(json['pron']),
      trans: serializer.fromJson<String>(json['trans']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'clipId': serializer.toJson<int>(clipId),
      'startMs': serializer.toJson<int>(startMs),
      'endMs': serializer.toJson<int>(endMs),
      'original': serializer.toJson<String>(original),
      'pron': serializer.toJson<String>(pron),
      'trans': serializer.toJson<String>(trans),
    };
  }

  Segment copyWith(
          {int? id,
          int? clipId,
          int? startMs,
          int? endMs,
          String? original,
          String? pron,
          String? trans}) =>
      Segment(
        id: id ?? this.id,
        clipId: clipId ?? this.clipId,
        startMs: startMs ?? this.startMs,
        endMs: endMs ?? this.endMs,
        original: original ?? this.original,
        pron: pron ?? this.pron,
        trans: trans ?? this.trans,
      );
  Segment copyWithCompanion(SegmentsCompanion data) {
    return Segment(
      id: data.id.present ? data.id.value : this.id,
      clipId: data.clipId.present ? data.clipId.value : this.clipId,
      startMs: data.startMs.present ? data.startMs.value : this.startMs,
      endMs: data.endMs.present ? data.endMs.value : this.endMs,
      original: data.original.present ? data.original.value : this.original,
      pron: data.pron.present ? data.pron.value : this.pron,
      trans: data.trans.present ? data.trans.value : this.trans,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Segment(')
          ..write('id: $id, ')
          ..write('clipId: $clipId, ')
          ..write('startMs: $startMs, ')
          ..write('endMs: $endMs, ')
          ..write('original: $original, ')
          ..write('pron: $pron, ')
          ..write('trans: $trans')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode =>
      Object.hash(id, clipId, startMs, endMs, original, pron, trans);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Segment &&
          other.id == this.id &&
          other.clipId == this.clipId &&
          other.startMs == this.startMs &&
          other.endMs == this.endMs &&
          other.original == this.original &&
          other.pron == this.pron &&
          other.trans == this.trans);
}

class SegmentsCompanion extends UpdateCompanion<Segment> {
  final Value<int> id;
  final Value<int> clipId;
  final Value<int> startMs;
  final Value<int> endMs;
  final Value<String> original;
  final Value<String> pron;
  final Value<String> trans;
  const SegmentsCompanion({
    this.id = const Value.absent(),
    this.clipId = const Value.absent(),
    this.startMs = const Value.absent(),
    this.endMs = const Value.absent(),
    this.original = const Value.absent(),
    this.pron = const Value.absent(),
    this.trans = const Value.absent(),
  });
  SegmentsCompanion.insert({
    this.id = const Value.absent(),
    required int clipId,
    required int startMs,
    required int endMs,
    required String original,
    required String pron,
    required String trans,
  })  : clipId = Value(clipId),
        startMs = Value(startMs),
        endMs = Value(endMs),
        original = Value(original),
        pron = Value(pron),
        trans = Value(trans);
  static Insertable<Segment> custom({
    Expression<int>? id,
    Expression<int>? clipId,
    Expression<int>? startMs,
    Expression<int>? endMs,
    Expression<String>? original,
    Expression<String>? pron,
    Expression<String>? trans,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (clipId != null) 'clip_id': clipId,
      if (startMs != null) 'start_ms': startMs,
      if (endMs != null) 'end_ms': endMs,
      if (original != null) 'original': original,
      if (pron != null) 'pron': pron,
      if (trans != null) 'trans': trans,
    });
  }

  SegmentsCompanion copyWith(
      {Value<int>? id,
      Value<int>? clipId,
      Value<int>? startMs,
      Value<int>? endMs,
      Value<String>? original,
      Value<String>? pron,
      Value<String>? trans}) {
    return SegmentsCompanion(
      id: id ?? this.id,
      clipId: clipId ?? this.clipId,
      startMs: startMs ?? this.startMs,
      endMs: endMs ?? this.endMs,
      original: original ?? this.original,
      pron: pron ?? this.pron,
      trans: trans ?? this.trans,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (clipId.present) {
      map['clip_id'] = Variable<int>(clipId.value);
    }
    if (startMs.present) {
      map['start_ms'] = Variable<int>(startMs.value);
    }
    if (endMs.present) {
      map['end_ms'] = Variable<int>(endMs.value);
    }
    if (original.present) {
      map['original'] = Variable<String>(original.value);
    }
    if (pron.present) {
      map['pron'] = Variable<String>(pron.value);
    }
    if (trans.present) {
      map['trans'] = Variable<String>(trans.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('SegmentsCompanion(')
          ..write('id: $id, ')
          ..write('clipId: $clipId, ')
          ..write('startMs: $startMs, ')
          ..write('endMs: $endMs, ')
          ..write('original: $original, ')
          ..write('pron: $pron, ')
          ..write('trans: $trans')
          ..write(')'))
        .toString();
  }
}

class $TagsTable extends Tags with TableInfo<$TagsTable, Tag> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $TagsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
      'id', aliasedName, false,
      hasAutoIncrement: true,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('PRIMARY KEY AUTOINCREMENT'));
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
      'name', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  @override
  List<GeneratedColumn> get $columns => [id, name];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'tags';
  @override
  VerificationContext validateIntegrity(Insertable<Tag> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('name')) {
      context.handle(
          _nameMeta, name.isAcceptableOrUnknown(data['name']!, _nameMeta));
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Tag map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Tag(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}id'])!,
      name: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}name'])!,
    );
  }

  @override
  $TagsTable createAlias(String alias) {
    return $TagsTable(attachedDatabase, alias);
  }
}

class Tag extends DataClass implements Insertable<Tag> {
  final int id;
  final String name;
  const Tag({required this.id, required this.name});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['name'] = Variable<String>(name);
    return map;
  }

  TagsCompanion toCompanion(bool nullToAbsent) {
    return TagsCompanion(
      id: Value(id),
      name: Value(name),
    );
  }

  factory Tag.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Tag(
      id: serializer.fromJson<int>(json['id']),
      name: serializer.fromJson<String>(json['name']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'name': serializer.toJson<String>(name),
    };
  }

  Tag copyWith({int? id, String? name}) => Tag(
        id: id ?? this.id,
        name: name ?? this.name,
      );
  Tag copyWithCompanion(TagsCompanion data) {
    return Tag(
      id: data.id.present ? data.id.value : this.id,
      name: data.name.present ? data.name.value : this.name,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Tag(')
          ..write('id: $id, ')
          ..write('name: $name')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, name);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Tag && other.id == this.id && other.name == this.name);
}

class TagsCompanion extends UpdateCompanion<Tag> {
  final Value<int> id;
  final Value<String> name;
  const TagsCompanion({
    this.id = const Value.absent(),
    this.name = const Value.absent(),
  });
  TagsCompanion.insert({
    this.id = const Value.absent(),
    required String name,
  }) : name = Value(name);
  static Insertable<Tag> custom({
    Expression<int>? id,
    Expression<String>? name,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (name != null) 'name': name,
    });
  }

  TagsCompanion copyWith({Value<int>? id, Value<String>? name}) {
    return TagsCompanion(
      id: id ?? this.id,
      name: name ?? this.name,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('TagsCompanion(')
          ..write('id: $id, ')
          ..write('name: $name')
          ..write(')'))
        .toString();
  }
}

class $ClipTagsTable extends ClipTags with TableInfo<$ClipTagsTable, ClipTag> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $ClipTagsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _clipIdMeta = const VerificationMeta('clipId');
  @override
  late final GeneratedColumn<int> clipId = GeneratedColumn<int>(
      'clip_id', aliasedName, false,
      type: DriftSqlType.int,
      requiredDuringInsert: true,
      defaultConstraints: GeneratedColumn.constraintIsAlways(
          'REFERENCES clips (id) ON DELETE CASCADE'));
  static const VerificationMeta _tagIdMeta = const VerificationMeta('tagId');
  @override
  late final GeneratedColumn<int> tagId = GeneratedColumn<int>(
      'tag_id', aliasedName, false,
      type: DriftSqlType.int,
      requiredDuringInsert: true,
      defaultConstraints: GeneratedColumn.constraintIsAlways(
          'REFERENCES tags (id) ON DELETE CASCADE'));
  @override
  List<GeneratedColumn> get $columns => [clipId, tagId];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'clip_tags';
  @override
  VerificationContext validateIntegrity(Insertable<ClipTag> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('clip_id')) {
      context.handle(_clipIdMeta,
          clipId.isAcceptableOrUnknown(data['clip_id']!, _clipIdMeta));
    } else if (isInserting) {
      context.missing(_clipIdMeta);
    }
    if (data.containsKey('tag_id')) {
      context.handle(
          _tagIdMeta, tagId.isAcceptableOrUnknown(data['tag_id']!, _tagIdMeta));
    } else if (isInserting) {
      context.missing(_tagIdMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {clipId, tagId};
  @override
  ClipTag map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return ClipTag(
      clipId: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}clip_id'])!,
      tagId: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}tag_id'])!,
    );
  }

  @override
  $ClipTagsTable createAlias(String alias) {
    return $ClipTagsTable(attachedDatabase, alias);
  }
}

class ClipTag extends DataClass implements Insertable<ClipTag> {
  final int clipId;
  final int tagId;
  const ClipTag({required this.clipId, required this.tagId});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['clip_id'] = Variable<int>(clipId);
    map['tag_id'] = Variable<int>(tagId);
    return map;
  }

  ClipTagsCompanion toCompanion(bool nullToAbsent) {
    return ClipTagsCompanion(
      clipId: Value(clipId),
      tagId: Value(tagId),
    );
  }

  factory ClipTag.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return ClipTag(
      clipId: serializer.fromJson<int>(json['clipId']),
      tagId: serializer.fromJson<int>(json['tagId']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'clipId': serializer.toJson<int>(clipId),
      'tagId': serializer.toJson<int>(tagId),
    };
  }

  ClipTag copyWith({int? clipId, int? tagId}) => ClipTag(
        clipId: clipId ?? this.clipId,
        tagId: tagId ?? this.tagId,
      );
  ClipTag copyWithCompanion(ClipTagsCompanion data) {
    return ClipTag(
      clipId: data.clipId.present ? data.clipId.value : this.clipId,
      tagId: data.tagId.present ? data.tagId.value : this.tagId,
    );
  }

  @override
  String toString() {
    return (StringBuffer('ClipTag(')
          ..write('clipId: $clipId, ')
          ..write('tagId: $tagId')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(clipId, tagId);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is ClipTag &&
          other.clipId == this.clipId &&
          other.tagId == this.tagId);
}

class ClipTagsCompanion extends UpdateCompanion<ClipTag> {
  final Value<int> clipId;
  final Value<int> tagId;
  final Value<int> rowid;
  const ClipTagsCompanion({
    this.clipId = const Value.absent(),
    this.tagId = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  ClipTagsCompanion.insert({
    required int clipId,
    required int tagId,
    this.rowid = const Value.absent(),
  })  : clipId = Value(clipId),
        tagId = Value(tagId);
  static Insertable<ClipTag> custom({
    Expression<int>? clipId,
    Expression<int>? tagId,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (clipId != null) 'clip_id': clipId,
      if (tagId != null) 'tag_id': tagId,
      if (rowid != null) 'rowid': rowid,
    });
  }

  ClipTagsCompanion copyWith(
      {Value<int>? clipId, Value<int>? tagId, Value<int>? rowid}) {
    return ClipTagsCompanion(
      clipId: clipId ?? this.clipId,
      tagId: tagId ?? this.tagId,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (clipId.present) {
      map['clip_id'] = Variable<int>(clipId.value);
    }
    if (tagId.present) {
      map['tag_id'] = Variable<int>(tagId.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('ClipTagsCompanion(')
          ..write('clipId: $clipId, ')
          ..write('tagId: $tagId, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $RecentClipViewsTable extends RecentClipViews
    with TableInfo<$RecentClipViewsTable, RecentClipView> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $RecentClipViewsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _clipIdMeta = const VerificationMeta('clipId');
  @override
  late final GeneratedColumn<int> clipId = GeneratedColumn<int>(
      'clip_id', aliasedName, false,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultConstraints: GeneratedColumn.constraintIsAlways(
          'REFERENCES clips (id) ON DELETE CASCADE'));
  static const VerificationMeta _lastSeqMeta =
      const VerificationMeta('lastSeq');
  @override
  late final GeneratedColumn<int> lastSeq = GeneratedColumn<int>(
      'last_seq', aliasedName, false,
      type: DriftSqlType.int, requiredDuringInsert: true);
  @override
  List<GeneratedColumn> get $columns => [clipId, lastSeq];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'recent_clip_views';
  @override
  VerificationContext validateIntegrity(Insertable<RecentClipView> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('clip_id')) {
      context.handle(_clipIdMeta,
          clipId.isAcceptableOrUnknown(data['clip_id']!, _clipIdMeta));
    }
    if (data.containsKey('last_seq')) {
      context.handle(_lastSeqMeta,
          lastSeq.isAcceptableOrUnknown(data['last_seq']!, _lastSeqMeta));
    } else if (isInserting) {
      context.missing(_lastSeqMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {clipId};
  @override
  RecentClipView map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return RecentClipView(
      clipId: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}clip_id'])!,
      lastSeq: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}last_seq'])!,
    );
  }

  @override
  $RecentClipViewsTable createAlias(String alias) {
    return $RecentClipViewsTable(attachedDatabase, alias);
  }
}

class RecentClipView extends DataClass implements Insertable<RecentClipView> {
  final int clipId;
  final int lastSeq;
  const RecentClipView({required this.clipId, required this.lastSeq});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['clip_id'] = Variable<int>(clipId);
    map['last_seq'] = Variable<int>(lastSeq);
    return map;
  }

  RecentClipViewsCompanion toCompanion(bool nullToAbsent) {
    return RecentClipViewsCompanion(
      clipId: Value(clipId),
      lastSeq: Value(lastSeq),
    );
  }

  factory RecentClipView.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return RecentClipView(
      clipId: serializer.fromJson<int>(json['clipId']),
      lastSeq: serializer.fromJson<int>(json['lastSeq']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'clipId': serializer.toJson<int>(clipId),
      'lastSeq': serializer.toJson<int>(lastSeq),
    };
  }

  RecentClipView copyWith({int? clipId, int? lastSeq}) => RecentClipView(
        clipId: clipId ?? this.clipId,
        lastSeq: lastSeq ?? this.lastSeq,
      );
  RecentClipView copyWithCompanion(RecentClipViewsCompanion data) {
    return RecentClipView(
      clipId: data.clipId.present ? data.clipId.value : this.clipId,
      lastSeq: data.lastSeq.present ? data.lastSeq.value : this.lastSeq,
    );
  }

  @override
  String toString() {
    return (StringBuffer('RecentClipView(')
          ..write('clipId: $clipId, ')
          ..write('lastSeq: $lastSeq')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(clipId, lastSeq);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is RecentClipView &&
          other.clipId == this.clipId &&
          other.lastSeq == this.lastSeq);
}

class RecentClipViewsCompanion extends UpdateCompanion<RecentClipView> {
  final Value<int> clipId;
  final Value<int> lastSeq;
  const RecentClipViewsCompanion({
    this.clipId = const Value.absent(),
    this.lastSeq = const Value.absent(),
  });
  RecentClipViewsCompanion.insert({
    this.clipId = const Value.absent(),
    required int lastSeq,
  }) : lastSeq = Value(lastSeq);
  static Insertable<RecentClipView> custom({
    Expression<int>? clipId,
    Expression<int>? lastSeq,
  }) {
    return RawValuesInsertable({
      if (clipId != null) 'clip_id': clipId,
      if (lastSeq != null) 'last_seq': lastSeq,
    });
  }

  RecentClipViewsCompanion copyWith({Value<int>? clipId, Value<int>? lastSeq}) {
    return RecentClipViewsCompanion(
      clipId: clipId ?? this.clipId,
      lastSeq: lastSeq ?? this.lastSeq,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (clipId.present) {
      map['clip_id'] = Variable<int>(clipId.value);
    }
    if (lastSeq.present) {
      map['last_seq'] = Variable<int>(lastSeq.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('RecentClipViewsCompanion(')
          ..write('clipId: $clipId, ')
          ..write('lastSeq: $lastSeq')
          ..write(')'))
        .toString();
  }
}

class $GroupCollectionsTable extends GroupCollections
    with TableInfo<$GroupCollectionsTable, GroupCollection> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $GroupCollectionsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _groupIdMeta =
      const VerificationMeta('groupId');
  @override
  late final GeneratedColumn<int> groupId = GeneratedColumn<int>(
      'group_id', aliasedName, false,
      type: DriftSqlType.int,
      requiredDuringInsert: true,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('REFERENCES "groups" (id)'));
  static const VerificationMeta _collectionIdMeta =
      const VerificationMeta('collectionId');
  @override
  late final GeneratedColumn<int> collectionId = GeneratedColumn<int>(
      'collection_id', aliasedName, false,
      type: DriftSqlType.int,
      requiredDuringInsert: true,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('REFERENCES collections (id)'));
  @override
  List<GeneratedColumn> get $columns => [groupId, collectionId];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'group_collections';
  @override
  VerificationContext validateIntegrity(Insertable<GroupCollection> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('group_id')) {
      context.handle(_groupIdMeta,
          groupId.isAcceptableOrUnknown(data['group_id']!, _groupIdMeta));
    } else if (isInserting) {
      context.missing(_groupIdMeta);
    }
    if (data.containsKey('collection_id')) {
      context.handle(
          _collectionIdMeta,
          collectionId.isAcceptableOrUnknown(
              data['collection_id']!, _collectionIdMeta));
    } else if (isInserting) {
      context.missing(_collectionIdMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {groupId, collectionId};
  @override
  GroupCollection map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return GroupCollection(
      groupId: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}group_id'])!,
      collectionId: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}collection_id'])!,
    );
  }

  @override
  $GroupCollectionsTable createAlias(String alias) {
    return $GroupCollectionsTable(attachedDatabase, alias);
  }
}

class GroupCollection extends DataClass implements Insertable<GroupCollection> {
  final int groupId;
  final int collectionId;
  const GroupCollection({required this.groupId, required this.collectionId});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['group_id'] = Variable<int>(groupId);
    map['collection_id'] = Variable<int>(collectionId);
    return map;
  }

  GroupCollectionsCompanion toCompanion(bool nullToAbsent) {
    return GroupCollectionsCompanion(
      groupId: Value(groupId),
      collectionId: Value(collectionId),
    );
  }

  factory GroupCollection.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return GroupCollection(
      groupId: serializer.fromJson<int>(json['groupId']),
      collectionId: serializer.fromJson<int>(json['collectionId']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'groupId': serializer.toJson<int>(groupId),
      'collectionId': serializer.toJson<int>(collectionId),
    };
  }

  GroupCollection copyWith({int? groupId, int? collectionId}) =>
      GroupCollection(
        groupId: groupId ?? this.groupId,
        collectionId: collectionId ?? this.collectionId,
      );
  GroupCollection copyWithCompanion(GroupCollectionsCompanion data) {
    return GroupCollection(
      groupId: data.groupId.present ? data.groupId.value : this.groupId,
      collectionId: data.collectionId.present
          ? data.collectionId.value
          : this.collectionId,
    );
  }

  @override
  String toString() {
    return (StringBuffer('GroupCollection(')
          ..write('groupId: $groupId, ')
          ..write('collectionId: $collectionId')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(groupId, collectionId);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is GroupCollection &&
          other.groupId == this.groupId &&
          other.collectionId == this.collectionId);
}

class GroupCollectionsCompanion extends UpdateCompanion<GroupCollection> {
  final Value<int> groupId;
  final Value<int> collectionId;
  final Value<int> rowid;
  const GroupCollectionsCompanion({
    this.groupId = const Value.absent(),
    this.collectionId = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  GroupCollectionsCompanion.insert({
    required int groupId,
    required int collectionId,
    this.rowid = const Value.absent(),
  })  : groupId = Value(groupId),
        collectionId = Value(collectionId);
  static Insertable<GroupCollection> custom({
    Expression<int>? groupId,
    Expression<int>? collectionId,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (groupId != null) 'group_id': groupId,
      if (collectionId != null) 'collection_id': collectionId,
      if (rowid != null) 'rowid': rowid,
    });
  }

  GroupCollectionsCompanion copyWith(
      {Value<int>? groupId, Value<int>? collectionId, Value<int>? rowid}) {
    return GroupCollectionsCompanion(
      groupId: groupId ?? this.groupId,
      collectionId: collectionId ?? this.collectionId,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (groupId.present) {
      map['group_id'] = Variable<int>(groupId.value);
    }
    if (collectionId.present) {
      map['collection_id'] = Variable<int>(collectionId.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('GroupCollectionsCompanion(')
          ..write('groupId: $groupId, ')
          ..write('collectionId: $collectionId, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

abstract class _$AppDatabase extends GeneratedDatabase {
  _$AppDatabase(QueryExecutor e) : super(e);
  $AppDatabaseManager get managers => $AppDatabaseManager(this);
  late final $GroupsTable groups = $GroupsTable(this);
  late final $CollectionsTable collections = $CollectionsTable(this);
  late final $ClipsTable clips = $ClipsTable(this);
  late final $SegmentsTable segments = $SegmentsTable(this);
  late final $TagsTable tags = $TagsTable(this);
  late final $ClipTagsTable clipTags = $ClipTagsTable(this);
  late final $RecentClipViewsTable recentClipViews =
      $RecentClipViewsTable(this);
  late final $GroupCollectionsTable groupCollections =
      $GroupCollectionsTable(this);
  late final GroupsDao groupsDao = GroupsDao(this as AppDatabase);
  late final CollectionsDao collectionsDao =
      CollectionsDao(this as AppDatabase);
  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities => [
        groups,
        collections,
        clips,
        segments,
        tags,
        clipTags,
        recentClipViews,
        groupCollections
      ];
  @override
  StreamQueryUpdateRules get streamUpdateRules => const StreamQueryUpdateRules(
        [
          WritePropagation(
            on: TableUpdateQuery.onTableName('clips',
                limitUpdateKind: UpdateKind.delete),
            result: [
              TableUpdate('clip_tags', kind: UpdateKind.delete),
            ],
          ),
          WritePropagation(
            on: TableUpdateQuery.onTableName('tags',
                limitUpdateKind: UpdateKind.delete),
            result: [
              TableUpdate('clip_tags', kind: UpdateKind.delete),
            ],
          ),
          WritePropagation(
            on: TableUpdateQuery.onTableName('clips',
                limitUpdateKind: UpdateKind.delete),
            result: [
              TableUpdate('recent_clip_views', kind: UpdateKind.delete),
            ],
          ),
        ],
      );
}

typedef $$GroupsTableCreateCompanionBuilder = GroupsCompanion Function({
  Value<int> id,
  required String name,
});
typedef $$GroupsTableUpdateCompanionBuilder = GroupsCompanion Function({
  Value<int> id,
  Value<String> name,
});

final class $$GroupsTableReferences
    extends BaseReferences<_$AppDatabase, $GroupsTable, Group> {
  $$GroupsTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static MultiTypedResultKey<$GroupCollectionsTable, List<GroupCollection>>
      _groupCollectionsRefsTable(_$AppDatabase db) =>
          MultiTypedResultKey.fromTable(db.groupCollections,
              aliasName: $_aliasNameGenerator(
                  db.groups.id, db.groupCollections.groupId));

  $$GroupCollectionsTableProcessedTableManager get groupCollectionsRefs {
    final manager =
        $$GroupCollectionsTableTableManager($_db, $_db.groupCollections)
            .filter((f) => f.groupId.id.sqlEquals($_itemColumn<int>('id')!));

    final cache =
        $_typedResult.readTableOrNull(_groupCollectionsRefsTable($_db));
    return ProcessedTableManager(
        manager.$state.copyWith(prefetchedData: cache));
  }
}

class $$GroupsTableFilterComposer
    extends Composer<_$AppDatabase, $GroupsTable> {
  $$GroupsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get name => $composableBuilder(
      column: $table.name, builder: (column) => ColumnFilters(column));

  Expression<bool> groupCollectionsRefs(
      Expression<bool> Function($$GroupCollectionsTableFilterComposer f) f) {
    final $$GroupCollectionsTableFilterComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.id,
        referencedTable: $db.groupCollections,
        getReferencedColumn: (t) => t.groupId,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$GroupCollectionsTableFilterComposer(
              $db: $db,
              $table: $db.groupCollections,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return f(composer);
  }
}

class $$GroupsTableOrderingComposer
    extends Composer<_$AppDatabase, $GroupsTable> {
  $$GroupsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get name => $composableBuilder(
      column: $table.name, builder: (column) => ColumnOrderings(column));
}

class $$GroupsTableAnnotationComposer
    extends Composer<_$AppDatabase, $GroupsTable> {
  $$GroupsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  Expression<T> groupCollectionsRefs<T extends Object>(
      Expression<T> Function($$GroupCollectionsTableAnnotationComposer a) f) {
    final $$GroupCollectionsTableAnnotationComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.id,
        referencedTable: $db.groupCollections,
        getReferencedColumn: (t) => t.groupId,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$GroupCollectionsTableAnnotationComposer(
              $db: $db,
              $table: $db.groupCollections,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return f(composer);
  }
}

class $$GroupsTableTableManager extends RootTableManager<
    _$AppDatabase,
    $GroupsTable,
    Group,
    $$GroupsTableFilterComposer,
    $$GroupsTableOrderingComposer,
    $$GroupsTableAnnotationComposer,
    $$GroupsTableCreateCompanionBuilder,
    $$GroupsTableUpdateCompanionBuilder,
    (Group, $$GroupsTableReferences),
    Group,
    PrefetchHooks Function({bool groupCollectionsRefs})> {
  $$GroupsTableTableManager(_$AppDatabase db, $GroupsTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$GroupsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$GroupsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$GroupsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<int> id = const Value.absent(),
            Value<String> name = const Value.absent(),
          }) =>
              GroupsCompanion(
            id: id,
            name: name,
          ),
          createCompanionCallback: ({
            Value<int> id = const Value.absent(),
            required String name,
          }) =>
              GroupsCompanion.insert(
            id: id,
            name: name,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) =>
                  (e.readTable(table), $$GroupsTableReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: ({groupCollectionsRefs = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [
                if (groupCollectionsRefs) db.groupCollections
              ],
              addJoins: null,
              getPrefetchedDataCallback: (items) async {
                return [
                  if (groupCollectionsRefs)
                    await $_getPrefetchedData<Group, $GroupsTable,
                            GroupCollection>(
                        currentTable: table,
                        referencedTable: $$GroupsTableReferences
                            ._groupCollectionsRefsTable(db),
                        managerFromTypedResult: (p0) =>
                            $$GroupsTableReferences(db, table, p0)
                                .groupCollectionsRefs,
                        referencedItemsForCurrentItem: (item,
                                referencedItems) =>
                            referencedItems.where((e) => e.groupId == item.id),
                        typedResults: items)
                ];
              },
            );
          },
        ));
}

typedef $$GroupsTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $GroupsTable,
    Group,
    $$GroupsTableFilterComposer,
    $$GroupsTableOrderingComposer,
    $$GroupsTableAnnotationComposer,
    $$GroupsTableCreateCompanionBuilder,
    $$GroupsTableUpdateCompanionBuilder,
    (Group, $$GroupsTableReferences),
    Group,
    PrefetchHooks Function({bool groupCollectionsRefs})>;
typedef $$CollectionsTableCreateCompanionBuilder = CollectionsCompanion
    Function({
  Value<int> id,
  required String name,
  Value<String?> remoteId,
  Value<String> syncStatus,
  Value<DateTime?> lastSyncedAt,
});
typedef $$CollectionsTableUpdateCompanionBuilder = CollectionsCompanion
    Function({
  Value<int> id,
  Value<String> name,
  Value<String?> remoteId,
  Value<String> syncStatus,
  Value<DateTime?> lastSyncedAt,
});

final class $$CollectionsTableReferences
    extends BaseReferences<_$AppDatabase, $CollectionsTable, Collection> {
  $$CollectionsTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static MultiTypedResultKey<$ClipsTable, List<Clip>> _clipsRefsTable(
          _$AppDatabase db) =>
      MultiTypedResultKey.fromTable(db.clips,
          aliasName:
              $_aliasNameGenerator(db.collections.id, db.clips.collectionId));

  $$ClipsTableProcessedTableManager get clipsRefs {
    final manager = $$ClipsTableTableManager($_db, $_db.clips)
        .filter((f) => f.collectionId.id.sqlEquals($_itemColumn<int>('id')!));

    final cache = $_typedResult.readTableOrNull(_clipsRefsTable($_db));
    return ProcessedTableManager(
        manager.$state.copyWith(prefetchedData: cache));
  }

  static MultiTypedResultKey<$GroupCollectionsTable, List<GroupCollection>>
      _groupCollectionsRefsTable(_$AppDatabase db) =>
          MultiTypedResultKey.fromTable(db.groupCollections,
              aliasName: $_aliasNameGenerator(
                  db.collections.id, db.groupCollections.collectionId));

  $$GroupCollectionsTableProcessedTableManager get groupCollectionsRefs {
    final manager = $$GroupCollectionsTableTableManager(
            $_db, $_db.groupCollections)
        .filter((f) => f.collectionId.id.sqlEquals($_itemColumn<int>('id')!));

    final cache =
        $_typedResult.readTableOrNull(_groupCollectionsRefsTable($_db));
    return ProcessedTableManager(
        manager.$state.copyWith(prefetchedData: cache));
  }
}

class $$CollectionsTableFilterComposer
    extends Composer<_$AppDatabase, $CollectionsTable> {
  $$CollectionsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get name => $composableBuilder(
      column: $table.name, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get remoteId => $composableBuilder(
      column: $table.remoteId, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get syncStatus => $composableBuilder(
      column: $table.syncStatus, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get lastSyncedAt => $composableBuilder(
      column: $table.lastSyncedAt, builder: (column) => ColumnFilters(column));

  Expression<bool> clipsRefs(
      Expression<bool> Function($$ClipsTableFilterComposer f) f) {
    final $$ClipsTableFilterComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.id,
        referencedTable: $db.clips,
        getReferencedColumn: (t) => t.collectionId,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$ClipsTableFilterComposer(
              $db: $db,
              $table: $db.clips,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return f(composer);
  }

  Expression<bool> groupCollectionsRefs(
      Expression<bool> Function($$GroupCollectionsTableFilterComposer f) f) {
    final $$GroupCollectionsTableFilterComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.id,
        referencedTable: $db.groupCollections,
        getReferencedColumn: (t) => t.collectionId,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$GroupCollectionsTableFilterComposer(
              $db: $db,
              $table: $db.groupCollections,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return f(composer);
  }
}

class $$CollectionsTableOrderingComposer
    extends Composer<_$AppDatabase, $CollectionsTable> {
  $$CollectionsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get name => $composableBuilder(
      column: $table.name, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get remoteId => $composableBuilder(
      column: $table.remoteId, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get syncStatus => $composableBuilder(
      column: $table.syncStatus, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get lastSyncedAt => $composableBuilder(
      column: $table.lastSyncedAt,
      builder: (column) => ColumnOrderings(column));
}

class $$CollectionsTableAnnotationComposer
    extends Composer<_$AppDatabase, $CollectionsTable> {
  $$CollectionsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumn<String> get remoteId =>
      $composableBuilder(column: $table.remoteId, builder: (column) => column);

  GeneratedColumn<String> get syncStatus => $composableBuilder(
      column: $table.syncStatus, builder: (column) => column);

  GeneratedColumn<DateTime> get lastSyncedAt => $composableBuilder(
      column: $table.lastSyncedAt, builder: (column) => column);

  Expression<T> clipsRefs<T extends Object>(
      Expression<T> Function($$ClipsTableAnnotationComposer a) f) {
    final $$ClipsTableAnnotationComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.id,
        referencedTable: $db.clips,
        getReferencedColumn: (t) => t.collectionId,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$ClipsTableAnnotationComposer(
              $db: $db,
              $table: $db.clips,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return f(composer);
  }

  Expression<T> groupCollectionsRefs<T extends Object>(
      Expression<T> Function($$GroupCollectionsTableAnnotationComposer a) f) {
    final $$GroupCollectionsTableAnnotationComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.id,
        referencedTable: $db.groupCollections,
        getReferencedColumn: (t) => t.collectionId,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$GroupCollectionsTableAnnotationComposer(
              $db: $db,
              $table: $db.groupCollections,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return f(composer);
  }
}

class $$CollectionsTableTableManager extends RootTableManager<
    _$AppDatabase,
    $CollectionsTable,
    Collection,
    $$CollectionsTableFilterComposer,
    $$CollectionsTableOrderingComposer,
    $$CollectionsTableAnnotationComposer,
    $$CollectionsTableCreateCompanionBuilder,
    $$CollectionsTableUpdateCompanionBuilder,
    (Collection, $$CollectionsTableReferences),
    Collection,
    PrefetchHooks Function({bool clipsRefs, bool groupCollectionsRefs})> {
  $$CollectionsTableTableManager(_$AppDatabase db, $CollectionsTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$CollectionsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$CollectionsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$CollectionsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<int> id = const Value.absent(),
            Value<String> name = const Value.absent(),
            Value<String?> remoteId = const Value.absent(),
            Value<String> syncStatus = const Value.absent(),
            Value<DateTime?> lastSyncedAt = const Value.absent(),
          }) =>
              CollectionsCompanion(
            id: id,
            name: name,
            remoteId: remoteId,
            syncStatus: syncStatus,
            lastSyncedAt: lastSyncedAt,
          ),
          createCompanionCallback: ({
            Value<int> id = const Value.absent(),
            required String name,
            Value<String?> remoteId = const Value.absent(),
            Value<String> syncStatus = const Value.absent(),
            Value<DateTime?> lastSyncedAt = const Value.absent(),
          }) =>
              CollectionsCompanion.insert(
            id: id,
            name: name,
            remoteId: remoteId,
            syncStatus: syncStatus,
            lastSyncedAt: lastSyncedAt,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (
                    e.readTable(table),
                    $$CollectionsTableReferences(db, table, e)
                  ))
              .toList(),
          prefetchHooksCallback: (
              {clipsRefs = false, groupCollectionsRefs = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [
                if (clipsRefs) db.clips,
                if (groupCollectionsRefs) db.groupCollections
              ],
              addJoins: null,
              getPrefetchedDataCallback: (items) async {
                return [
                  if (clipsRefs)
                    await $_getPrefetchedData<Collection, $CollectionsTable,
                            Clip>(
                        currentTable: table,
                        referencedTable:
                            $$CollectionsTableReferences._clipsRefsTable(db),
                        managerFromTypedResult: (p0) =>
                            $$CollectionsTableReferences(db, table, p0)
                                .clipsRefs,
                        referencedItemsForCurrentItem:
                            (item, referencedItems) => referencedItems
                                .where((e) => e.collectionId == item.id),
                        typedResults: items),
                  if (groupCollectionsRefs)
                    await $_getPrefetchedData<Collection, $CollectionsTable,
                            GroupCollection>(
                        currentTable: table,
                        referencedTable: $$CollectionsTableReferences
                            ._groupCollectionsRefsTable(db),
                        managerFromTypedResult: (p0) =>
                            $$CollectionsTableReferences(db, table, p0)
                                .groupCollectionsRefs,
                        referencedItemsForCurrentItem:
                            (item, referencedItems) => referencedItems
                                .where((e) => e.collectionId == item.id),
                        typedResults: items)
                ];
              },
            );
          },
        ));
}

typedef $$CollectionsTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $CollectionsTable,
    Collection,
    $$CollectionsTableFilterComposer,
    $$CollectionsTableOrderingComposer,
    $$CollectionsTableAnnotationComposer,
    $$CollectionsTableCreateCompanionBuilder,
    $$CollectionsTableUpdateCompanionBuilder,
    (Collection, $$CollectionsTableReferences),
    Collection,
    PrefetchHooks Function({bool clipsRefs, bool groupCollectionsRefs})>;
typedef $$ClipsTableCreateCompanionBuilder = ClipsCompanion Function({
  Value<int> id,
  Value<int?> collectionId,
  required String title,
  required String filePath,
  Value<String?> remoteId,
  Value<String> storageMode,
  Value<int> storageBytes,
  required int durationMs,
  Value<String> syncStatus,
  Value<DateTime?> lastSyncedAt,
});
typedef $$ClipsTableUpdateCompanionBuilder = ClipsCompanion Function({
  Value<int> id,
  Value<int?> collectionId,
  Value<String> title,
  Value<String> filePath,
  Value<String?> remoteId,
  Value<String> storageMode,
  Value<int> storageBytes,
  Value<int> durationMs,
  Value<String> syncStatus,
  Value<DateTime?> lastSyncedAt,
});

final class $$ClipsTableReferences
    extends BaseReferences<_$AppDatabase, $ClipsTable, Clip> {
  $$ClipsTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static $CollectionsTable _collectionIdTable(_$AppDatabase db) =>
      db.collections.createAlias(
          $_aliasNameGenerator(db.clips.collectionId, db.collections.id));

  $$CollectionsTableProcessedTableManager? get collectionId {
    final $_column = $_itemColumn<int>('collection_id');
    if ($_column == null) return null;
    final manager = $$CollectionsTableTableManager($_db, $_db.collections)
        .filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_collectionIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
        manager.$state.copyWith(prefetchedData: [item]));
  }

  static MultiTypedResultKey<$SegmentsTable, List<Segment>> _segmentsRefsTable(
          _$AppDatabase db) =>
      MultiTypedResultKey.fromTable(db.segments,
          aliasName: $_aliasNameGenerator(db.clips.id, db.segments.clipId));

  $$SegmentsTableProcessedTableManager get segmentsRefs {
    final manager = $$SegmentsTableTableManager($_db, $_db.segments)
        .filter((f) => f.clipId.id.sqlEquals($_itemColumn<int>('id')!));

    final cache = $_typedResult.readTableOrNull(_segmentsRefsTable($_db));
    return ProcessedTableManager(
        manager.$state.copyWith(prefetchedData: cache));
  }

  static MultiTypedResultKey<$ClipTagsTable, List<ClipTag>> _clipTagsRefsTable(
          _$AppDatabase db) =>
      MultiTypedResultKey.fromTable(db.clipTags,
          aliasName: $_aliasNameGenerator(db.clips.id, db.clipTags.clipId));

  $$ClipTagsTableProcessedTableManager get clipTagsRefs {
    final manager = $$ClipTagsTableTableManager($_db, $_db.clipTags)
        .filter((f) => f.clipId.id.sqlEquals($_itemColumn<int>('id')!));

    final cache = $_typedResult.readTableOrNull(_clipTagsRefsTable($_db));
    return ProcessedTableManager(
        manager.$state.copyWith(prefetchedData: cache));
  }

  static MultiTypedResultKey<$RecentClipViewsTable, List<RecentClipView>>
      _recentClipViewsRefsTable(_$AppDatabase db) =>
          MultiTypedResultKey.fromTable(db.recentClipViews,
              aliasName:
                  $_aliasNameGenerator(db.clips.id, db.recentClipViews.clipId));

  $$RecentClipViewsTableProcessedTableManager get recentClipViewsRefs {
    final manager =
        $$RecentClipViewsTableTableManager($_db, $_db.recentClipViews)
            .filter((f) => f.clipId.id.sqlEquals($_itemColumn<int>('id')!));

    final cache =
        $_typedResult.readTableOrNull(_recentClipViewsRefsTable($_db));
    return ProcessedTableManager(
        manager.$state.copyWith(prefetchedData: cache));
  }
}

class $$ClipsTableFilterComposer extends Composer<_$AppDatabase, $ClipsTable> {
  $$ClipsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get title => $composableBuilder(
      column: $table.title, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get filePath => $composableBuilder(
      column: $table.filePath, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get remoteId => $composableBuilder(
      column: $table.remoteId, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get storageMode => $composableBuilder(
      column: $table.storageMode, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get storageBytes => $composableBuilder(
      column: $table.storageBytes, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get durationMs => $composableBuilder(
      column: $table.durationMs, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get syncStatus => $composableBuilder(
      column: $table.syncStatus, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get lastSyncedAt => $composableBuilder(
      column: $table.lastSyncedAt, builder: (column) => ColumnFilters(column));

  $$CollectionsTableFilterComposer get collectionId {
    final $$CollectionsTableFilterComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.collectionId,
        referencedTable: $db.collections,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$CollectionsTableFilterComposer(
              $db: $db,
              $table: $db.collections,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }

  Expression<bool> segmentsRefs(
      Expression<bool> Function($$SegmentsTableFilterComposer f) f) {
    final $$SegmentsTableFilterComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.id,
        referencedTable: $db.segments,
        getReferencedColumn: (t) => t.clipId,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$SegmentsTableFilterComposer(
              $db: $db,
              $table: $db.segments,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return f(composer);
  }

  Expression<bool> clipTagsRefs(
      Expression<bool> Function($$ClipTagsTableFilterComposer f) f) {
    final $$ClipTagsTableFilterComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.id,
        referencedTable: $db.clipTags,
        getReferencedColumn: (t) => t.clipId,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$ClipTagsTableFilterComposer(
              $db: $db,
              $table: $db.clipTags,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return f(composer);
  }

  Expression<bool> recentClipViewsRefs(
      Expression<bool> Function($$RecentClipViewsTableFilterComposer f) f) {
    final $$RecentClipViewsTableFilterComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.id,
        referencedTable: $db.recentClipViews,
        getReferencedColumn: (t) => t.clipId,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$RecentClipViewsTableFilterComposer(
              $db: $db,
              $table: $db.recentClipViews,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return f(composer);
  }
}

class $$ClipsTableOrderingComposer
    extends Composer<_$AppDatabase, $ClipsTable> {
  $$ClipsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get title => $composableBuilder(
      column: $table.title, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get filePath => $composableBuilder(
      column: $table.filePath, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get remoteId => $composableBuilder(
      column: $table.remoteId, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get storageMode => $composableBuilder(
      column: $table.storageMode, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get storageBytes => $composableBuilder(
      column: $table.storageBytes,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get durationMs => $composableBuilder(
      column: $table.durationMs, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get syncStatus => $composableBuilder(
      column: $table.syncStatus, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get lastSyncedAt => $composableBuilder(
      column: $table.lastSyncedAt,
      builder: (column) => ColumnOrderings(column));

  $$CollectionsTableOrderingComposer get collectionId {
    final $$CollectionsTableOrderingComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.collectionId,
        referencedTable: $db.collections,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$CollectionsTableOrderingComposer(
              $db: $db,
              $table: $db.collections,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }
}

class $$ClipsTableAnnotationComposer
    extends Composer<_$AppDatabase, $ClipsTable> {
  $$ClipsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get title =>
      $composableBuilder(column: $table.title, builder: (column) => column);

  GeneratedColumn<String> get filePath =>
      $composableBuilder(column: $table.filePath, builder: (column) => column);

  GeneratedColumn<String> get remoteId =>
      $composableBuilder(column: $table.remoteId, builder: (column) => column);

  GeneratedColumn<String> get storageMode => $composableBuilder(
      column: $table.storageMode, builder: (column) => column);

  GeneratedColumn<int> get storageBytes => $composableBuilder(
      column: $table.storageBytes, builder: (column) => column);

  GeneratedColumn<int> get durationMs => $composableBuilder(
      column: $table.durationMs, builder: (column) => column);

  GeneratedColumn<String> get syncStatus => $composableBuilder(
      column: $table.syncStatus, builder: (column) => column);

  GeneratedColumn<DateTime> get lastSyncedAt => $composableBuilder(
      column: $table.lastSyncedAt, builder: (column) => column);

  $$CollectionsTableAnnotationComposer get collectionId {
    final $$CollectionsTableAnnotationComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.collectionId,
        referencedTable: $db.collections,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$CollectionsTableAnnotationComposer(
              $db: $db,
              $table: $db.collections,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }

  Expression<T> segmentsRefs<T extends Object>(
      Expression<T> Function($$SegmentsTableAnnotationComposer a) f) {
    final $$SegmentsTableAnnotationComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.id,
        referencedTable: $db.segments,
        getReferencedColumn: (t) => t.clipId,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$SegmentsTableAnnotationComposer(
              $db: $db,
              $table: $db.segments,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return f(composer);
  }

  Expression<T> clipTagsRefs<T extends Object>(
      Expression<T> Function($$ClipTagsTableAnnotationComposer a) f) {
    final $$ClipTagsTableAnnotationComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.id,
        referencedTable: $db.clipTags,
        getReferencedColumn: (t) => t.clipId,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$ClipTagsTableAnnotationComposer(
              $db: $db,
              $table: $db.clipTags,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return f(composer);
  }

  Expression<T> recentClipViewsRefs<T extends Object>(
      Expression<T> Function($$RecentClipViewsTableAnnotationComposer a) f) {
    final $$RecentClipViewsTableAnnotationComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.id,
        referencedTable: $db.recentClipViews,
        getReferencedColumn: (t) => t.clipId,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$RecentClipViewsTableAnnotationComposer(
              $db: $db,
              $table: $db.recentClipViews,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return f(composer);
  }
}

class $$ClipsTableTableManager extends RootTableManager<
    _$AppDatabase,
    $ClipsTable,
    Clip,
    $$ClipsTableFilterComposer,
    $$ClipsTableOrderingComposer,
    $$ClipsTableAnnotationComposer,
    $$ClipsTableCreateCompanionBuilder,
    $$ClipsTableUpdateCompanionBuilder,
    (Clip, $$ClipsTableReferences),
    Clip,
    PrefetchHooks Function(
        {bool collectionId,
        bool segmentsRefs,
        bool clipTagsRefs,
        bool recentClipViewsRefs})> {
  $$ClipsTableTableManager(_$AppDatabase db, $ClipsTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$ClipsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$ClipsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$ClipsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<int> id = const Value.absent(),
            Value<int?> collectionId = const Value.absent(),
            Value<String> title = const Value.absent(),
            Value<String> filePath = const Value.absent(),
            Value<String?> remoteId = const Value.absent(),
            Value<String> storageMode = const Value.absent(),
            Value<int> storageBytes = const Value.absent(),
            Value<int> durationMs = const Value.absent(),
            Value<String> syncStatus = const Value.absent(),
            Value<DateTime?> lastSyncedAt = const Value.absent(),
          }) =>
              ClipsCompanion(
            id: id,
            collectionId: collectionId,
            title: title,
            filePath: filePath,
            remoteId: remoteId,
            storageMode: storageMode,
            storageBytes: storageBytes,
            durationMs: durationMs,
            syncStatus: syncStatus,
            lastSyncedAt: lastSyncedAt,
          ),
          createCompanionCallback: ({
            Value<int> id = const Value.absent(),
            Value<int?> collectionId = const Value.absent(),
            required String title,
            required String filePath,
            Value<String?> remoteId = const Value.absent(),
            Value<String> storageMode = const Value.absent(),
            Value<int> storageBytes = const Value.absent(),
            required int durationMs,
            Value<String> syncStatus = const Value.absent(),
            Value<DateTime?> lastSyncedAt = const Value.absent(),
          }) =>
              ClipsCompanion.insert(
            id: id,
            collectionId: collectionId,
            title: title,
            filePath: filePath,
            remoteId: remoteId,
            storageMode: storageMode,
            storageBytes: storageBytes,
            durationMs: durationMs,
            syncStatus: syncStatus,
            lastSyncedAt: lastSyncedAt,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) =>
                  (e.readTable(table), $$ClipsTableReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: (
              {collectionId = false,
              segmentsRefs = false,
              clipTagsRefs = false,
              recentClipViewsRefs = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [
                if (segmentsRefs) db.segments,
                if (clipTagsRefs) db.clipTags,
                if (recentClipViewsRefs) db.recentClipViews
              ],
              addJoins: <
                  T extends TableManagerState<
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic>>(state) {
                if (collectionId) {
                  state = state.withJoin(
                    currentTable: table,
                    currentColumn: table.collectionId,
                    referencedTable:
                        $$ClipsTableReferences._collectionIdTable(db),
                    referencedColumn:
                        $$ClipsTableReferences._collectionIdTable(db).id,
                  ) as T;
                }

                return state;
              },
              getPrefetchedDataCallback: (items) async {
                return [
                  if (segmentsRefs)
                    await $_getPrefetchedData<Clip, $ClipsTable, Segment>(
                        currentTable: table,
                        referencedTable:
                            $$ClipsTableReferences._segmentsRefsTable(db),
                        managerFromTypedResult: (p0) =>
                            $$ClipsTableReferences(db, table, p0).segmentsRefs,
                        referencedItemsForCurrentItem: (item,
                                referencedItems) =>
                            referencedItems.where((e) => e.clipId == item.id),
                        typedResults: items),
                  if (clipTagsRefs)
                    await $_getPrefetchedData<Clip, $ClipsTable, ClipTag>(
                        currentTable: table,
                        referencedTable:
                            $$ClipsTableReferences._clipTagsRefsTable(db),
                        managerFromTypedResult: (p0) =>
                            $$ClipsTableReferences(db, table, p0).clipTagsRefs,
                        referencedItemsForCurrentItem: (item,
                                referencedItems) =>
                            referencedItems.where((e) => e.clipId == item.id),
                        typedResults: items),
                  if (recentClipViewsRefs)
                    await $_getPrefetchedData<Clip, $ClipsTable,
                            RecentClipView>(
                        currentTable: table,
                        referencedTable: $$ClipsTableReferences
                            ._recentClipViewsRefsTable(db),
                        managerFromTypedResult: (p0) =>
                            $$ClipsTableReferences(db, table, p0)
                                .recentClipViewsRefs,
                        referencedItemsForCurrentItem: (item,
                                referencedItems) =>
                            referencedItems.where((e) => e.clipId == item.id),
                        typedResults: items)
                ];
              },
            );
          },
        ));
}

typedef $$ClipsTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $ClipsTable,
    Clip,
    $$ClipsTableFilterComposer,
    $$ClipsTableOrderingComposer,
    $$ClipsTableAnnotationComposer,
    $$ClipsTableCreateCompanionBuilder,
    $$ClipsTableUpdateCompanionBuilder,
    (Clip, $$ClipsTableReferences),
    Clip,
    PrefetchHooks Function(
        {bool collectionId,
        bool segmentsRefs,
        bool clipTagsRefs,
        bool recentClipViewsRefs})>;
typedef $$SegmentsTableCreateCompanionBuilder = SegmentsCompanion Function({
  Value<int> id,
  required int clipId,
  required int startMs,
  required int endMs,
  required String original,
  required String pron,
  required String trans,
});
typedef $$SegmentsTableUpdateCompanionBuilder = SegmentsCompanion Function({
  Value<int> id,
  Value<int> clipId,
  Value<int> startMs,
  Value<int> endMs,
  Value<String> original,
  Value<String> pron,
  Value<String> trans,
});

final class $$SegmentsTableReferences
    extends BaseReferences<_$AppDatabase, $SegmentsTable, Segment> {
  $$SegmentsTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static $ClipsTable _clipIdTable(_$AppDatabase db) => db.clips
      .createAlias($_aliasNameGenerator(db.segments.clipId, db.clips.id));

  $$ClipsTableProcessedTableManager get clipId {
    final $_column = $_itemColumn<int>('clip_id')!;

    final manager = $$ClipsTableTableManager($_db, $_db.clips)
        .filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_clipIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
        manager.$state.copyWith(prefetchedData: [item]));
  }
}

class $$SegmentsTableFilterComposer
    extends Composer<_$AppDatabase, $SegmentsTable> {
  $$SegmentsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get startMs => $composableBuilder(
      column: $table.startMs, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get endMs => $composableBuilder(
      column: $table.endMs, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get original => $composableBuilder(
      column: $table.original, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get pron => $composableBuilder(
      column: $table.pron, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get trans => $composableBuilder(
      column: $table.trans, builder: (column) => ColumnFilters(column));

  $$ClipsTableFilterComposer get clipId {
    final $$ClipsTableFilterComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.clipId,
        referencedTable: $db.clips,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$ClipsTableFilterComposer(
              $db: $db,
              $table: $db.clips,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }
}

class $$SegmentsTableOrderingComposer
    extends Composer<_$AppDatabase, $SegmentsTable> {
  $$SegmentsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get startMs => $composableBuilder(
      column: $table.startMs, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get endMs => $composableBuilder(
      column: $table.endMs, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get original => $composableBuilder(
      column: $table.original, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get pron => $composableBuilder(
      column: $table.pron, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get trans => $composableBuilder(
      column: $table.trans, builder: (column) => ColumnOrderings(column));

  $$ClipsTableOrderingComposer get clipId {
    final $$ClipsTableOrderingComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.clipId,
        referencedTable: $db.clips,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$ClipsTableOrderingComposer(
              $db: $db,
              $table: $db.clips,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }
}

class $$SegmentsTableAnnotationComposer
    extends Composer<_$AppDatabase, $SegmentsTable> {
  $$SegmentsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<int> get startMs =>
      $composableBuilder(column: $table.startMs, builder: (column) => column);

  GeneratedColumn<int> get endMs =>
      $composableBuilder(column: $table.endMs, builder: (column) => column);

  GeneratedColumn<String> get original =>
      $composableBuilder(column: $table.original, builder: (column) => column);

  GeneratedColumn<String> get pron =>
      $composableBuilder(column: $table.pron, builder: (column) => column);

  GeneratedColumn<String> get trans =>
      $composableBuilder(column: $table.trans, builder: (column) => column);

  $$ClipsTableAnnotationComposer get clipId {
    final $$ClipsTableAnnotationComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.clipId,
        referencedTable: $db.clips,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$ClipsTableAnnotationComposer(
              $db: $db,
              $table: $db.clips,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }
}

class $$SegmentsTableTableManager extends RootTableManager<
    _$AppDatabase,
    $SegmentsTable,
    Segment,
    $$SegmentsTableFilterComposer,
    $$SegmentsTableOrderingComposer,
    $$SegmentsTableAnnotationComposer,
    $$SegmentsTableCreateCompanionBuilder,
    $$SegmentsTableUpdateCompanionBuilder,
    (Segment, $$SegmentsTableReferences),
    Segment,
    PrefetchHooks Function({bool clipId})> {
  $$SegmentsTableTableManager(_$AppDatabase db, $SegmentsTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$SegmentsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$SegmentsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$SegmentsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<int> id = const Value.absent(),
            Value<int> clipId = const Value.absent(),
            Value<int> startMs = const Value.absent(),
            Value<int> endMs = const Value.absent(),
            Value<String> original = const Value.absent(),
            Value<String> pron = const Value.absent(),
            Value<String> trans = const Value.absent(),
          }) =>
              SegmentsCompanion(
            id: id,
            clipId: clipId,
            startMs: startMs,
            endMs: endMs,
            original: original,
            pron: pron,
            trans: trans,
          ),
          createCompanionCallback: ({
            Value<int> id = const Value.absent(),
            required int clipId,
            required int startMs,
            required int endMs,
            required String original,
            required String pron,
            required String trans,
          }) =>
              SegmentsCompanion.insert(
            id: id,
            clipId: clipId,
            startMs: startMs,
            endMs: endMs,
            original: original,
            pron: pron,
            trans: trans,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) =>
                  (e.readTable(table), $$SegmentsTableReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: ({clipId = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [],
              addJoins: <
                  T extends TableManagerState<
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic>>(state) {
                if (clipId) {
                  state = state.withJoin(
                    currentTable: table,
                    currentColumn: table.clipId,
                    referencedTable: $$SegmentsTableReferences._clipIdTable(db),
                    referencedColumn:
                        $$SegmentsTableReferences._clipIdTable(db).id,
                  ) as T;
                }

                return state;
              },
              getPrefetchedDataCallback: (items) async {
                return [];
              },
            );
          },
        ));
}

typedef $$SegmentsTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $SegmentsTable,
    Segment,
    $$SegmentsTableFilterComposer,
    $$SegmentsTableOrderingComposer,
    $$SegmentsTableAnnotationComposer,
    $$SegmentsTableCreateCompanionBuilder,
    $$SegmentsTableUpdateCompanionBuilder,
    (Segment, $$SegmentsTableReferences),
    Segment,
    PrefetchHooks Function({bool clipId})>;
typedef $$TagsTableCreateCompanionBuilder = TagsCompanion Function({
  Value<int> id,
  required String name,
});
typedef $$TagsTableUpdateCompanionBuilder = TagsCompanion Function({
  Value<int> id,
  Value<String> name,
});

final class $$TagsTableReferences
    extends BaseReferences<_$AppDatabase, $TagsTable, Tag> {
  $$TagsTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static MultiTypedResultKey<$ClipTagsTable, List<ClipTag>> _clipTagsRefsTable(
          _$AppDatabase db) =>
      MultiTypedResultKey.fromTable(db.clipTags,
          aliasName: $_aliasNameGenerator(db.tags.id, db.clipTags.tagId));

  $$ClipTagsTableProcessedTableManager get clipTagsRefs {
    final manager = $$ClipTagsTableTableManager($_db, $_db.clipTags)
        .filter((f) => f.tagId.id.sqlEquals($_itemColumn<int>('id')!));

    final cache = $_typedResult.readTableOrNull(_clipTagsRefsTable($_db));
    return ProcessedTableManager(
        manager.$state.copyWith(prefetchedData: cache));
  }
}

class $$TagsTableFilterComposer extends Composer<_$AppDatabase, $TagsTable> {
  $$TagsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get name => $composableBuilder(
      column: $table.name, builder: (column) => ColumnFilters(column));

  Expression<bool> clipTagsRefs(
      Expression<bool> Function($$ClipTagsTableFilterComposer f) f) {
    final $$ClipTagsTableFilterComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.id,
        referencedTable: $db.clipTags,
        getReferencedColumn: (t) => t.tagId,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$ClipTagsTableFilterComposer(
              $db: $db,
              $table: $db.clipTags,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return f(composer);
  }
}

class $$TagsTableOrderingComposer extends Composer<_$AppDatabase, $TagsTable> {
  $$TagsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get name => $composableBuilder(
      column: $table.name, builder: (column) => ColumnOrderings(column));
}

class $$TagsTableAnnotationComposer
    extends Composer<_$AppDatabase, $TagsTable> {
  $$TagsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  Expression<T> clipTagsRefs<T extends Object>(
      Expression<T> Function($$ClipTagsTableAnnotationComposer a) f) {
    final $$ClipTagsTableAnnotationComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.id,
        referencedTable: $db.clipTags,
        getReferencedColumn: (t) => t.tagId,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$ClipTagsTableAnnotationComposer(
              $db: $db,
              $table: $db.clipTags,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return f(composer);
  }
}

class $$TagsTableTableManager extends RootTableManager<
    _$AppDatabase,
    $TagsTable,
    Tag,
    $$TagsTableFilterComposer,
    $$TagsTableOrderingComposer,
    $$TagsTableAnnotationComposer,
    $$TagsTableCreateCompanionBuilder,
    $$TagsTableUpdateCompanionBuilder,
    (Tag, $$TagsTableReferences),
    Tag,
    PrefetchHooks Function({bool clipTagsRefs})> {
  $$TagsTableTableManager(_$AppDatabase db, $TagsTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$TagsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$TagsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$TagsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<int> id = const Value.absent(),
            Value<String> name = const Value.absent(),
          }) =>
              TagsCompanion(
            id: id,
            name: name,
          ),
          createCompanionCallback: ({
            Value<int> id = const Value.absent(),
            required String name,
          }) =>
              TagsCompanion.insert(
            id: id,
            name: name,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) =>
                  (e.readTable(table), $$TagsTableReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: ({clipTagsRefs = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [if (clipTagsRefs) db.clipTags],
              addJoins: null,
              getPrefetchedDataCallback: (items) async {
                return [
                  if (clipTagsRefs)
                    await $_getPrefetchedData<Tag, $TagsTable, ClipTag>(
                        currentTable: table,
                        referencedTable:
                            $$TagsTableReferences._clipTagsRefsTable(db),
                        managerFromTypedResult: (p0) =>
                            $$TagsTableReferences(db, table, p0).clipTagsRefs,
                        referencedItemsForCurrentItem: (item,
                                referencedItems) =>
                            referencedItems.where((e) => e.tagId == item.id),
                        typedResults: items)
                ];
              },
            );
          },
        ));
}

typedef $$TagsTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $TagsTable,
    Tag,
    $$TagsTableFilterComposer,
    $$TagsTableOrderingComposer,
    $$TagsTableAnnotationComposer,
    $$TagsTableCreateCompanionBuilder,
    $$TagsTableUpdateCompanionBuilder,
    (Tag, $$TagsTableReferences),
    Tag,
    PrefetchHooks Function({bool clipTagsRefs})>;
typedef $$ClipTagsTableCreateCompanionBuilder = ClipTagsCompanion Function({
  required int clipId,
  required int tagId,
  Value<int> rowid,
});
typedef $$ClipTagsTableUpdateCompanionBuilder = ClipTagsCompanion Function({
  Value<int> clipId,
  Value<int> tagId,
  Value<int> rowid,
});

final class $$ClipTagsTableReferences
    extends BaseReferences<_$AppDatabase, $ClipTagsTable, ClipTag> {
  $$ClipTagsTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static $ClipsTable _clipIdTable(_$AppDatabase db) => db.clips
      .createAlias($_aliasNameGenerator(db.clipTags.clipId, db.clips.id));

  $$ClipsTableProcessedTableManager get clipId {
    final $_column = $_itemColumn<int>('clip_id')!;

    final manager = $$ClipsTableTableManager($_db, $_db.clips)
        .filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_clipIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
        manager.$state.copyWith(prefetchedData: [item]));
  }

  static $TagsTable _tagIdTable(_$AppDatabase db) =>
      db.tags.createAlias($_aliasNameGenerator(db.clipTags.tagId, db.tags.id));

  $$TagsTableProcessedTableManager get tagId {
    final $_column = $_itemColumn<int>('tag_id')!;

    final manager = $$TagsTableTableManager($_db, $_db.tags)
        .filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_tagIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
        manager.$state.copyWith(prefetchedData: [item]));
  }
}

class $$ClipTagsTableFilterComposer
    extends Composer<_$AppDatabase, $ClipTagsTable> {
  $$ClipTagsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  $$ClipsTableFilterComposer get clipId {
    final $$ClipsTableFilterComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.clipId,
        referencedTable: $db.clips,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$ClipsTableFilterComposer(
              $db: $db,
              $table: $db.clips,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }

  $$TagsTableFilterComposer get tagId {
    final $$TagsTableFilterComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.tagId,
        referencedTable: $db.tags,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$TagsTableFilterComposer(
              $db: $db,
              $table: $db.tags,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }
}

class $$ClipTagsTableOrderingComposer
    extends Composer<_$AppDatabase, $ClipTagsTable> {
  $$ClipTagsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  $$ClipsTableOrderingComposer get clipId {
    final $$ClipsTableOrderingComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.clipId,
        referencedTable: $db.clips,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$ClipsTableOrderingComposer(
              $db: $db,
              $table: $db.clips,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }

  $$TagsTableOrderingComposer get tagId {
    final $$TagsTableOrderingComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.tagId,
        referencedTable: $db.tags,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$TagsTableOrderingComposer(
              $db: $db,
              $table: $db.tags,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }
}

class $$ClipTagsTableAnnotationComposer
    extends Composer<_$AppDatabase, $ClipTagsTable> {
  $$ClipTagsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  $$ClipsTableAnnotationComposer get clipId {
    final $$ClipsTableAnnotationComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.clipId,
        referencedTable: $db.clips,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$ClipsTableAnnotationComposer(
              $db: $db,
              $table: $db.clips,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }

  $$TagsTableAnnotationComposer get tagId {
    final $$TagsTableAnnotationComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.tagId,
        referencedTable: $db.tags,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$TagsTableAnnotationComposer(
              $db: $db,
              $table: $db.tags,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }
}

class $$ClipTagsTableTableManager extends RootTableManager<
    _$AppDatabase,
    $ClipTagsTable,
    ClipTag,
    $$ClipTagsTableFilterComposer,
    $$ClipTagsTableOrderingComposer,
    $$ClipTagsTableAnnotationComposer,
    $$ClipTagsTableCreateCompanionBuilder,
    $$ClipTagsTableUpdateCompanionBuilder,
    (ClipTag, $$ClipTagsTableReferences),
    ClipTag,
    PrefetchHooks Function({bool clipId, bool tagId})> {
  $$ClipTagsTableTableManager(_$AppDatabase db, $ClipTagsTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$ClipTagsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$ClipTagsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$ClipTagsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<int> clipId = const Value.absent(),
            Value<int> tagId = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              ClipTagsCompanion(
            clipId: clipId,
            tagId: tagId,
            rowid: rowid,
          ),
          createCompanionCallback: ({
            required int clipId,
            required int tagId,
            Value<int> rowid = const Value.absent(),
          }) =>
              ClipTagsCompanion.insert(
            clipId: clipId,
            tagId: tagId,
            rowid: rowid,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) =>
                  (e.readTable(table), $$ClipTagsTableReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: ({clipId = false, tagId = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [],
              addJoins: <
                  T extends TableManagerState<
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic>>(state) {
                if (clipId) {
                  state = state.withJoin(
                    currentTable: table,
                    currentColumn: table.clipId,
                    referencedTable: $$ClipTagsTableReferences._clipIdTable(db),
                    referencedColumn:
                        $$ClipTagsTableReferences._clipIdTable(db).id,
                  ) as T;
                }
                if (tagId) {
                  state = state.withJoin(
                    currentTable: table,
                    currentColumn: table.tagId,
                    referencedTable: $$ClipTagsTableReferences._tagIdTable(db),
                    referencedColumn:
                        $$ClipTagsTableReferences._tagIdTable(db).id,
                  ) as T;
                }

                return state;
              },
              getPrefetchedDataCallback: (items) async {
                return [];
              },
            );
          },
        ));
}

typedef $$ClipTagsTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $ClipTagsTable,
    ClipTag,
    $$ClipTagsTableFilterComposer,
    $$ClipTagsTableOrderingComposer,
    $$ClipTagsTableAnnotationComposer,
    $$ClipTagsTableCreateCompanionBuilder,
    $$ClipTagsTableUpdateCompanionBuilder,
    (ClipTag, $$ClipTagsTableReferences),
    ClipTag,
    PrefetchHooks Function({bool clipId, bool tagId})>;
typedef $$RecentClipViewsTableCreateCompanionBuilder = RecentClipViewsCompanion
    Function({
  Value<int> clipId,
  required int lastSeq,
});
typedef $$RecentClipViewsTableUpdateCompanionBuilder = RecentClipViewsCompanion
    Function({
  Value<int> clipId,
  Value<int> lastSeq,
});

final class $$RecentClipViewsTableReferences extends BaseReferences<
    _$AppDatabase, $RecentClipViewsTable, RecentClipView> {
  $$RecentClipViewsTableReferences(
      super.$_db, super.$_table, super.$_typedResult);

  static $ClipsTable _clipIdTable(_$AppDatabase db) => db.clips.createAlias(
      $_aliasNameGenerator(db.recentClipViews.clipId, db.clips.id));

  $$ClipsTableProcessedTableManager get clipId {
    final $_column = $_itemColumn<int>('clip_id')!;

    final manager = $$ClipsTableTableManager($_db, $_db.clips)
        .filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_clipIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
        manager.$state.copyWith(prefetchedData: [item]));
  }
}

class $$RecentClipViewsTableFilterComposer
    extends Composer<_$AppDatabase, $RecentClipViewsTable> {
  $$RecentClipViewsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get lastSeq => $composableBuilder(
      column: $table.lastSeq, builder: (column) => ColumnFilters(column));

  $$ClipsTableFilterComposer get clipId {
    final $$ClipsTableFilterComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.clipId,
        referencedTable: $db.clips,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$ClipsTableFilterComposer(
              $db: $db,
              $table: $db.clips,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }
}

class $$RecentClipViewsTableOrderingComposer
    extends Composer<_$AppDatabase, $RecentClipViewsTable> {
  $$RecentClipViewsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get lastSeq => $composableBuilder(
      column: $table.lastSeq, builder: (column) => ColumnOrderings(column));

  $$ClipsTableOrderingComposer get clipId {
    final $$ClipsTableOrderingComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.clipId,
        referencedTable: $db.clips,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$ClipsTableOrderingComposer(
              $db: $db,
              $table: $db.clips,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }
}

class $$RecentClipViewsTableAnnotationComposer
    extends Composer<_$AppDatabase, $RecentClipViewsTable> {
  $$RecentClipViewsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get lastSeq =>
      $composableBuilder(column: $table.lastSeq, builder: (column) => column);

  $$ClipsTableAnnotationComposer get clipId {
    final $$ClipsTableAnnotationComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.clipId,
        referencedTable: $db.clips,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$ClipsTableAnnotationComposer(
              $db: $db,
              $table: $db.clips,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }
}

class $$RecentClipViewsTableTableManager extends RootTableManager<
    _$AppDatabase,
    $RecentClipViewsTable,
    RecentClipView,
    $$RecentClipViewsTableFilterComposer,
    $$RecentClipViewsTableOrderingComposer,
    $$RecentClipViewsTableAnnotationComposer,
    $$RecentClipViewsTableCreateCompanionBuilder,
    $$RecentClipViewsTableUpdateCompanionBuilder,
    (RecentClipView, $$RecentClipViewsTableReferences),
    RecentClipView,
    PrefetchHooks Function({bool clipId})> {
  $$RecentClipViewsTableTableManager(
      _$AppDatabase db, $RecentClipViewsTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$RecentClipViewsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$RecentClipViewsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$RecentClipViewsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<int> clipId = const Value.absent(),
            Value<int> lastSeq = const Value.absent(),
          }) =>
              RecentClipViewsCompanion(
            clipId: clipId,
            lastSeq: lastSeq,
          ),
          createCompanionCallback: ({
            Value<int> clipId = const Value.absent(),
            required int lastSeq,
          }) =>
              RecentClipViewsCompanion.insert(
            clipId: clipId,
            lastSeq: lastSeq,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (
                    e.readTable(table),
                    $$RecentClipViewsTableReferences(db, table, e)
                  ))
              .toList(),
          prefetchHooksCallback: ({clipId = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [],
              addJoins: <
                  T extends TableManagerState<
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic>>(state) {
                if (clipId) {
                  state = state.withJoin(
                    currentTable: table,
                    currentColumn: table.clipId,
                    referencedTable:
                        $$RecentClipViewsTableReferences._clipIdTable(db),
                    referencedColumn:
                        $$RecentClipViewsTableReferences._clipIdTable(db).id,
                  ) as T;
                }

                return state;
              },
              getPrefetchedDataCallback: (items) async {
                return [];
              },
            );
          },
        ));
}

typedef $$RecentClipViewsTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $RecentClipViewsTable,
    RecentClipView,
    $$RecentClipViewsTableFilterComposer,
    $$RecentClipViewsTableOrderingComposer,
    $$RecentClipViewsTableAnnotationComposer,
    $$RecentClipViewsTableCreateCompanionBuilder,
    $$RecentClipViewsTableUpdateCompanionBuilder,
    (RecentClipView, $$RecentClipViewsTableReferences),
    RecentClipView,
    PrefetchHooks Function({bool clipId})>;
typedef $$GroupCollectionsTableCreateCompanionBuilder
    = GroupCollectionsCompanion Function({
  required int groupId,
  required int collectionId,
  Value<int> rowid,
});
typedef $$GroupCollectionsTableUpdateCompanionBuilder
    = GroupCollectionsCompanion Function({
  Value<int> groupId,
  Value<int> collectionId,
  Value<int> rowid,
});

final class $$GroupCollectionsTableReferences extends BaseReferences<
    _$AppDatabase, $GroupCollectionsTable, GroupCollection> {
  $$GroupCollectionsTableReferences(
      super.$_db, super.$_table, super.$_typedResult);

  static $GroupsTable _groupIdTable(_$AppDatabase db) => db.groups.createAlias(
      $_aliasNameGenerator(db.groupCollections.groupId, db.groups.id));

  $$GroupsTableProcessedTableManager get groupId {
    final $_column = $_itemColumn<int>('group_id')!;

    final manager = $$GroupsTableTableManager($_db, $_db.groups)
        .filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_groupIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
        manager.$state.copyWith(prefetchedData: [item]));
  }

  static $CollectionsTable _collectionIdTable(_$AppDatabase db) =>
      db.collections.createAlias($_aliasNameGenerator(
          db.groupCollections.collectionId, db.collections.id));

  $$CollectionsTableProcessedTableManager get collectionId {
    final $_column = $_itemColumn<int>('collection_id')!;

    final manager = $$CollectionsTableTableManager($_db, $_db.collections)
        .filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_collectionIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
        manager.$state.copyWith(prefetchedData: [item]));
  }
}

class $$GroupCollectionsTableFilterComposer
    extends Composer<_$AppDatabase, $GroupCollectionsTable> {
  $$GroupCollectionsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  $$GroupsTableFilterComposer get groupId {
    final $$GroupsTableFilterComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.groupId,
        referencedTable: $db.groups,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$GroupsTableFilterComposer(
              $db: $db,
              $table: $db.groups,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }

  $$CollectionsTableFilterComposer get collectionId {
    final $$CollectionsTableFilterComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.collectionId,
        referencedTable: $db.collections,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$CollectionsTableFilterComposer(
              $db: $db,
              $table: $db.collections,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }
}

class $$GroupCollectionsTableOrderingComposer
    extends Composer<_$AppDatabase, $GroupCollectionsTable> {
  $$GroupCollectionsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  $$GroupsTableOrderingComposer get groupId {
    final $$GroupsTableOrderingComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.groupId,
        referencedTable: $db.groups,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$GroupsTableOrderingComposer(
              $db: $db,
              $table: $db.groups,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }

  $$CollectionsTableOrderingComposer get collectionId {
    final $$CollectionsTableOrderingComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.collectionId,
        referencedTable: $db.collections,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$CollectionsTableOrderingComposer(
              $db: $db,
              $table: $db.collections,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }
}

class $$GroupCollectionsTableAnnotationComposer
    extends Composer<_$AppDatabase, $GroupCollectionsTable> {
  $$GroupCollectionsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  $$GroupsTableAnnotationComposer get groupId {
    final $$GroupsTableAnnotationComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.groupId,
        referencedTable: $db.groups,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$GroupsTableAnnotationComposer(
              $db: $db,
              $table: $db.groups,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }

  $$CollectionsTableAnnotationComposer get collectionId {
    final $$CollectionsTableAnnotationComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.collectionId,
        referencedTable: $db.collections,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$CollectionsTableAnnotationComposer(
              $db: $db,
              $table: $db.collections,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }
}

class $$GroupCollectionsTableTableManager extends RootTableManager<
    _$AppDatabase,
    $GroupCollectionsTable,
    GroupCollection,
    $$GroupCollectionsTableFilterComposer,
    $$GroupCollectionsTableOrderingComposer,
    $$GroupCollectionsTableAnnotationComposer,
    $$GroupCollectionsTableCreateCompanionBuilder,
    $$GroupCollectionsTableUpdateCompanionBuilder,
    (GroupCollection, $$GroupCollectionsTableReferences),
    GroupCollection,
    PrefetchHooks Function({bool groupId, bool collectionId})> {
  $$GroupCollectionsTableTableManager(
      _$AppDatabase db, $GroupCollectionsTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$GroupCollectionsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$GroupCollectionsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$GroupCollectionsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<int> groupId = const Value.absent(),
            Value<int> collectionId = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              GroupCollectionsCompanion(
            groupId: groupId,
            collectionId: collectionId,
            rowid: rowid,
          ),
          createCompanionCallback: ({
            required int groupId,
            required int collectionId,
            Value<int> rowid = const Value.absent(),
          }) =>
              GroupCollectionsCompanion.insert(
            groupId: groupId,
            collectionId: collectionId,
            rowid: rowid,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (
                    e.readTable(table),
                    $$GroupCollectionsTableReferences(db, table, e)
                  ))
              .toList(),
          prefetchHooksCallback: ({groupId = false, collectionId = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [],
              addJoins: <
                  T extends TableManagerState<
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic>>(state) {
                if (groupId) {
                  state = state.withJoin(
                    currentTable: table,
                    currentColumn: table.groupId,
                    referencedTable:
                        $$GroupCollectionsTableReferences._groupIdTable(db),
                    referencedColumn:
                        $$GroupCollectionsTableReferences._groupIdTable(db).id,
                  ) as T;
                }
                if (collectionId) {
                  state = state.withJoin(
                    currentTable: table,
                    currentColumn: table.collectionId,
                    referencedTable: $$GroupCollectionsTableReferences
                        ._collectionIdTable(db),
                    referencedColumn: $$GroupCollectionsTableReferences
                        ._collectionIdTable(db)
                        .id,
                  ) as T;
                }

                return state;
              },
              getPrefetchedDataCallback: (items) async {
                return [];
              },
            );
          },
        ));
}

typedef $$GroupCollectionsTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $GroupCollectionsTable,
    GroupCollection,
    $$GroupCollectionsTableFilterComposer,
    $$GroupCollectionsTableOrderingComposer,
    $$GroupCollectionsTableAnnotationComposer,
    $$GroupCollectionsTableCreateCompanionBuilder,
    $$GroupCollectionsTableUpdateCompanionBuilder,
    (GroupCollection, $$GroupCollectionsTableReferences),
    GroupCollection,
    PrefetchHooks Function({bool groupId, bool collectionId})>;

class $AppDatabaseManager {
  final _$AppDatabase _db;
  $AppDatabaseManager(this._db);
  $$GroupsTableTableManager get groups =>
      $$GroupsTableTableManager(_db, _db.groups);
  $$CollectionsTableTableManager get collections =>
      $$CollectionsTableTableManager(_db, _db.collections);
  $$ClipsTableTableManager get clips =>
      $$ClipsTableTableManager(_db, _db.clips);
  $$SegmentsTableTableManager get segments =>
      $$SegmentsTableTableManager(_db, _db.segments);
  $$TagsTableTableManager get tags => $$TagsTableTableManager(_db, _db.tags);
  $$ClipTagsTableTableManager get clipTags =>
      $$ClipTagsTableTableManager(_db, _db.clipTags);
  $$RecentClipViewsTableTableManager get recentClipViews =>
      $$RecentClipViewsTableTableManager(_db, _db.recentClipViews);
  $$GroupCollectionsTableTableManager get groupCollections =>
      $$GroupCollectionsTableTableManager(_db, _db.groupCollections);
}
