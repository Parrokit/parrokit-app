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
  static const VerificationMeta _storageModeMeta =
      const VerificationMeta('storageMode');
  @override
  late final GeneratedColumn<String> storageMode = GeneratedColumn<String>(
      'storage_mode', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: false,
      defaultValue: const Constant('local'));
  @override
  List<GeneratedColumn> get $columns => [id, name, storageMode];
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
    if (data.containsKey('storage_mode')) {
      context.handle(
          _storageModeMeta,
          storageMode.isAcceptableOrUnknown(
              data['storage_mode']!, _storageModeMeta));
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
      storageMode: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}storage_mode'])!,
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
  final String storageMode;
  const Group(
      {required this.id, required this.name, required this.storageMode});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['name'] = Variable<String>(name);
    map['storage_mode'] = Variable<String>(storageMode);
    return map;
  }

  GroupsCompanion toCompanion(bool nullToAbsent) {
    return GroupsCompanion(
      id: Value(id),
      name: Value(name),
      storageMode: Value(storageMode),
    );
  }

  factory Group.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Group(
      id: serializer.fromJson<int>(json['id']),
      name: serializer.fromJson<String>(json['name']),
      storageMode: serializer.fromJson<String>(json['storageMode']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'name': serializer.toJson<String>(name),
      'storageMode': serializer.toJson<String>(storageMode),
    };
  }

  Group copyWith({int? id, String? name, String? storageMode}) => Group(
        id: id ?? this.id,
        name: name ?? this.name,
        storageMode: storageMode ?? this.storageMode,
      );
  Group copyWithCompanion(GroupsCompanion data) {
    return Group(
      id: data.id.present ? data.id.value : this.id,
      name: data.name.present ? data.name.value : this.name,
      storageMode:
          data.storageMode.present ? data.storageMode.value : this.storageMode,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Group(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('storageMode: $storageMode')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, name, storageMode);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Group &&
          other.id == this.id &&
          other.name == this.name &&
          other.storageMode == this.storageMode);
}

class GroupsCompanion extends UpdateCompanion<Group> {
  final Value<int> id;
  final Value<String> name;
  final Value<String> storageMode;
  const GroupsCompanion({
    this.id = const Value.absent(),
    this.name = const Value.absent(),
    this.storageMode = const Value.absent(),
  });
  GroupsCompanion.insert({
    this.id = const Value.absent(),
    required String name,
    this.storageMode = const Value.absent(),
  }) : name = Value(name);
  static Insertable<Group> custom({
    Expression<int>? id,
    Expression<String>? name,
    Expression<String>? storageMode,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (name != null) 'name': name,
      if (storageMode != null) 'storage_mode': storageMode,
    });
  }

  GroupsCompanion copyWith(
      {Value<int>? id, Value<String>? name, Value<String>? storageMode}) {
    return GroupsCompanion(
      id: id ?? this.id,
      name: name ?? this.name,
      storageMode: storageMode ?? this.storageMode,
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
    if (storageMode.present) {
      map['storage_mode'] = Variable<String>(storageMode.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('GroupsCompanion(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('storageMode: $storageMode')
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
  static const VerificationMeta _storageModeMeta =
      const VerificationMeta('storageMode');
  @override
  late final GeneratedColumn<String> storageMode = GeneratedColumn<String>(
      'storage_mode', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: false,
      defaultValue: const Constant('local'));
  @override
  List<GeneratedColumn> get $columns => [id, name, storageMode];
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
    if (data.containsKey('storage_mode')) {
      context.handle(
          _storageModeMeta,
          storageMode.isAcceptableOrUnknown(
              data['storage_mode']!, _storageModeMeta));
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
      storageMode: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}storage_mode'])!,
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
  final String storageMode;
  const Collection(
      {required this.id, required this.name, required this.storageMode});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['name'] = Variable<String>(name);
    map['storage_mode'] = Variable<String>(storageMode);
    return map;
  }

  CollectionsCompanion toCompanion(bool nullToAbsent) {
    return CollectionsCompanion(
      id: Value(id),
      name: Value(name),
      storageMode: Value(storageMode),
    );
  }

  factory Collection.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Collection(
      id: serializer.fromJson<int>(json['id']),
      name: serializer.fromJson<String>(json['name']),
      storageMode: serializer.fromJson<String>(json['storageMode']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'name': serializer.toJson<String>(name),
      'storageMode': serializer.toJson<String>(storageMode),
    };
  }

  Collection copyWith({int? id, String? name, String? storageMode}) =>
      Collection(
        id: id ?? this.id,
        name: name ?? this.name,
        storageMode: storageMode ?? this.storageMode,
      );
  Collection copyWithCompanion(CollectionsCompanion data) {
    return Collection(
      id: data.id.present ? data.id.value : this.id,
      name: data.name.present ? data.name.value : this.name,
      storageMode:
          data.storageMode.present ? data.storageMode.value : this.storageMode,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Collection(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('storageMode: $storageMode')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, name, storageMode);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Collection &&
          other.id == this.id &&
          other.name == this.name &&
          other.storageMode == this.storageMode);
}

class CollectionsCompanion extends UpdateCompanion<Collection> {
  final Value<int> id;
  final Value<String> name;
  final Value<String> storageMode;
  const CollectionsCompanion({
    this.id = const Value.absent(),
    this.name = const Value.absent(),
    this.storageMode = const Value.absent(),
  });
  CollectionsCompanion.insert({
    this.id = const Value.absent(),
    required String name,
    this.storageMode = const Value.absent(),
  }) : name = Value(name);
  static Insertable<Collection> custom({
    Expression<int>? id,
    Expression<String>? name,
    Expression<String>? storageMode,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (name != null) 'name': name,
      if (storageMode != null) 'storage_mode': storageMode,
    });
  }

  CollectionsCompanion copyWith(
      {Value<int>? id, Value<String>? name, Value<String>? storageMode}) {
    return CollectionsCompanion(
      id: id ?? this.id,
      name: name ?? this.name,
      storageMode: storageMode ?? this.storageMode,
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
    if (storageMode.present) {
      map['storage_mode'] = Variable<String>(storageMode.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('CollectionsCompanion(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('storageMode: $storageMode')
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
  static const VerificationMeta _sourceFilePathMeta =
      const VerificationMeta('sourceFilePath');
  @override
  late final GeneratedColumn<String> sourceFilePath = GeneratedColumn<String>(
      'source_file_path', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _thumbnailFilePathMeta =
      const VerificationMeta('thumbnailFilePath');
  @override
  late final GeneratedColumn<String> thumbnailFilePath =
      GeneratedColumn<String>('thumbnail_file_path', aliasedName, true,
          type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _ownerScopeMeta =
      const VerificationMeta('ownerScope');
  @override
  late final GeneratedColumn<String> ownerScope = GeneratedColumn<String>(
      'owner_scope', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: false,
      defaultValue: const Constant('device'));
  static const VerificationMeta _ownerKeyMeta =
      const VerificationMeta('ownerKey');
  @override
  late final GeneratedColumn<String> ownerKey = GeneratedColumn<String>(
      'owner_key', aliasedName, true,
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
  @override
  List<GeneratedColumn> get $columns => [
        id,
        collectionId,
        title,
        filePath,
        sourceFilePath,
        thumbnailFilePath,
        ownerScope,
        ownerKey,
        storageMode,
        storageBytes,
        durationMs
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
    if (data.containsKey('source_file_path')) {
      context.handle(
          _sourceFilePathMeta,
          sourceFilePath.isAcceptableOrUnknown(
              data['source_file_path']!, _sourceFilePathMeta));
    }
    if (data.containsKey('thumbnail_file_path')) {
      context.handle(
          _thumbnailFilePathMeta,
          thumbnailFilePath.isAcceptableOrUnknown(
              data['thumbnail_file_path']!, _thumbnailFilePathMeta));
    }
    if (data.containsKey('owner_scope')) {
      context.handle(
          _ownerScopeMeta,
          ownerScope.isAcceptableOrUnknown(
              data['owner_scope']!, _ownerScopeMeta));
    }
    if (data.containsKey('owner_key')) {
      context.handle(_ownerKeyMeta,
          ownerKey.isAcceptableOrUnknown(data['owner_key']!, _ownerKeyMeta));
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
      sourceFilePath: attachedDatabase.typeMapping.read(
          DriftSqlType.string, data['${effectivePrefix}source_file_path']),
      thumbnailFilePath: attachedDatabase.typeMapping.read(
          DriftSqlType.string, data['${effectivePrefix}thumbnail_file_path']),
      ownerScope: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}owner_scope'])!,
      ownerKey: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}owner_key']),
      storageMode: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}storage_mode'])!,
      storageBytes: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}storage_bytes'])!,
      durationMs: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}duration_ms'])!,
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
  final String? sourceFilePath;
  final String? thumbnailFilePath;
  final String ownerScope;
  final String? ownerKey;
  final String storageMode;
  final int storageBytes;
  final int durationMs;
  const Clip(
      {required this.id,
      this.collectionId,
      required this.title,
      required this.filePath,
      this.sourceFilePath,
      this.thumbnailFilePath,
      required this.ownerScope,
      this.ownerKey,
      required this.storageMode,
      required this.storageBytes,
      required this.durationMs});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    if (!nullToAbsent || collectionId != null) {
      map['collection_id'] = Variable<int>(collectionId);
    }
    map['title'] = Variable<String>(title);
    map['file_path'] = Variable<String>(filePath);
    if (!nullToAbsent || sourceFilePath != null) {
      map['source_file_path'] = Variable<String>(sourceFilePath);
    }
    if (!nullToAbsent || thumbnailFilePath != null) {
      map['thumbnail_file_path'] = Variable<String>(thumbnailFilePath);
    }
    map['owner_scope'] = Variable<String>(ownerScope);
    if (!nullToAbsent || ownerKey != null) {
      map['owner_key'] = Variable<String>(ownerKey);
    }
    map['storage_mode'] = Variable<String>(storageMode);
    map['storage_bytes'] = Variable<int>(storageBytes);
    map['duration_ms'] = Variable<int>(durationMs);
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
      sourceFilePath: sourceFilePath == null && nullToAbsent
          ? const Value.absent()
          : Value(sourceFilePath),
      thumbnailFilePath: thumbnailFilePath == null && nullToAbsent
          ? const Value.absent()
          : Value(thumbnailFilePath),
      ownerScope: Value(ownerScope),
      ownerKey: ownerKey == null && nullToAbsent
          ? const Value.absent()
          : Value(ownerKey),
      storageMode: Value(storageMode),
      storageBytes: Value(storageBytes),
      durationMs: Value(durationMs),
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
      sourceFilePath: serializer.fromJson<String?>(json['sourceFilePath']),
      thumbnailFilePath:
          serializer.fromJson<String?>(json['thumbnailFilePath']),
      ownerScope: serializer.fromJson<String>(json['ownerScope']),
      ownerKey: serializer.fromJson<String?>(json['ownerKey']),
      storageMode: serializer.fromJson<String>(json['storageMode']),
      storageBytes: serializer.fromJson<int>(json['storageBytes']),
      durationMs: serializer.fromJson<int>(json['durationMs']),
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
      'sourceFilePath': serializer.toJson<String?>(sourceFilePath),
      'thumbnailFilePath': serializer.toJson<String?>(thumbnailFilePath),
      'ownerScope': serializer.toJson<String>(ownerScope),
      'ownerKey': serializer.toJson<String?>(ownerKey),
      'storageMode': serializer.toJson<String>(storageMode),
      'storageBytes': serializer.toJson<int>(storageBytes),
      'durationMs': serializer.toJson<int>(durationMs),
    };
  }

  Clip copyWith(
          {int? id,
          Value<int?> collectionId = const Value.absent(),
          String? title,
          String? filePath,
          Value<String?> sourceFilePath = const Value.absent(),
          Value<String?> thumbnailFilePath = const Value.absent(),
          String? ownerScope,
          Value<String?> ownerKey = const Value.absent(),
          String? storageMode,
          int? storageBytes,
          int? durationMs}) =>
      Clip(
        id: id ?? this.id,
        collectionId:
            collectionId.present ? collectionId.value : this.collectionId,
        title: title ?? this.title,
        filePath: filePath ?? this.filePath,
        sourceFilePath:
            sourceFilePath.present ? sourceFilePath.value : this.sourceFilePath,
        thumbnailFilePath: thumbnailFilePath.present
            ? thumbnailFilePath.value
            : this.thumbnailFilePath,
        ownerScope: ownerScope ?? this.ownerScope,
        ownerKey: ownerKey.present ? ownerKey.value : this.ownerKey,
        storageMode: storageMode ?? this.storageMode,
        storageBytes: storageBytes ?? this.storageBytes,
        durationMs: durationMs ?? this.durationMs,
      );
  Clip copyWithCompanion(ClipsCompanion data) {
    return Clip(
      id: data.id.present ? data.id.value : this.id,
      collectionId: data.collectionId.present
          ? data.collectionId.value
          : this.collectionId,
      title: data.title.present ? data.title.value : this.title,
      filePath: data.filePath.present ? data.filePath.value : this.filePath,
      sourceFilePath: data.sourceFilePath.present
          ? data.sourceFilePath.value
          : this.sourceFilePath,
      thumbnailFilePath: data.thumbnailFilePath.present
          ? data.thumbnailFilePath.value
          : this.thumbnailFilePath,
      ownerScope:
          data.ownerScope.present ? data.ownerScope.value : this.ownerScope,
      ownerKey: data.ownerKey.present ? data.ownerKey.value : this.ownerKey,
      storageMode:
          data.storageMode.present ? data.storageMode.value : this.storageMode,
      storageBytes: data.storageBytes.present
          ? data.storageBytes.value
          : this.storageBytes,
      durationMs:
          data.durationMs.present ? data.durationMs.value : this.durationMs,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Clip(')
          ..write('id: $id, ')
          ..write('collectionId: $collectionId, ')
          ..write('title: $title, ')
          ..write('filePath: $filePath, ')
          ..write('sourceFilePath: $sourceFilePath, ')
          ..write('thumbnailFilePath: $thumbnailFilePath, ')
          ..write('ownerScope: $ownerScope, ')
          ..write('ownerKey: $ownerKey, ')
          ..write('storageMode: $storageMode, ')
          ..write('storageBytes: $storageBytes, ')
          ..write('durationMs: $durationMs')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
      id,
      collectionId,
      title,
      filePath,
      sourceFilePath,
      thumbnailFilePath,
      ownerScope,
      ownerKey,
      storageMode,
      storageBytes,
      durationMs);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Clip &&
          other.id == this.id &&
          other.collectionId == this.collectionId &&
          other.title == this.title &&
          other.filePath == this.filePath &&
          other.sourceFilePath == this.sourceFilePath &&
          other.thumbnailFilePath == this.thumbnailFilePath &&
          other.ownerScope == this.ownerScope &&
          other.ownerKey == this.ownerKey &&
          other.storageMode == this.storageMode &&
          other.storageBytes == this.storageBytes &&
          other.durationMs == this.durationMs);
}

class ClipsCompanion extends UpdateCompanion<Clip> {
  final Value<int> id;
  final Value<int?> collectionId;
  final Value<String> title;
  final Value<String> filePath;
  final Value<String?> sourceFilePath;
  final Value<String?> thumbnailFilePath;
  final Value<String> ownerScope;
  final Value<String?> ownerKey;
  final Value<String> storageMode;
  final Value<int> storageBytes;
  final Value<int> durationMs;
  const ClipsCompanion({
    this.id = const Value.absent(),
    this.collectionId = const Value.absent(),
    this.title = const Value.absent(),
    this.filePath = const Value.absent(),
    this.sourceFilePath = const Value.absent(),
    this.thumbnailFilePath = const Value.absent(),
    this.ownerScope = const Value.absent(),
    this.ownerKey = const Value.absent(),
    this.storageMode = const Value.absent(),
    this.storageBytes = const Value.absent(),
    this.durationMs = const Value.absent(),
  });
  ClipsCompanion.insert({
    this.id = const Value.absent(),
    this.collectionId = const Value.absent(),
    required String title,
    required String filePath,
    this.sourceFilePath = const Value.absent(),
    this.thumbnailFilePath = const Value.absent(),
    this.ownerScope = const Value.absent(),
    this.ownerKey = const Value.absent(),
    this.storageMode = const Value.absent(),
    this.storageBytes = const Value.absent(),
    required int durationMs,
  })  : title = Value(title),
        filePath = Value(filePath),
        durationMs = Value(durationMs);
  static Insertable<Clip> custom({
    Expression<int>? id,
    Expression<int>? collectionId,
    Expression<String>? title,
    Expression<String>? filePath,
    Expression<String>? sourceFilePath,
    Expression<String>? thumbnailFilePath,
    Expression<String>? ownerScope,
    Expression<String>? ownerKey,
    Expression<String>? storageMode,
    Expression<int>? storageBytes,
    Expression<int>? durationMs,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (collectionId != null) 'collection_id': collectionId,
      if (title != null) 'title': title,
      if (filePath != null) 'file_path': filePath,
      if (sourceFilePath != null) 'source_file_path': sourceFilePath,
      if (thumbnailFilePath != null) 'thumbnail_file_path': thumbnailFilePath,
      if (ownerScope != null) 'owner_scope': ownerScope,
      if (ownerKey != null) 'owner_key': ownerKey,
      if (storageMode != null) 'storage_mode': storageMode,
      if (storageBytes != null) 'storage_bytes': storageBytes,
      if (durationMs != null) 'duration_ms': durationMs,
    });
  }

  ClipsCompanion copyWith(
      {Value<int>? id,
      Value<int?>? collectionId,
      Value<String>? title,
      Value<String>? filePath,
      Value<String?>? sourceFilePath,
      Value<String?>? thumbnailFilePath,
      Value<String>? ownerScope,
      Value<String?>? ownerKey,
      Value<String>? storageMode,
      Value<int>? storageBytes,
      Value<int>? durationMs}) {
    return ClipsCompanion(
      id: id ?? this.id,
      collectionId: collectionId ?? this.collectionId,
      title: title ?? this.title,
      filePath: filePath ?? this.filePath,
      sourceFilePath: sourceFilePath ?? this.sourceFilePath,
      thumbnailFilePath: thumbnailFilePath ?? this.thumbnailFilePath,
      ownerScope: ownerScope ?? this.ownerScope,
      ownerKey: ownerKey ?? this.ownerKey,
      storageMode: storageMode ?? this.storageMode,
      storageBytes: storageBytes ?? this.storageBytes,
      durationMs: durationMs ?? this.durationMs,
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
    if (sourceFilePath.present) {
      map['source_file_path'] = Variable<String>(sourceFilePath.value);
    }
    if (thumbnailFilePath.present) {
      map['thumbnail_file_path'] = Variable<String>(thumbnailFilePath.value);
    }
    if (ownerScope.present) {
      map['owner_scope'] = Variable<String>(ownerScope.value);
    }
    if (ownerKey.present) {
      map['owner_key'] = Variable<String>(ownerKey.value);
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
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('ClipsCompanion(')
          ..write('id: $id, ')
          ..write('collectionId: $collectionId, ')
          ..write('title: $title, ')
          ..write('filePath: $filePath, ')
          ..write('sourceFilePath: $sourceFilePath, ')
          ..write('thumbnailFilePath: $thumbnailFilePath, ')
          ..write('ownerScope: $ownerScope, ')
          ..write('ownerKey: $ownerKey, ')
          ..write('storageMode: $storageMode, ')
          ..write('storageBytes: $storageBytes, ')
          ..write('durationMs: $durationMs')
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

class $ClipSourceRefsTable extends ClipSourceRefs
    with TableInfo<$ClipSourceRefsTable, ClipSourceRef> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $ClipSourceRefsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _clipIdMeta = const VerificationMeta('clipId');
  @override
  late final GeneratedColumn<int> clipId = GeneratedColumn<int>(
      'clip_id', aliasedName, false,
      type: DriftSqlType.int,
      requiredDuringInsert: true,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('REFERENCES clips (id)'));
  static const VerificationMeta _providerMeta =
      const VerificationMeta('provider');
  @override
  late final GeneratedColumn<String> provider = GeneratedColumn<String>(
      'provider', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _ownerScopeMeta =
      const VerificationMeta('ownerScope');
  @override
  late final GeneratedColumn<String> ownerScope = GeneratedColumn<String>(
      'owner_scope', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _ownerKeyMeta =
      const VerificationMeta('ownerKey');
  @override
  late final GeneratedColumn<String> ownerKey = GeneratedColumn<String>(
      'owner_key', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _remoteDocIdMeta =
      const VerificationMeta('remoteDocId');
  @override
  late final GeneratedColumn<String> remoteDocId = GeneratedColumn<String>(
      'remote_doc_id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _storagePathMeta =
      const VerificationMeta('storagePath');
  @override
  late final GeneratedColumn<String> storagePath = GeneratedColumn<String>(
      'storage_path', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _downloadUrlMeta =
      const VerificationMeta('downloadUrl');
  @override
  late final GeneratedColumn<String> downloadUrl = GeneratedColumn<String>(
      'download_url', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _thumbnailStoragePathMeta =
      const VerificationMeta('thumbnailStoragePath');
  @override
  late final GeneratedColumn<String> thumbnailStoragePath =
      GeneratedColumn<String>('thumbnail_storage_path', aliasedName, true,
          type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _thumbnailDownloadUrlMeta =
      const VerificationMeta('thumbnailDownloadUrl');
  @override
  late final GeneratedColumn<String> thumbnailDownloadUrl =
      GeneratedColumn<String>('thumbnail_download_url', aliasedName, true,
          type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _thumbnailRemoteFileIdMeta =
      const VerificationMeta('thumbnailRemoteFileId');
  @override
  late final GeneratedColumn<String> thumbnailRemoteFileId =
      GeneratedColumn<String>('thumbnail_remote_file_id', aliasedName, true,
          type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _remoteFileIdMeta =
      const VerificationMeta('remoteFileId');
  @override
  late final GeneratedColumn<String> remoteFileId = GeneratedColumn<String>(
      'remote_file_id', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _cloudFolderIdMeta =
      const VerificationMeta('cloudFolderId');
  @override
  late final GeneratedColumn<String> cloudFolderId = GeneratedColumn<String>(
      'cloud_folder_id', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _metadataPathMeta =
      const VerificationMeta('metadataPath');
  @override
  late final GeneratedColumn<String> metadataPath = GeneratedColumn<String>(
      'metadata_path', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _lastSyncedAtMeta =
      const VerificationMeta('lastSyncedAt');
  @override
  late final GeneratedColumn<DateTime> lastSyncedAt = GeneratedColumn<DateTime>(
      'last_synced_at', aliasedName, true,
      type: DriftSqlType.dateTime, requiredDuringInsert: false);
  @override
  List<GeneratedColumn> get $columns => [
        clipId,
        provider,
        ownerScope,
        ownerKey,
        remoteDocId,
        storagePath,
        downloadUrl,
        thumbnailStoragePath,
        thumbnailDownloadUrl,
        thumbnailRemoteFileId,
        remoteFileId,
        cloudFolderId,
        metadataPath,
        lastSyncedAt
      ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'clip_source_refs';
  @override
  VerificationContext validateIntegrity(Insertable<ClipSourceRef> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('clip_id')) {
      context.handle(_clipIdMeta,
          clipId.isAcceptableOrUnknown(data['clip_id']!, _clipIdMeta));
    } else if (isInserting) {
      context.missing(_clipIdMeta);
    }
    if (data.containsKey('provider')) {
      context.handle(_providerMeta,
          provider.isAcceptableOrUnknown(data['provider']!, _providerMeta));
    } else if (isInserting) {
      context.missing(_providerMeta);
    }
    if (data.containsKey('owner_scope')) {
      context.handle(
          _ownerScopeMeta,
          ownerScope.isAcceptableOrUnknown(
              data['owner_scope']!, _ownerScopeMeta));
    } else if (isInserting) {
      context.missing(_ownerScopeMeta);
    }
    if (data.containsKey('owner_key')) {
      context.handle(_ownerKeyMeta,
          ownerKey.isAcceptableOrUnknown(data['owner_key']!, _ownerKeyMeta));
    } else if (isInserting) {
      context.missing(_ownerKeyMeta);
    }
    if (data.containsKey('remote_doc_id')) {
      context.handle(
          _remoteDocIdMeta,
          remoteDocId.isAcceptableOrUnknown(
              data['remote_doc_id']!, _remoteDocIdMeta));
    } else if (isInserting) {
      context.missing(_remoteDocIdMeta);
    }
    if (data.containsKey('storage_path')) {
      context.handle(
          _storagePathMeta,
          storagePath.isAcceptableOrUnknown(
              data['storage_path']!, _storagePathMeta));
    }
    if (data.containsKey('download_url')) {
      context.handle(
          _downloadUrlMeta,
          downloadUrl.isAcceptableOrUnknown(
              data['download_url']!, _downloadUrlMeta));
    }
    if (data.containsKey('thumbnail_storage_path')) {
      context.handle(
          _thumbnailStoragePathMeta,
          thumbnailStoragePath.isAcceptableOrUnknown(
              data['thumbnail_storage_path']!, _thumbnailStoragePathMeta));
    }
    if (data.containsKey('thumbnail_download_url')) {
      context.handle(
          _thumbnailDownloadUrlMeta,
          thumbnailDownloadUrl.isAcceptableOrUnknown(
              data['thumbnail_download_url']!, _thumbnailDownloadUrlMeta));
    }
    if (data.containsKey('thumbnail_remote_file_id')) {
      context.handle(
          _thumbnailRemoteFileIdMeta,
          thumbnailRemoteFileId.isAcceptableOrUnknown(
              data['thumbnail_remote_file_id']!, _thumbnailRemoteFileIdMeta));
    }
    if (data.containsKey('remote_file_id')) {
      context.handle(
          _remoteFileIdMeta,
          remoteFileId.isAcceptableOrUnknown(
              data['remote_file_id']!, _remoteFileIdMeta));
    }
    if (data.containsKey('cloud_folder_id')) {
      context.handle(
          _cloudFolderIdMeta,
          cloudFolderId.isAcceptableOrUnknown(
              data['cloud_folder_id']!, _cloudFolderIdMeta));
    }
    if (data.containsKey('metadata_path')) {
      context.handle(
          _metadataPathMeta,
          metadataPath.isAcceptableOrUnknown(
              data['metadata_path']!, _metadataPathMeta));
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
  Set<GeneratedColumn> get $primaryKey =>
      {clipId, provider, ownerScope, ownerKey};
  @override
  ClipSourceRef map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return ClipSourceRef(
      clipId: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}clip_id'])!,
      provider: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}provider'])!,
      ownerScope: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}owner_scope'])!,
      ownerKey: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}owner_key'])!,
      remoteDocId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}remote_doc_id'])!,
      storagePath: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}storage_path']),
      downloadUrl: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}download_url']),
      thumbnailStoragePath: attachedDatabase.typeMapping.read(
          DriftSqlType.string,
          data['${effectivePrefix}thumbnail_storage_path']),
      thumbnailDownloadUrl: attachedDatabase.typeMapping.read(
          DriftSqlType.string,
          data['${effectivePrefix}thumbnail_download_url']),
      thumbnailRemoteFileId: attachedDatabase.typeMapping.read(
          DriftSqlType.string,
          data['${effectivePrefix}thumbnail_remote_file_id']),
      remoteFileId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}remote_file_id']),
      cloudFolderId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}cloud_folder_id']),
      metadataPath: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}metadata_path']),
      lastSyncedAt: attachedDatabase.typeMapping.read(
          DriftSqlType.dateTime, data['${effectivePrefix}last_synced_at']),
    );
  }

  @override
  $ClipSourceRefsTable createAlias(String alias) {
    return $ClipSourceRefsTable(attachedDatabase, alias);
  }
}

class ClipSourceRef extends DataClass implements Insertable<ClipSourceRef> {
  final int clipId;
  final String provider;
  final String ownerScope;
  final String ownerKey;
  final String remoteDocId;
  final String? storagePath;
  final String? downloadUrl;
  final String? thumbnailStoragePath;
  final String? thumbnailDownloadUrl;
  final String? thumbnailRemoteFileId;
  final String? remoteFileId;
  final String? cloudFolderId;
  final String? metadataPath;
  final DateTime? lastSyncedAt;
  const ClipSourceRef(
      {required this.clipId,
      required this.provider,
      required this.ownerScope,
      required this.ownerKey,
      required this.remoteDocId,
      this.storagePath,
      this.downloadUrl,
      this.thumbnailStoragePath,
      this.thumbnailDownloadUrl,
      this.thumbnailRemoteFileId,
      this.remoteFileId,
      this.cloudFolderId,
      this.metadataPath,
      this.lastSyncedAt});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['clip_id'] = Variable<int>(clipId);
    map['provider'] = Variable<String>(provider);
    map['owner_scope'] = Variable<String>(ownerScope);
    map['owner_key'] = Variable<String>(ownerKey);
    map['remote_doc_id'] = Variable<String>(remoteDocId);
    if (!nullToAbsent || storagePath != null) {
      map['storage_path'] = Variable<String>(storagePath);
    }
    if (!nullToAbsent || downloadUrl != null) {
      map['download_url'] = Variable<String>(downloadUrl);
    }
    if (!nullToAbsent || thumbnailStoragePath != null) {
      map['thumbnail_storage_path'] = Variable<String>(thumbnailStoragePath);
    }
    if (!nullToAbsent || thumbnailDownloadUrl != null) {
      map['thumbnail_download_url'] = Variable<String>(thumbnailDownloadUrl);
    }
    if (!nullToAbsent || thumbnailRemoteFileId != null) {
      map['thumbnail_remote_file_id'] = Variable<String>(thumbnailRemoteFileId);
    }
    if (!nullToAbsent || remoteFileId != null) {
      map['remote_file_id'] = Variable<String>(remoteFileId);
    }
    if (!nullToAbsent || cloudFolderId != null) {
      map['cloud_folder_id'] = Variable<String>(cloudFolderId);
    }
    if (!nullToAbsent || metadataPath != null) {
      map['metadata_path'] = Variable<String>(metadataPath);
    }
    if (!nullToAbsent || lastSyncedAt != null) {
      map['last_synced_at'] = Variable<DateTime>(lastSyncedAt);
    }
    return map;
  }

  ClipSourceRefsCompanion toCompanion(bool nullToAbsent) {
    return ClipSourceRefsCompanion(
      clipId: Value(clipId),
      provider: Value(provider),
      ownerScope: Value(ownerScope),
      ownerKey: Value(ownerKey),
      remoteDocId: Value(remoteDocId),
      storagePath: storagePath == null && nullToAbsent
          ? const Value.absent()
          : Value(storagePath),
      downloadUrl: downloadUrl == null && nullToAbsent
          ? const Value.absent()
          : Value(downloadUrl),
      thumbnailStoragePath: thumbnailStoragePath == null && nullToAbsent
          ? const Value.absent()
          : Value(thumbnailStoragePath),
      thumbnailDownloadUrl: thumbnailDownloadUrl == null && nullToAbsent
          ? const Value.absent()
          : Value(thumbnailDownloadUrl),
      thumbnailRemoteFileId: thumbnailRemoteFileId == null && nullToAbsent
          ? const Value.absent()
          : Value(thumbnailRemoteFileId),
      remoteFileId: remoteFileId == null && nullToAbsent
          ? const Value.absent()
          : Value(remoteFileId),
      cloudFolderId: cloudFolderId == null && nullToAbsent
          ? const Value.absent()
          : Value(cloudFolderId),
      metadataPath: metadataPath == null && nullToAbsent
          ? const Value.absent()
          : Value(metadataPath),
      lastSyncedAt: lastSyncedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(lastSyncedAt),
    );
  }

  factory ClipSourceRef.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return ClipSourceRef(
      clipId: serializer.fromJson<int>(json['clipId']),
      provider: serializer.fromJson<String>(json['provider']),
      ownerScope: serializer.fromJson<String>(json['ownerScope']),
      ownerKey: serializer.fromJson<String>(json['ownerKey']),
      remoteDocId: serializer.fromJson<String>(json['remoteDocId']),
      storagePath: serializer.fromJson<String?>(json['storagePath']),
      downloadUrl: serializer.fromJson<String?>(json['downloadUrl']),
      thumbnailStoragePath:
          serializer.fromJson<String?>(json['thumbnailStoragePath']),
      thumbnailDownloadUrl:
          serializer.fromJson<String?>(json['thumbnailDownloadUrl']),
      thumbnailRemoteFileId:
          serializer.fromJson<String?>(json['thumbnailRemoteFileId']),
      remoteFileId: serializer.fromJson<String?>(json['remoteFileId']),
      cloudFolderId: serializer.fromJson<String?>(json['cloudFolderId']),
      metadataPath: serializer.fromJson<String?>(json['metadataPath']),
      lastSyncedAt: serializer.fromJson<DateTime?>(json['lastSyncedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'clipId': serializer.toJson<int>(clipId),
      'provider': serializer.toJson<String>(provider),
      'ownerScope': serializer.toJson<String>(ownerScope),
      'ownerKey': serializer.toJson<String>(ownerKey),
      'remoteDocId': serializer.toJson<String>(remoteDocId),
      'storagePath': serializer.toJson<String?>(storagePath),
      'downloadUrl': serializer.toJson<String?>(downloadUrl),
      'thumbnailStoragePath': serializer.toJson<String?>(thumbnailStoragePath),
      'thumbnailDownloadUrl': serializer.toJson<String?>(thumbnailDownloadUrl),
      'thumbnailRemoteFileId':
          serializer.toJson<String?>(thumbnailRemoteFileId),
      'remoteFileId': serializer.toJson<String?>(remoteFileId),
      'cloudFolderId': serializer.toJson<String?>(cloudFolderId),
      'metadataPath': serializer.toJson<String?>(metadataPath),
      'lastSyncedAt': serializer.toJson<DateTime?>(lastSyncedAt),
    };
  }

  ClipSourceRef copyWith(
          {int? clipId,
          String? provider,
          String? ownerScope,
          String? ownerKey,
          String? remoteDocId,
          Value<String?> storagePath = const Value.absent(),
          Value<String?> downloadUrl = const Value.absent(),
          Value<String?> thumbnailStoragePath = const Value.absent(),
          Value<String?> thumbnailDownloadUrl = const Value.absent(),
          Value<String?> thumbnailRemoteFileId = const Value.absent(),
          Value<String?> remoteFileId = const Value.absent(),
          Value<String?> cloudFolderId = const Value.absent(),
          Value<String?> metadataPath = const Value.absent(),
          Value<DateTime?> lastSyncedAt = const Value.absent()}) =>
      ClipSourceRef(
        clipId: clipId ?? this.clipId,
        provider: provider ?? this.provider,
        ownerScope: ownerScope ?? this.ownerScope,
        ownerKey: ownerKey ?? this.ownerKey,
        remoteDocId: remoteDocId ?? this.remoteDocId,
        storagePath: storagePath.present ? storagePath.value : this.storagePath,
        downloadUrl: downloadUrl.present ? downloadUrl.value : this.downloadUrl,
        thumbnailStoragePath: thumbnailStoragePath.present
            ? thumbnailStoragePath.value
            : this.thumbnailStoragePath,
        thumbnailDownloadUrl: thumbnailDownloadUrl.present
            ? thumbnailDownloadUrl.value
            : this.thumbnailDownloadUrl,
        thumbnailRemoteFileId: thumbnailRemoteFileId.present
            ? thumbnailRemoteFileId.value
            : this.thumbnailRemoteFileId,
        remoteFileId:
            remoteFileId.present ? remoteFileId.value : this.remoteFileId,
        cloudFolderId:
            cloudFolderId.present ? cloudFolderId.value : this.cloudFolderId,
        metadataPath:
            metadataPath.present ? metadataPath.value : this.metadataPath,
        lastSyncedAt:
            lastSyncedAt.present ? lastSyncedAt.value : this.lastSyncedAt,
      );
  ClipSourceRef copyWithCompanion(ClipSourceRefsCompanion data) {
    return ClipSourceRef(
      clipId: data.clipId.present ? data.clipId.value : this.clipId,
      provider: data.provider.present ? data.provider.value : this.provider,
      ownerScope:
          data.ownerScope.present ? data.ownerScope.value : this.ownerScope,
      ownerKey: data.ownerKey.present ? data.ownerKey.value : this.ownerKey,
      remoteDocId:
          data.remoteDocId.present ? data.remoteDocId.value : this.remoteDocId,
      storagePath:
          data.storagePath.present ? data.storagePath.value : this.storagePath,
      downloadUrl:
          data.downloadUrl.present ? data.downloadUrl.value : this.downloadUrl,
      thumbnailStoragePath: data.thumbnailStoragePath.present
          ? data.thumbnailStoragePath.value
          : this.thumbnailStoragePath,
      thumbnailDownloadUrl: data.thumbnailDownloadUrl.present
          ? data.thumbnailDownloadUrl.value
          : this.thumbnailDownloadUrl,
      thumbnailRemoteFileId: data.thumbnailRemoteFileId.present
          ? data.thumbnailRemoteFileId.value
          : this.thumbnailRemoteFileId,
      remoteFileId: data.remoteFileId.present
          ? data.remoteFileId.value
          : this.remoteFileId,
      cloudFolderId: data.cloudFolderId.present
          ? data.cloudFolderId.value
          : this.cloudFolderId,
      metadataPath: data.metadataPath.present
          ? data.metadataPath.value
          : this.metadataPath,
      lastSyncedAt: data.lastSyncedAt.present
          ? data.lastSyncedAt.value
          : this.lastSyncedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('ClipSourceRef(')
          ..write('clipId: $clipId, ')
          ..write('provider: $provider, ')
          ..write('ownerScope: $ownerScope, ')
          ..write('ownerKey: $ownerKey, ')
          ..write('remoteDocId: $remoteDocId, ')
          ..write('storagePath: $storagePath, ')
          ..write('downloadUrl: $downloadUrl, ')
          ..write('thumbnailStoragePath: $thumbnailStoragePath, ')
          ..write('thumbnailDownloadUrl: $thumbnailDownloadUrl, ')
          ..write('thumbnailRemoteFileId: $thumbnailRemoteFileId, ')
          ..write('remoteFileId: $remoteFileId, ')
          ..write('cloudFolderId: $cloudFolderId, ')
          ..write('metadataPath: $metadataPath, ')
          ..write('lastSyncedAt: $lastSyncedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
      clipId,
      provider,
      ownerScope,
      ownerKey,
      remoteDocId,
      storagePath,
      downloadUrl,
      thumbnailStoragePath,
      thumbnailDownloadUrl,
      thumbnailRemoteFileId,
      remoteFileId,
      cloudFolderId,
      metadataPath,
      lastSyncedAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is ClipSourceRef &&
          other.clipId == this.clipId &&
          other.provider == this.provider &&
          other.ownerScope == this.ownerScope &&
          other.ownerKey == this.ownerKey &&
          other.remoteDocId == this.remoteDocId &&
          other.storagePath == this.storagePath &&
          other.downloadUrl == this.downloadUrl &&
          other.thumbnailStoragePath == this.thumbnailStoragePath &&
          other.thumbnailDownloadUrl == this.thumbnailDownloadUrl &&
          other.thumbnailRemoteFileId == this.thumbnailRemoteFileId &&
          other.remoteFileId == this.remoteFileId &&
          other.cloudFolderId == this.cloudFolderId &&
          other.metadataPath == this.metadataPath &&
          other.lastSyncedAt == this.lastSyncedAt);
}

class ClipSourceRefsCompanion extends UpdateCompanion<ClipSourceRef> {
  final Value<int> clipId;
  final Value<String> provider;
  final Value<String> ownerScope;
  final Value<String> ownerKey;
  final Value<String> remoteDocId;
  final Value<String?> storagePath;
  final Value<String?> downloadUrl;
  final Value<String?> thumbnailStoragePath;
  final Value<String?> thumbnailDownloadUrl;
  final Value<String?> thumbnailRemoteFileId;
  final Value<String?> remoteFileId;
  final Value<String?> cloudFolderId;
  final Value<String?> metadataPath;
  final Value<DateTime?> lastSyncedAt;
  final Value<int> rowid;
  const ClipSourceRefsCompanion({
    this.clipId = const Value.absent(),
    this.provider = const Value.absent(),
    this.ownerScope = const Value.absent(),
    this.ownerKey = const Value.absent(),
    this.remoteDocId = const Value.absent(),
    this.storagePath = const Value.absent(),
    this.downloadUrl = const Value.absent(),
    this.thumbnailStoragePath = const Value.absent(),
    this.thumbnailDownloadUrl = const Value.absent(),
    this.thumbnailRemoteFileId = const Value.absent(),
    this.remoteFileId = const Value.absent(),
    this.cloudFolderId = const Value.absent(),
    this.metadataPath = const Value.absent(),
    this.lastSyncedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  ClipSourceRefsCompanion.insert({
    required int clipId,
    required String provider,
    required String ownerScope,
    required String ownerKey,
    required String remoteDocId,
    this.storagePath = const Value.absent(),
    this.downloadUrl = const Value.absent(),
    this.thumbnailStoragePath = const Value.absent(),
    this.thumbnailDownloadUrl = const Value.absent(),
    this.thumbnailRemoteFileId = const Value.absent(),
    this.remoteFileId = const Value.absent(),
    this.cloudFolderId = const Value.absent(),
    this.metadataPath = const Value.absent(),
    this.lastSyncedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  })  : clipId = Value(clipId),
        provider = Value(provider),
        ownerScope = Value(ownerScope),
        ownerKey = Value(ownerKey),
        remoteDocId = Value(remoteDocId);
  static Insertable<ClipSourceRef> custom({
    Expression<int>? clipId,
    Expression<String>? provider,
    Expression<String>? ownerScope,
    Expression<String>? ownerKey,
    Expression<String>? remoteDocId,
    Expression<String>? storagePath,
    Expression<String>? downloadUrl,
    Expression<String>? thumbnailStoragePath,
    Expression<String>? thumbnailDownloadUrl,
    Expression<String>? thumbnailRemoteFileId,
    Expression<String>? remoteFileId,
    Expression<String>? cloudFolderId,
    Expression<String>? metadataPath,
    Expression<DateTime>? lastSyncedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (clipId != null) 'clip_id': clipId,
      if (provider != null) 'provider': provider,
      if (ownerScope != null) 'owner_scope': ownerScope,
      if (ownerKey != null) 'owner_key': ownerKey,
      if (remoteDocId != null) 'remote_doc_id': remoteDocId,
      if (storagePath != null) 'storage_path': storagePath,
      if (downloadUrl != null) 'download_url': downloadUrl,
      if (thumbnailStoragePath != null)
        'thumbnail_storage_path': thumbnailStoragePath,
      if (thumbnailDownloadUrl != null)
        'thumbnail_download_url': thumbnailDownloadUrl,
      if (thumbnailRemoteFileId != null)
        'thumbnail_remote_file_id': thumbnailRemoteFileId,
      if (remoteFileId != null) 'remote_file_id': remoteFileId,
      if (cloudFolderId != null) 'cloud_folder_id': cloudFolderId,
      if (metadataPath != null) 'metadata_path': metadataPath,
      if (lastSyncedAt != null) 'last_synced_at': lastSyncedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  ClipSourceRefsCompanion copyWith(
      {Value<int>? clipId,
      Value<String>? provider,
      Value<String>? ownerScope,
      Value<String>? ownerKey,
      Value<String>? remoteDocId,
      Value<String?>? storagePath,
      Value<String?>? downloadUrl,
      Value<String?>? thumbnailStoragePath,
      Value<String?>? thumbnailDownloadUrl,
      Value<String?>? thumbnailRemoteFileId,
      Value<String?>? remoteFileId,
      Value<String?>? cloudFolderId,
      Value<String?>? metadataPath,
      Value<DateTime?>? lastSyncedAt,
      Value<int>? rowid}) {
    return ClipSourceRefsCompanion(
      clipId: clipId ?? this.clipId,
      provider: provider ?? this.provider,
      ownerScope: ownerScope ?? this.ownerScope,
      ownerKey: ownerKey ?? this.ownerKey,
      remoteDocId: remoteDocId ?? this.remoteDocId,
      storagePath: storagePath ?? this.storagePath,
      downloadUrl: downloadUrl ?? this.downloadUrl,
      thumbnailStoragePath: thumbnailStoragePath ?? this.thumbnailStoragePath,
      thumbnailDownloadUrl: thumbnailDownloadUrl ?? this.thumbnailDownloadUrl,
      thumbnailRemoteFileId:
          thumbnailRemoteFileId ?? this.thumbnailRemoteFileId,
      remoteFileId: remoteFileId ?? this.remoteFileId,
      cloudFolderId: cloudFolderId ?? this.cloudFolderId,
      metadataPath: metadataPath ?? this.metadataPath,
      lastSyncedAt: lastSyncedAt ?? this.lastSyncedAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (clipId.present) {
      map['clip_id'] = Variable<int>(clipId.value);
    }
    if (provider.present) {
      map['provider'] = Variable<String>(provider.value);
    }
    if (ownerScope.present) {
      map['owner_scope'] = Variable<String>(ownerScope.value);
    }
    if (ownerKey.present) {
      map['owner_key'] = Variable<String>(ownerKey.value);
    }
    if (remoteDocId.present) {
      map['remote_doc_id'] = Variable<String>(remoteDocId.value);
    }
    if (storagePath.present) {
      map['storage_path'] = Variable<String>(storagePath.value);
    }
    if (downloadUrl.present) {
      map['download_url'] = Variable<String>(downloadUrl.value);
    }
    if (thumbnailStoragePath.present) {
      map['thumbnail_storage_path'] =
          Variable<String>(thumbnailStoragePath.value);
    }
    if (thumbnailDownloadUrl.present) {
      map['thumbnail_download_url'] =
          Variable<String>(thumbnailDownloadUrl.value);
    }
    if (thumbnailRemoteFileId.present) {
      map['thumbnail_remote_file_id'] =
          Variable<String>(thumbnailRemoteFileId.value);
    }
    if (remoteFileId.present) {
      map['remote_file_id'] = Variable<String>(remoteFileId.value);
    }
    if (cloudFolderId.present) {
      map['cloud_folder_id'] = Variable<String>(cloudFolderId.value);
    }
    if (metadataPath.present) {
      map['metadata_path'] = Variable<String>(metadataPath.value);
    }
    if (lastSyncedAt.present) {
      map['last_synced_at'] = Variable<DateTime>(lastSyncedAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('ClipSourceRefsCompanion(')
          ..write('clipId: $clipId, ')
          ..write('provider: $provider, ')
          ..write('ownerScope: $ownerScope, ')
          ..write('ownerKey: $ownerKey, ')
          ..write('remoteDocId: $remoteDocId, ')
          ..write('storagePath: $storagePath, ')
          ..write('downloadUrl: $downloadUrl, ')
          ..write('thumbnailStoragePath: $thumbnailStoragePath, ')
          ..write('thumbnailDownloadUrl: $thumbnailDownloadUrl, ')
          ..write('thumbnailRemoteFileId: $thumbnailRemoteFileId, ')
          ..write('remoteFileId: $remoteFileId, ')
          ..write('cloudFolderId: $cloudFolderId, ')
          ..write('metadataPath: $metadataPath, ')
          ..write('lastSyncedAt: $lastSyncedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $ClipCacheEntriesTable extends ClipCacheEntries
    with TableInfo<$ClipCacheEntriesTable, ClipCacheEntry> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $ClipCacheEntriesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _clipIdMeta = const VerificationMeta('clipId');
  @override
  late final GeneratedColumn<int> clipId = GeneratedColumn<int>(
      'clip_id', aliasedName, false,
      type: DriftSqlType.int,
      requiredDuringInsert: true,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('REFERENCES clips (id)'));
  static const VerificationMeta _providerMeta =
      const VerificationMeta('provider');
  @override
  late final GeneratedColumn<String> provider = GeneratedColumn<String>(
      'provider', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _ownerScopeMeta =
      const VerificationMeta('ownerScope');
  @override
  late final GeneratedColumn<String> ownerScope = GeneratedColumn<String>(
      'owner_scope', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _ownerKeyMeta =
      const VerificationMeta('ownerKey');
  @override
  late final GeneratedColumn<String> ownerKey = GeneratedColumn<String>(
      'owner_key', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _filePathMeta =
      const VerificationMeta('filePath');
  @override
  late final GeneratedColumn<String> filePath = GeneratedColumn<String>(
      'file_path', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _storageBytesMeta =
      const VerificationMeta('storageBytes');
  @override
  late final GeneratedColumn<int> storageBytes = GeneratedColumn<int>(
      'storage_bytes', aliasedName, false,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultValue: const Constant(0));
  static const VerificationMeta _cachedAtMeta =
      const VerificationMeta('cachedAt');
  @override
  late final GeneratedColumn<DateTime> cachedAt = GeneratedColumn<DateTime>(
      'cached_at', aliasedName, true,
      type: DriftSqlType.dateTime, requiredDuringInsert: false);
  static const VerificationMeta _lastAccessedAtMeta =
      const VerificationMeta('lastAccessedAt');
  @override
  late final GeneratedColumn<DateTime> lastAccessedAt =
      GeneratedColumn<DateTime>('last_accessed_at', aliasedName, true,
          type: DriftSqlType.dateTime, requiredDuringInsert: false);
  @override
  List<GeneratedColumn> get $columns => [
        clipId,
        provider,
        ownerScope,
        ownerKey,
        filePath,
        storageBytes,
        cachedAt,
        lastAccessedAt
      ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'clip_cache_entries';
  @override
  VerificationContext validateIntegrity(Insertable<ClipCacheEntry> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('clip_id')) {
      context.handle(_clipIdMeta,
          clipId.isAcceptableOrUnknown(data['clip_id']!, _clipIdMeta));
    } else if (isInserting) {
      context.missing(_clipIdMeta);
    }
    if (data.containsKey('provider')) {
      context.handle(_providerMeta,
          provider.isAcceptableOrUnknown(data['provider']!, _providerMeta));
    } else if (isInserting) {
      context.missing(_providerMeta);
    }
    if (data.containsKey('owner_scope')) {
      context.handle(
          _ownerScopeMeta,
          ownerScope.isAcceptableOrUnknown(
              data['owner_scope']!, _ownerScopeMeta));
    } else if (isInserting) {
      context.missing(_ownerScopeMeta);
    }
    if (data.containsKey('owner_key')) {
      context.handle(_ownerKeyMeta,
          ownerKey.isAcceptableOrUnknown(data['owner_key']!, _ownerKeyMeta));
    } else if (isInserting) {
      context.missing(_ownerKeyMeta);
    }
    if (data.containsKey('file_path')) {
      context.handle(_filePathMeta,
          filePath.isAcceptableOrUnknown(data['file_path']!, _filePathMeta));
    } else if (isInserting) {
      context.missing(_filePathMeta);
    }
    if (data.containsKey('storage_bytes')) {
      context.handle(
          _storageBytesMeta,
          storageBytes.isAcceptableOrUnknown(
              data['storage_bytes']!, _storageBytesMeta));
    }
    if (data.containsKey('cached_at')) {
      context.handle(_cachedAtMeta,
          cachedAt.isAcceptableOrUnknown(data['cached_at']!, _cachedAtMeta));
    }
    if (data.containsKey('last_accessed_at')) {
      context.handle(
          _lastAccessedAtMeta,
          lastAccessedAt.isAcceptableOrUnknown(
              data['last_accessed_at']!, _lastAccessedAtMeta));
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey =>
      {clipId, provider, ownerScope, ownerKey};
  @override
  ClipCacheEntry map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return ClipCacheEntry(
      clipId: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}clip_id'])!,
      provider: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}provider'])!,
      ownerScope: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}owner_scope'])!,
      ownerKey: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}owner_key'])!,
      filePath: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}file_path'])!,
      storageBytes: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}storage_bytes'])!,
      cachedAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}cached_at']),
      lastAccessedAt: attachedDatabase.typeMapping.read(
          DriftSqlType.dateTime, data['${effectivePrefix}last_accessed_at']),
    );
  }

  @override
  $ClipCacheEntriesTable createAlias(String alias) {
    return $ClipCacheEntriesTable(attachedDatabase, alias);
  }
}

class ClipCacheEntry extends DataClass implements Insertable<ClipCacheEntry> {
  final int clipId;
  final String provider;
  final String ownerScope;
  final String ownerKey;
  final String filePath;
  final int storageBytes;
  final DateTime? cachedAt;
  final DateTime? lastAccessedAt;
  const ClipCacheEntry(
      {required this.clipId,
      required this.provider,
      required this.ownerScope,
      required this.ownerKey,
      required this.filePath,
      required this.storageBytes,
      this.cachedAt,
      this.lastAccessedAt});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['clip_id'] = Variable<int>(clipId);
    map['provider'] = Variable<String>(provider);
    map['owner_scope'] = Variable<String>(ownerScope);
    map['owner_key'] = Variable<String>(ownerKey);
    map['file_path'] = Variable<String>(filePath);
    map['storage_bytes'] = Variable<int>(storageBytes);
    if (!nullToAbsent || cachedAt != null) {
      map['cached_at'] = Variable<DateTime>(cachedAt);
    }
    if (!nullToAbsent || lastAccessedAt != null) {
      map['last_accessed_at'] = Variable<DateTime>(lastAccessedAt);
    }
    return map;
  }

  ClipCacheEntriesCompanion toCompanion(bool nullToAbsent) {
    return ClipCacheEntriesCompanion(
      clipId: Value(clipId),
      provider: Value(provider),
      ownerScope: Value(ownerScope),
      ownerKey: Value(ownerKey),
      filePath: Value(filePath),
      storageBytes: Value(storageBytes),
      cachedAt: cachedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(cachedAt),
      lastAccessedAt: lastAccessedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(lastAccessedAt),
    );
  }

  factory ClipCacheEntry.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return ClipCacheEntry(
      clipId: serializer.fromJson<int>(json['clipId']),
      provider: serializer.fromJson<String>(json['provider']),
      ownerScope: serializer.fromJson<String>(json['ownerScope']),
      ownerKey: serializer.fromJson<String>(json['ownerKey']),
      filePath: serializer.fromJson<String>(json['filePath']),
      storageBytes: serializer.fromJson<int>(json['storageBytes']),
      cachedAt: serializer.fromJson<DateTime?>(json['cachedAt']),
      lastAccessedAt: serializer.fromJson<DateTime?>(json['lastAccessedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'clipId': serializer.toJson<int>(clipId),
      'provider': serializer.toJson<String>(provider),
      'ownerScope': serializer.toJson<String>(ownerScope),
      'ownerKey': serializer.toJson<String>(ownerKey),
      'filePath': serializer.toJson<String>(filePath),
      'storageBytes': serializer.toJson<int>(storageBytes),
      'cachedAt': serializer.toJson<DateTime?>(cachedAt),
      'lastAccessedAt': serializer.toJson<DateTime?>(lastAccessedAt),
    };
  }

  ClipCacheEntry copyWith(
          {int? clipId,
          String? provider,
          String? ownerScope,
          String? ownerKey,
          String? filePath,
          int? storageBytes,
          Value<DateTime?> cachedAt = const Value.absent(),
          Value<DateTime?> lastAccessedAt = const Value.absent()}) =>
      ClipCacheEntry(
        clipId: clipId ?? this.clipId,
        provider: provider ?? this.provider,
        ownerScope: ownerScope ?? this.ownerScope,
        ownerKey: ownerKey ?? this.ownerKey,
        filePath: filePath ?? this.filePath,
        storageBytes: storageBytes ?? this.storageBytes,
        cachedAt: cachedAt.present ? cachedAt.value : this.cachedAt,
        lastAccessedAt:
            lastAccessedAt.present ? lastAccessedAt.value : this.lastAccessedAt,
      );
  ClipCacheEntry copyWithCompanion(ClipCacheEntriesCompanion data) {
    return ClipCacheEntry(
      clipId: data.clipId.present ? data.clipId.value : this.clipId,
      provider: data.provider.present ? data.provider.value : this.provider,
      ownerScope:
          data.ownerScope.present ? data.ownerScope.value : this.ownerScope,
      ownerKey: data.ownerKey.present ? data.ownerKey.value : this.ownerKey,
      filePath: data.filePath.present ? data.filePath.value : this.filePath,
      storageBytes: data.storageBytes.present
          ? data.storageBytes.value
          : this.storageBytes,
      cachedAt: data.cachedAt.present ? data.cachedAt.value : this.cachedAt,
      lastAccessedAt: data.lastAccessedAt.present
          ? data.lastAccessedAt.value
          : this.lastAccessedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('ClipCacheEntry(')
          ..write('clipId: $clipId, ')
          ..write('provider: $provider, ')
          ..write('ownerScope: $ownerScope, ')
          ..write('ownerKey: $ownerKey, ')
          ..write('filePath: $filePath, ')
          ..write('storageBytes: $storageBytes, ')
          ..write('cachedAt: $cachedAt, ')
          ..write('lastAccessedAt: $lastAccessedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(clipId, provider, ownerScope, ownerKey,
      filePath, storageBytes, cachedAt, lastAccessedAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is ClipCacheEntry &&
          other.clipId == this.clipId &&
          other.provider == this.provider &&
          other.ownerScope == this.ownerScope &&
          other.ownerKey == this.ownerKey &&
          other.filePath == this.filePath &&
          other.storageBytes == this.storageBytes &&
          other.cachedAt == this.cachedAt &&
          other.lastAccessedAt == this.lastAccessedAt);
}

class ClipCacheEntriesCompanion extends UpdateCompanion<ClipCacheEntry> {
  final Value<int> clipId;
  final Value<String> provider;
  final Value<String> ownerScope;
  final Value<String> ownerKey;
  final Value<String> filePath;
  final Value<int> storageBytes;
  final Value<DateTime?> cachedAt;
  final Value<DateTime?> lastAccessedAt;
  final Value<int> rowid;
  const ClipCacheEntriesCompanion({
    this.clipId = const Value.absent(),
    this.provider = const Value.absent(),
    this.ownerScope = const Value.absent(),
    this.ownerKey = const Value.absent(),
    this.filePath = const Value.absent(),
    this.storageBytes = const Value.absent(),
    this.cachedAt = const Value.absent(),
    this.lastAccessedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  ClipCacheEntriesCompanion.insert({
    required int clipId,
    required String provider,
    required String ownerScope,
    required String ownerKey,
    required String filePath,
    this.storageBytes = const Value.absent(),
    this.cachedAt = const Value.absent(),
    this.lastAccessedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  })  : clipId = Value(clipId),
        provider = Value(provider),
        ownerScope = Value(ownerScope),
        ownerKey = Value(ownerKey),
        filePath = Value(filePath);
  static Insertable<ClipCacheEntry> custom({
    Expression<int>? clipId,
    Expression<String>? provider,
    Expression<String>? ownerScope,
    Expression<String>? ownerKey,
    Expression<String>? filePath,
    Expression<int>? storageBytes,
    Expression<DateTime>? cachedAt,
    Expression<DateTime>? lastAccessedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (clipId != null) 'clip_id': clipId,
      if (provider != null) 'provider': provider,
      if (ownerScope != null) 'owner_scope': ownerScope,
      if (ownerKey != null) 'owner_key': ownerKey,
      if (filePath != null) 'file_path': filePath,
      if (storageBytes != null) 'storage_bytes': storageBytes,
      if (cachedAt != null) 'cached_at': cachedAt,
      if (lastAccessedAt != null) 'last_accessed_at': lastAccessedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  ClipCacheEntriesCompanion copyWith(
      {Value<int>? clipId,
      Value<String>? provider,
      Value<String>? ownerScope,
      Value<String>? ownerKey,
      Value<String>? filePath,
      Value<int>? storageBytes,
      Value<DateTime?>? cachedAt,
      Value<DateTime?>? lastAccessedAt,
      Value<int>? rowid}) {
    return ClipCacheEntriesCompanion(
      clipId: clipId ?? this.clipId,
      provider: provider ?? this.provider,
      ownerScope: ownerScope ?? this.ownerScope,
      ownerKey: ownerKey ?? this.ownerKey,
      filePath: filePath ?? this.filePath,
      storageBytes: storageBytes ?? this.storageBytes,
      cachedAt: cachedAt ?? this.cachedAt,
      lastAccessedAt: lastAccessedAt ?? this.lastAccessedAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (clipId.present) {
      map['clip_id'] = Variable<int>(clipId.value);
    }
    if (provider.present) {
      map['provider'] = Variable<String>(provider.value);
    }
    if (ownerScope.present) {
      map['owner_scope'] = Variable<String>(ownerScope.value);
    }
    if (ownerKey.present) {
      map['owner_key'] = Variable<String>(ownerKey.value);
    }
    if (filePath.present) {
      map['file_path'] = Variable<String>(filePath.value);
    }
    if (storageBytes.present) {
      map['storage_bytes'] = Variable<int>(storageBytes.value);
    }
    if (cachedAt.present) {
      map['cached_at'] = Variable<DateTime>(cachedAt.value);
    }
    if (lastAccessedAt.present) {
      map['last_accessed_at'] = Variable<DateTime>(lastAccessedAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('ClipCacheEntriesCompanion(')
          ..write('clipId: $clipId, ')
          ..write('provider: $provider, ')
          ..write('ownerScope: $ownerScope, ')
          ..write('ownerKey: $ownerKey, ')
          ..write('filePath: $filePath, ')
          ..write('storageBytes: $storageBytes, ')
          ..write('cachedAt: $cachedAt, ')
          ..write('lastAccessedAt: $lastAccessedAt, ')
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
  late final $ClipSourceRefsTable clipSourceRefs = $ClipSourceRefsTable(this);
  late final $ClipCacheEntriesTable clipCacheEntries =
      $ClipCacheEntriesTable(this);
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
        groupCollections,
        clipSourceRefs,
        clipCacheEntries
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
  Value<String> storageMode,
});
typedef $$GroupsTableUpdateCompanionBuilder = GroupsCompanion Function({
  Value<int> id,
  Value<String> name,
  Value<String> storageMode,
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

  ColumnFilters<String> get storageMode => $composableBuilder(
      column: $table.storageMode, builder: (column) => ColumnFilters(column));

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

  ColumnOrderings<String> get storageMode => $composableBuilder(
      column: $table.storageMode, builder: (column) => ColumnOrderings(column));
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

  GeneratedColumn<String> get storageMode => $composableBuilder(
      column: $table.storageMode, builder: (column) => column);

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
            Value<String> storageMode = const Value.absent(),
          }) =>
              GroupsCompanion(
            id: id,
            name: name,
            storageMode: storageMode,
          ),
          createCompanionCallback: ({
            Value<int> id = const Value.absent(),
            required String name,
            Value<String> storageMode = const Value.absent(),
          }) =>
              GroupsCompanion.insert(
            id: id,
            name: name,
            storageMode: storageMode,
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
  Value<String> storageMode,
});
typedef $$CollectionsTableUpdateCompanionBuilder = CollectionsCompanion
    Function({
  Value<int> id,
  Value<String> name,
  Value<String> storageMode,
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

  ColumnFilters<String> get storageMode => $composableBuilder(
      column: $table.storageMode, builder: (column) => ColumnFilters(column));

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

  ColumnOrderings<String> get storageMode => $composableBuilder(
      column: $table.storageMode, builder: (column) => ColumnOrderings(column));
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

  GeneratedColumn<String> get storageMode => $composableBuilder(
      column: $table.storageMode, builder: (column) => column);

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
            Value<String> storageMode = const Value.absent(),
          }) =>
              CollectionsCompanion(
            id: id,
            name: name,
            storageMode: storageMode,
          ),
          createCompanionCallback: ({
            Value<int> id = const Value.absent(),
            required String name,
            Value<String> storageMode = const Value.absent(),
          }) =>
              CollectionsCompanion.insert(
            id: id,
            name: name,
            storageMode: storageMode,
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
  Value<String?> sourceFilePath,
  Value<String?> thumbnailFilePath,
  Value<String> ownerScope,
  Value<String?> ownerKey,
  Value<String> storageMode,
  Value<int> storageBytes,
  required int durationMs,
});
typedef $$ClipsTableUpdateCompanionBuilder = ClipsCompanion Function({
  Value<int> id,
  Value<int?> collectionId,
  Value<String> title,
  Value<String> filePath,
  Value<String?> sourceFilePath,
  Value<String?> thumbnailFilePath,
  Value<String> ownerScope,
  Value<String?> ownerKey,
  Value<String> storageMode,
  Value<int> storageBytes,
  Value<int> durationMs,
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

  static MultiTypedResultKey<$ClipSourceRefsTable, List<ClipSourceRef>>
      _clipSourceRefsRefsTable(_$AppDatabase db) =>
          MultiTypedResultKey.fromTable(db.clipSourceRefs,
              aliasName:
                  $_aliasNameGenerator(db.clips.id, db.clipSourceRefs.clipId));

  $$ClipSourceRefsTableProcessedTableManager get clipSourceRefsRefs {
    final manager = $$ClipSourceRefsTableTableManager($_db, $_db.clipSourceRefs)
        .filter((f) => f.clipId.id.sqlEquals($_itemColumn<int>('id')!));

    final cache = $_typedResult.readTableOrNull(_clipSourceRefsRefsTable($_db));
    return ProcessedTableManager(
        manager.$state.copyWith(prefetchedData: cache));
  }

  static MultiTypedResultKey<$ClipCacheEntriesTable, List<ClipCacheEntry>>
      _clipCacheEntriesRefsTable(_$AppDatabase db) =>
          MultiTypedResultKey.fromTable(db.clipCacheEntries,
              aliasName: $_aliasNameGenerator(
                  db.clips.id, db.clipCacheEntries.clipId));

  $$ClipCacheEntriesTableProcessedTableManager get clipCacheEntriesRefs {
    final manager =
        $$ClipCacheEntriesTableTableManager($_db, $_db.clipCacheEntries)
            .filter((f) => f.clipId.id.sqlEquals($_itemColumn<int>('id')!));

    final cache =
        $_typedResult.readTableOrNull(_clipCacheEntriesRefsTable($_db));
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

  ColumnFilters<String> get sourceFilePath => $composableBuilder(
      column: $table.sourceFilePath,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get thumbnailFilePath => $composableBuilder(
      column: $table.thumbnailFilePath,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get ownerScope => $composableBuilder(
      column: $table.ownerScope, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get ownerKey => $composableBuilder(
      column: $table.ownerKey, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get storageMode => $composableBuilder(
      column: $table.storageMode, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get storageBytes => $composableBuilder(
      column: $table.storageBytes, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get durationMs => $composableBuilder(
      column: $table.durationMs, builder: (column) => ColumnFilters(column));

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

  Expression<bool> clipSourceRefsRefs(
      Expression<bool> Function($$ClipSourceRefsTableFilterComposer f) f) {
    final $$ClipSourceRefsTableFilterComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.id,
        referencedTable: $db.clipSourceRefs,
        getReferencedColumn: (t) => t.clipId,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$ClipSourceRefsTableFilterComposer(
              $db: $db,
              $table: $db.clipSourceRefs,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return f(composer);
  }

  Expression<bool> clipCacheEntriesRefs(
      Expression<bool> Function($$ClipCacheEntriesTableFilterComposer f) f) {
    final $$ClipCacheEntriesTableFilterComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.id,
        referencedTable: $db.clipCacheEntries,
        getReferencedColumn: (t) => t.clipId,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$ClipCacheEntriesTableFilterComposer(
              $db: $db,
              $table: $db.clipCacheEntries,
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

  ColumnOrderings<String> get sourceFilePath => $composableBuilder(
      column: $table.sourceFilePath,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get thumbnailFilePath => $composableBuilder(
      column: $table.thumbnailFilePath,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get ownerScope => $composableBuilder(
      column: $table.ownerScope, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get ownerKey => $composableBuilder(
      column: $table.ownerKey, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get storageMode => $composableBuilder(
      column: $table.storageMode, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get storageBytes => $composableBuilder(
      column: $table.storageBytes,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get durationMs => $composableBuilder(
      column: $table.durationMs, builder: (column) => ColumnOrderings(column));

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

  GeneratedColumn<String> get sourceFilePath => $composableBuilder(
      column: $table.sourceFilePath, builder: (column) => column);

  GeneratedColumn<String> get thumbnailFilePath => $composableBuilder(
      column: $table.thumbnailFilePath, builder: (column) => column);

  GeneratedColumn<String> get ownerScope => $composableBuilder(
      column: $table.ownerScope, builder: (column) => column);

  GeneratedColumn<String> get ownerKey =>
      $composableBuilder(column: $table.ownerKey, builder: (column) => column);

  GeneratedColumn<String> get storageMode => $composableBuilder(
      column: $table.storageMode, builder: (column) => column);

  GeneratedColumn<int> get storageBytes => $composableBuilder(
      column: $table.storageBytes, builder: (column) => column);

  GeneratedColumn<int> get durationMs => $composableBuilder(
      column: $table.durationMs, builder: (column) => column);

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

  Expression<T> clipSourceRefsRefs<T extends Object>(
      Expression<T> Function($$ClipSourceRefsTableAnnotationComposer a) f) {
    final $$ClipSourceRefsTableAnnotationComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.id,
        referencedTable: $db.clipSourceRefs,
        getReferencedColumn: (t) => t.clipId,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$ClipSourceRefsTableAnnotationComposer(
              $db: $db,
              $table: $db.clipSourceRefs,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return f(composer);
  }

  Expression<T> clipCacheEntriesRefs<T extends Object>(
      Expression<T> Function($$ClipCacheEntriesTableAnnotationComposer a) f) {
    final $$ClipCacheEntriesTableAnnotationComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.id,
        referencedTable: $db.clipCacheEntries,
        getReferencedColumn: (t) => t.clipId,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$ClipCacheEntriesTableAnnotationComposer(
              $db: $db,
              $table: $db.clipCacheEntries,
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
        bool recentClipViewsRefs,
        bool clipSourceRefsRefs,
        bool clipCacheEntriesRefs})> {
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
            Value<String?> sourceFilePath = const Value.absent(),
            Value<String?> thumbnailFilePath = const Value.absent(),
            Value<String> ownerScope = const Value.absent(),
            Value<String?> ownerKey = const Value.absent(),
            Value<String> storageMode = const Value.absent(),
            Value<int> storageBytes = const Value.absent(),
            Value<int> durationMs = const Value.absent(),
          }) =>
              ClipsCompanion(
            id: id,
            collectionId: collectionId,
            title: title,
            filePath: filePath,
            sourceFilePath: sourceFilePath,
            thumbnailFilePath: thumbnailFilePath,
            ownerScope: ownerScope,
            ownerKey: ownerKey,
            storageMode: storageMode,
            storageBytes: storageBytes,
            durationMs: durationMs,
          ),
          createCompanionCallback: ({
            Value<int> id = const Value.absent(),
            Value<int?> collectionId = const Value.absent(),
            required String title,
            required String filePath,
            Value<String?> sourceFilePath = const Value.absent(),
            Value<String?> thumbnailFilePath = const Value.absent(),
            Value<String> ownerScope = const Value.absent(),
            Value<String?> ownerKey = const Value.absent(),
            Value<String> storageMode = const Value.absent(),
            Value<int> storageBytes = const Value.absent(),
            required int durationMs,
          }) =>
              ClipsCompanion.insert(
            id: id,
            collectionId: collectionId,
            title: title,
            filePath: filePath,
            sourceFilePath: sourceFilePath,
            thumbnailFilePath: thumbnailFilePath,
            ownerScope: ownerScope,
            ownerKey: ownerKey,
            storageMode: storageMode,
            storageBytes: storageBytes,
            durationMs: durationMs,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) =>
                  (e.readTable(table), $$ClipsTableReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: (
              {collectionId = false,
              segmentsRefs = false,
              clipTagsRefs = false,
              recentClipViewsRefs = false,
              clipSourceRefsRefs = false,
              clipCacheEntriesRefs = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [
                if (segmentsRefs) db.segments,
                if (clipTagsRefs) db.clipTags,
                if (recentClipViewsRefs) db.recentClipViews,
                if (clipSourceRefsRefs) db.clipSourceRefs,
                if (clipCacheEntriesRefs) db.clipCacheEntries
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
                        typedResults: items),
                  if (clipSourceRefsRefs)
                    await $_getPrefetchedData<Clip, $ClipsTable, ClipSourceRef>(
                        currentTable: table,
                        referencedTable:
                            $$ClipsTableReferences._clipSourceRefsRefsTable(db),
                        managerFromTypedResult: (p0) =>
                            $$ClipsTableReferences(db, table, p0)
                                .clipSourceRefsRefs,
                        referencedItemsForCurrentItem: (item,
                                referencedItems) =>
                            referencedItems.where((e) => e.clipId == item.id),
                        typedResults: items),
                  if (clipCacheEntriesRefs)
                    await $_getPrefetchedData<Clip, $ClipsTable,
                            ClipCacheEntry>(
                        currentTable: table,
                        referencedTable: $$ClipsTableReferences
                            ._clipCacheEntriesRefsTable(db),
                        managerFromTypedResult: (p0) =>
                            $$ClipsTableReferences(db, table, p0)
                                .clipCacheEntriesRefs,
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
        bool recentClipViewsRefs,
        bool clipSourceRefsRefs,
        bool clipCacheEntriesRefs})>;
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
typedef $$ClipSourceRefsTableCreateCompanionBuilder = ClipSourceRefsCompanion
    Function({
  required int clipId,
  required String provider,
  required String ownerScope,
  required String ownerKey,
  required String remoteDocId,
  Value<String?> storagePath,
  Value<String?> downloadUrl,
  Value<String?> thumbnailStoragePath,
  Value<String?> thumbnailDownloadUrl,
  Value<String?> thumbnailRemoteFileId,
  Value<String?> remoteFileId,
  Value<String?> cloudFolderId,
  Value<String?> metadataPath,
  Value<DateTime?> lastSyncedAt,
  Value<int> rowid,
});
typedef $$ClipSourceRefsTableUpdateCompanionBuilder = ClipSourceRefsCompanion
    Function({
  Value<int> clipId,
  Value<String> provider,
  Value<String> ownerScope,
  Value<String> ownerKey,
  Value<String> remoteDocId,
  Value<String?> storagePath,
  Value<String?> downloadUrl,
  Value<String?> thumbnailStoragePath,
  Value<String?> thumbnailDownloadUrl,
  Value<String?> thumbnailRemoteFileId,
  Value<String?> remoteFileId,
  Value<String?> cloudFolderId,
  Value<String?> metadataPath,
  Value<DateTime?> lastSyncedAt,
  Value<int> rowid,
});

final class $$ClipSourceRefsTableReferences
    extends BaseReferences<_$AppDatabase, $ClipSourceRefsTable, ClipSourceRef> {
  $$ClipSourceRefsTableReferences(
      super.$_db, super.$_table, super.$_typedResult);

  static $ClipsTable _clipIdTable(_$AppDatabase db) => db.clips
      .createAlias($_aliasNameGenerator(db.clipSourceRefs.clipId, db.clips.id));

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

class $$ClipSourceRefsTableFilterComposer
    extends Composer<_$AppDatabase, $ClipSourceRefsTable> {
  $$ClipSourceRefsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get provider => $composableBuilder(
      column: $table.provider, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get ownerScope => $composableBuilder(
      column: $table.ownerScope, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get ownerKey => $composableBuilder(
      column: $table.ownerKey, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get remoteDocId => $composableBuilder(
      column: $table.remoteDocId, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get storagePath => $composableBuilder(
      column: $table.storagePath, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get downloadUrl => $composableBuilder(
      column: $table.downloadUrl, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get thumbnailStoragePath => $composableBuilder(
      column: $table.thumbnailStoragePath,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get thumbnailDownloadUrl => $composableBuilder(
      column: $table.thumbnailDownloadUrl,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get thumbnailRemoteFileId => $composableBuilder(
      column: $table.thumbnailRemoteFileId,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get remoteFileId => $composableBuilder(
      column: $table.remoteFileId, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get cloudFolderId => $composableBuilder(
      column: $table.cloudFolderId, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get metadataPath => $composableBuilder(
      column: $table.metadataPath, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get lastSyncedAt => $composableBuilder(
      column: $table.lastSyncedAt, builder: (column) => ColumnFilters(column));

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

class $$ClipSourceRefsTableOrderingComposer
    extends Composer<_$AppDatabase, $ClipSourceRefsTable> {
  $$ClipSourceRefsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get provider => $composableBuilder(
      column: $table.provider, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get ownerScope => $composableBuilder(
      column: $table.ownerScope, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get ownerKey => $composableBuilder(
      column: $table.ownerKey, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get remoteDocId => $composableBuilder(
      column: $table.remoteDocId, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get storagePath => $composableBuilder(
      column: $table.storagePath, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get downloadUrl => $composableBuilder(
      column: $table.downloadUrl, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get thumbnailStoragePath => $composableBuilder(
      column: $table.thumbnailStoragePath,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get thumbnailDownloadUrl => $composableBuilder(
      column: $table.thumbnailDownloadUrl,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get thumbnailRemoteFileId => $composableBuilder(
      column: $table.thumbnailRemoteFileId,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get remoteFileId => $composableBuilder(
      column: $table.remoteFileId,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get cloudFolderId => $composableBuilder(
      column: $table.cloudFolderId,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get metadataPath => $composableBuilder(
      column: $table.metadataPath,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get lastSyncedAt => $composableBuilder(
      column: $table.lastSyncedAt,
      builder: (column) => ColumnOrderings(column));

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

class $$ClipSourceRefsTableAnnotationComposer
    extends Composer<_$AppDatabase, $ClipSourceRefsTable> {
  $$ClipSourceRefsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get provider =>
      $composableBuilder(column: $table.provider, builder: (column) => column);

  GeneratedColumn<String> get ownerScope => $composableBuilder(
      column: $table.ownerScope, builder: (column) => column);

  GeneratedColumn<String> get ownerKey =>
      $composableBuilder(column: $table.ownerKey, builder: (column) => column);

  GeneratedColumn<String> get remoteDocId => $composableBuilder(
      column: $table.remoteDocId, builder: (column) => column);

  GeneratedColumn<String> get storagePath => $composableBuilder(
      column: $table.storagePath, builder: (column) => column);

  GeneratedColumn<String> get downloadUrl => $composableBuilder(
      column: $table.downloadUrl, builder: (column) => column);

  GeneratedColumn<String> get thumbnailStoragePath => $composableBuilder(
      column: $table.thumbnailStoragePath, builder: (column) => column);

  GeneratedColumn<String> get thumbnailDownloadUrl => $composableBuilder(
      column: $table.thumbnailDownloadUrl, builder: (column) => column);

  GeneratedColumn<String> get thumbnailRemoteFileId => $composableBuilder(
      column: $table.thumbnailRemoteFileId, builder: (column) => column);

  GeneratedColumn<String> get remoteFileId => $composableBuilder(
      column: $table.remoteFileId, builder: (column) => column);

  GeneratedColumn<String> get cloudFolderId => $composableBuilder(
      column: $table.cloudFolderId, builder: (column) => column);

  GeneratedColumn<String> get metadataPath => $composableBuilder(
      column: $table.metadataPath, builder: (column) => column);

  GeneratedColumn<DateTime> get lastSyncedAt => $composableBuilder(
      column: $table.lastSyncedAt, builder: (column) => column);

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

class $$ClipSourceRefsTableTableManager extends RootTableManager<
    _$AppDatabase,
    $ClipSourceRefsTable,
    ClipSourceRef,
    $$ClipSourceRefsTableFilterComposer,
    $$ClipSourceRefsTableOrderingComposer,
    $$ClipSourceRefsTableAnnotationComposer,
    $$ClipSourceRefsTableCreateCompanionBuilder,
    $$ClipSourceRefsTableUpdateCompanionBuilder,
    (ClipSourceRef, $$ClipSourceRefsTableReferences),
    ClipSourceRef,
    PrefetchHooks Function({bool clipId})> {
  $$ClipSourceRefsTableTableManager(
      _$AppDatabase db, $ClipSourceRefsTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$ClipSourceRefsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$ClipSourceRefsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$ClipSourceRefsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<int> clipId = const Value.absent(),
            Value<String> provider = const Value.absent(),
            Value<String> ownerScope = const Value.absent(),
            Value<String> ownerKey = const Value.absent(),
            Value<String> remoteDocId = const Value.absent(),
            Value<String?> storagePath = const Value.absent(),
            Value<String?> downloadUrl = const Value.absent(),
            Value<String?> thumbnailStoragePath = const Value.absent(),
            Value<String?> thumbnailDownloadUrl = const Value.absent(),
            Value<String?> thumbnailRemoteFileId = const Value.absent(),
            Value<String?> remoteFileId = const Value.absent(),
            Value<String?> cloudFolderId = const Value.absent(),
            Value<String?> metadataPath = const Value.absent(),
            Value<DateTime?> lastSyncedAt = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              ClipSourceRefsCompanion(
            clipId: clipId,
            provider: provider,
            ownerScope: ownerScope,
            ownerKey: ownerKey,
            remoteDocId: remoteDocId,
            storagePath: storagePath,
            downloadUrl: downloadUrl,
            thumbnailStoragePath: thumbnailStoragePath,
            thumbnailDownloadUrl: thumbnailDownloadUrl,
            thumbnailRemoteFileId: thumbnailRemoteFileId,
            remoteFileId: remoteFileId,
            cloudFolderId: cloudFolderId,
            metadataPath: metadataPath,
            lastSyncedAt: lastSyncedAt,
            rowid: rowid,
          ),
          createCompanionCallback: ({
            required int clipId,
            required String provider,
            required String ownerScope,
            required String ownerKey,
            required String remoteDocId,
            Value<String?> storagePath = const Value.absent(),
            Value<String?> downloadUrl = const Value.absent(),
            Value<String?> thumbnailStoragePath = const Value.absent(),
            Value<String?> thumbnailDownloadUrl = const Value.absent(),
            Value<String?> thumbnailRemoteFileId = const Value.absent(),
            Value<String?> remoteFileId = const Value.absent(),
            Value<String?> cloudFolderId = const Value.absent(),
            Value<String?> metadataPath = const Value.absent(),
            Value<DateTime?> lastSyncedAt = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              ClipSourceRefsCompanion.insert(
            clipId: clipId,
            provider: provider,
            ownerScope: ownerScope,
            ownerKey: ownerKey,
            remoteDocId: remoteDocId,
            storagePath: storagePath,
            downloadUrl: downloadUrl,
            thumbnailStoragePath: thumbnailStoragePath,
            thumbnailDownloadUrl: thumbnailDownloadUrl,
            thumbnailRemoteFileId: thumbnailRemoteFileId,
            remoteFileId: remoteFileId,
            cloudFolderId: cloudFolderId,
            metadataPath: metadataPath,
            lastSyncedAt: lastSyncedAt,
            rowid: rowid,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (
                    e.readTable(table),
                    $$ClipSourceRefsTableReferences(db, table, e)
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
                        $$ClipSourceRefsTableReferences._clipIdTable(db),
                    referencedColumn:
                        $$ClipSourceRefsTableReferences._clipIdTable(db).id,
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

typedef $$ClipSourceRefsTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $ClipSourceRefsTable,
    ClipSourceRef,
    $$ClipSourceRefsTableFilterComposer,
    $$ClipSourceRefsTableOrderingComposer,
    $$ClipSourceRefsTableAnnotationComposer,
    $$ClipSourceRefsTableCreateCompanionBuilder,
    $$ClipSourceRefsTableUpdateCompanionBuilder,
    (ClipSourceRef, $$ClipSourceRefsTableReferences),
    ClipSourceRef,
    PrefetchHooks Function({bool clipId})>;
typedef $$ClipCacheEntriesTableCreateCompanionBuilder
    = ClipCacheEntriesCompanion Function({
  required int clipId,
  required String provider,
  required String ownerScope,
  required String ownerKey,
  required String filePath,
  Value<int> storageBytes,
  Value<DateTime?> cachedAt,
  Value<DateTime?> lastAccessedAt,
  Value<int> rowid,
});
typedef $$ClipCacheEntriesTableUpdateCompanionBuilder
    = ClipCacheEntriesCompanion Function({
  Value<int> clipId,
  Value<String> provider,
  Value<String> ownerScope,
  Value<String> ownerKey,
  Value<String> filePath,
  Value<int> storageBytes,
  Value<DateTime?> cachedAt,
  Value<DateTime?> lastAccessedAt,
  Value<int> rowid,
});

final class $$ClipCacheEntriesTableReferences extends BaseReferences<
    _$AppDatabase, $ClipCacheEntriesTable, ClipCacheEntry> {
  $$ClipCacheEntriesTableReferences(
      super.$_db, super.$_table, super.$_typedResult);

  static $ClipsTable _clipIdTable(_$AppDatabase db) => db.clips.createAlias(
      $_aliasNameGenerator(db.clipCacheEntries.clipId, db.clips.id));

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

class $$ClipCacheEntriesTableFilterComposer
    extends Composer<_$AppDatabase, $ClipCacheEntriesTable> {
  $$ClipCacheEntriesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get provider => $composableBuilder(
      column: $table.provider, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get ownerScope => $composableBuilder(
      column: $table.ownerScope, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get ownerKey => $composableBuilder(
      column: $table.ownerKey, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get filePath => $composableBuilder(
      column: $table.filePath, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get storageBytes => $composableBuilder(
      column: $table.storageBytes, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get cachedAt => $composableBuilder(
      column: $table.cachedAt, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get lastAccessedAt => $composableBuilder(
      column: $table.lastAccessedAt,
      builder: (column) => ColumnFilters(column));

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

class $$ClipCacheEntriesTableOrderingComposer
    extends Composer<_$AppDatabase, $ClipCacheEntriesTable> {
  $$ClipCacheEntriesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get provider => $composableBuilder(
      column: $table.provider, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get ownerScope => $composableBuilder(
      column: $table.ownerScope, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get ownerKey => $composableBuilder(
      column: $table.ownerKey, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get filePath => $composableBuilder(
      column: $table.filePath, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get storageBytes => $composableBuilder(
      column: $table.storageBytes,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get cachedAt => $composableBuilder(
      column: $table.cachedAt, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get lastAccessedAt => $composableBuilder(
      column: $table.lastAccessedAt,
      builder: (column) => ColumnOrderings(column));

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

class $$ClipCacheEntriesTableAnnotationComposer
    extends Composer<_$AppDatabase, $ClipCacheEntriesTable> {
  $$ClipCacheEntriesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get provider =>
      $composableBuilder(column: $table.provider, builder: (column) => column);

  GeneratedColumn<String> get ownerScope => $composableBuilder(
      column: $table.ownerScope, builder: (column) => column);

  GeneratedColumn<String> get ownerKey =>
      $composableBuilder(column: $table.ownerKey, builder: (column) => column);

  GeneratedColumn<String> get filePath =>
      $composableBuilder(column: $table.filePath, builder: (column) => column);

  GeneratedColumn<int> get storageBytes => $composableBuilder(
      column: $table.storageBytes, builder: (column) => column);

  GeneratedColumn<DateTime> get cachedAt =>
      $composableBuilder(column: $table.cachedAt, builder: (column) => column);

  GeneratedColumn<DateTime> get lastAccessedAt => $composableBuilder(
      column: $table.lastAccessedAt, builder: (column) => column);

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

class $$ClipCacheEntriesTableTableManager extends RootTableManager<
    _$AppDatabase,
    $ClipCacheEntriesTable,
    ClipCacheEntry,
    $$ClipCacheEntriesTableFilterComposer,
    $$ClipCacheEntriesTableOrderingComposer,
    $$ClipCacheEntriesTableAnnotationComposer,
    $$ClipCacheEntriesTableCreateCompanionBuilder,
    $$ClipCacheEntriesTableUpdateCompanionBuilder,
    (ClipCacheEntry, $$ClipCacheEntriesTableReferences),
    ClipCacheEntry,
    PrefetchHooks Function({bool clipId})> {
  $$ClipCacheEntriesTableTableManager(
      _$AppDatabase db, $ClipCacheEntriesTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$ClipCacheEntriesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$ClipCacheEntriesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$ClipCacheEntriesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<int> clipId = const Value.absent(),
            Value<String> provider = const Value.absent(),
            Value<String> ownerScope = const Value.absent(),
            Value<String> ownerKey = const Value.absent(),
            Value<String> filePath = const Value.absent(),
            Value<int> storageBytes = const Value.absent(),
            Value<DateTime?> cachedAt = const Value.absent(),
            Value<DateTime?> lastAccessedAt = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              ClipCacheEntriesCompanion(
            clipId: clipId,
            provider: provider,
            ownerScope: ownerScope,
            ownerKey: ownerKey,
            filePath: filePath,
            storageBytes: storageBytes,
            cachedAt: cachedAt,
            lastAccessedAt: lastAccessedAt,
            rowid: rowid,
          ),
          createCompanionCallback: ({
            required int clipId,
            required String provider,
            required String ownerScope,
            required String ownerKey,
            required String filePath,
            Value<int> storageBytes = const Value.absent(),
            Value<DateTime?> cachedAt = const Value.absent(),
            Value<DateTime?> lastAccessedAt = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              ClipCacheEntriesCompanion.insert(
            clipId: clipId,
            provider: provider,
            ownerScope: ownerScope,
            ownerKey: ownerKey,
            filePath: filePath,
            storageBytes: storageBytes,
            cachedAt: cachedAt,
            lastAccessedAt: lastAccessedAt,
            rowid: rowid,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (
                    e.readTable(table),
                    $$ClipCacheEntriesTableReferences(db, table, e)
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
                        $$ClipCacheEntriesTableReferences._clipIdTable(db),
                    referencedColumn:
                        $$ClipCacheEntriesTableReferences._clipIdTable(db).id,
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

typedef $$ClipCacheEntriesTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $ClipCacheEntriesTable,
    ClipCacheEntry,
    $$ClipCacheEntriesTableFilterComposer,
    $$ClipCacheEntriesTableOrderingComposer,
    $$ClipCacheEntriesTableAnnotationComposer,
    $$ClipCacheEntriesTableCreateCompanionBuilder,
    $$ClipCacheEntriesTableUpdateCompanionBuilder,
    (ClipCacheEntry, $$ClipCacheEntriesTableReferences),
    ClipCacheEntry,
    PrefetchHooks Function({bool clipId})>;

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
  $$ClipSourceRefsTableTableManager get clipSourceRefs =>
      $$ClipSourceRefsTableTableManager(_db, _db.clipSourceRefs);
  $$ClipCacheEntriesTableTableManager get clipCacheEntries =>
      $$ClipCacheEntriesTableTableManager(_db, _db.clipCacheEntries);
}
