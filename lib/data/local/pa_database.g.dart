// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'pa_database.dart';

// ignore_for_file: type=lint
class $TitlesTable extends Titles with TableInfo<$TitlesTable, Title> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $TitlesTable(this.attachedDatabase, [this._alias]);
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
  static const VerificationMeta _nameNativeMeta =
      const VerificationMeta('nameNative');
  @override
  late final GeneratedColumn<String> nameNative = GeneratedColumn<String>(
      'name_native', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  @override
  List<GeneratedColumn> get $columns => [id, name, nameNative];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'titles';
  @override
  VerificationContext validateIntegrity(Insertable<Title> instance,
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
    if (data.containsKey('name_native')) {
      context.handle(
          _nameNativeMeta,
          nameNative.isAcceptableOrUnknown(
              data['name_native']!, _nameNativeMeta));
    } else if (isInserting) {
      context.missing(_nameNativeMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Title map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Title(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}id'])!,
      name: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}name'])!,
      nameNative: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}name_native'])!,
    );
  }

  @override
  $TitlesTable createAlias(String alias) {
    return $TitlesTable(attachedDatabase, alias);
  }
}

class Title extends DataClass implements Insertable<Title> {
  final int id;
  final String name;
  final String nameNative;
  const Title({required this.id, required this.name, required this.nameNative});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['name'] = Variable<String>(name);
    map['name_native'] = Variable<String>(nameNative);
    return map;
  }

  TitlesCompanion toCompanion(bool nullToAbsent) {
    return TitlesCompanion(
      id: Value(id),
      name: Value(name),
      nameNative: Value(nameNative),
    );
  }

  factory Title.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Title(
      id: serializer.fromJson<int>(json['id']),
      name: serializer.fromJson<String>(json['name']),
      nameNative: serializer.fromJson<String>(json['nameNative']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'name': serializer.toJson<String>(name),
      'nameNative': serializer.toJson<String>(nameNative),
    };
  }

  Title copyWith({int? id, String? name, String? nameNative}) => Title(
        id: id ?? this.id,
        name: name ?? this.name,
        nameNative: nameNative ?? this.nameNative,
      );
  Title copyWithCompanion(TitlesCompanion data) {
    return Title(
      id: data.id.present ? data.id.value : this.id,
      name: data.name.present ? data.name.value : this.name,
      nameNative:
          data.nameNative.present ? data.nameNative.value : this.nameNative,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Title(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('nameNative: $nameNative')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, name, nameNative);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Title &&
          other.id == this.id &&
          other.name == this.name &&
          other.nameNative == this.nameNative);
}

class TitlesCompanion extends UpdateCompanion<Title> {
  final Value<int> id;
  final Value<String> name;
  final Value<String> nameNative;
  const TitlesCompanion({
    this.id = const Value.absent(),
    this.name = const Value.absent(),
    this.nameNative = const Value.absent(),
  });
  TitlesCompanion.insert({
    this.id = const Value.absent(),
    required String name,
    required String nameNative,
  })  : name = Value(name),
        nameNative = Value(nameNative);
  static Insertable<Title> custom({
    Expression<int>? id,
    Expression<String>? name,
    Expression<String>? nameNative,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (name != null) 'name': name,
      if (nameNative != null) 'name_native': nameNative,
    });
  }

  TitlesCompanion copyWith(
      {Value<int>? id, Value<String>? name, Value<String>? nameNative}) {
    return TitlesCompanion(
      id: id ?? this.id,
      name: name ?? this.name,
      nameNative: nameNative ?? this.nameNative,
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
    if (nameNative.present) {
      map['name_native'] = Variable<String>(nameNative.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('TitlesCompanion(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('nameNative: $nameNative')
          ..write(')'))
        .toString();
  }
}

class $ReleasesTable extends Releases with TableInfo<$ReleasesTable, Release> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $ReleasesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
      'id', aliasedName, false,
      hasAutoIncrement: true,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('PRIMARY KEY AUTOINCREMENT'));
  static const VerificationMeta _titleIdMeta =
      const VerificationMeta('titleId');
  @override
  late final GeneratedColumn<int> titleId = GeneratedColumn<int>(
      'title_id', aliasedName, false,
      type: DriftSqlType.int,
      requiredDuringInsert: true,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('REFERENCES titles (id)'));
  static const VerificationMeta _typeMeta = const VerificationMeta('type');
  @override
  late final GeneratedColumn<String> type = GeneratedColumn<String>(
      'type', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _numberMeta = const VerificationMeta('number');
  @override
  late final GeneratedColumn<int> number = GeneratedColumn<int>(
      'number', aliasedName, true,
      type: DriftSqlType.int, requiredDuringInsert: false);
  @override
  List<GeneratedColumn> get $columns => [id, titleId, type, number];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'releases';
  @override
  VerificationContext validateIntegrity(Insertable<Release> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('title_id')) {
      context.handle(_titleIdMeta,
          titleId.isAcceptableOrUnknown(data['title_id']!, _titleIdMeta));
    } else if (isInserting) {
      context.missing(_titleIdMeta);
    }
    if (data.containsKey('type')) {
      context.handle(
          _typeMeta, type.isAcceptableOrUnknown(data['type']!, _typeMeta));
    } else if (isInserting) {
      context.missing(_typeMeta);
    }
    if (data.containsKey('number')) {
      context.handle(_numberMeta,
          number.isAcceptableOrUnknown(data['number']!, _numberMeta));
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  List<Set<GeneratedColumn>> get uniqueKeys => [
        {titleId, type, number},
      ];
  @override
  Release map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Release(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}id'])!,
      titleId: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}title_id'])!,
      type: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}type'])!,
      number: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}number']),
    );
  }

  @override
  $ReleasesTable createAlias(String alias) {
    return $ReleasesTable(attachedDatabase, alias);
  }
}

class Release extends DataClass implements Insertable<Release> {
  final int id;
  final int titleId;
  final String type;
  final int? number;
  const Release(
      {required this.id,
      required this.titleId,
      required this.type,
      this.number});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['title_id'] = Variable<int>(titleId);
    map['type'] = Variable<String>(type);
    if (!nullToAbsent || number != null) {
      map['number'] = Variable<int>(number);
    }
    return map;
  }

  ReleasesCompanion toCompanion(bool nullToAbsent) {
    return ReleasesCompanion(
      id: Value(id),
      titleId: Value(titleId),
      type: Value(type),
      number:
          number == null && nullToAbsent ? const Value.absent() : Value(number),
    );
  }

  factory Release.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Release(
      id: serializer.fromJson<int>(json['id']),
      titleId: serializer.fromJson<int>(json['titleId']),
      type: serializer.fromJson<String>(json['type']),
      number: serializer.fromJson<int?>(json['number']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'titleId': serializer.toJson<int>(titleId),
      'type': serializer.toJson<String>(type),
      'number': serializer.toJson<int?>(number),
    };
  }

  Release copyWith(
          {int? id,
          int? titleId,
          String? type,
          Value<int?> number = const Value.absent()}) =>
      Release(
        id: id ?? this.id,
        titleId: titleId ?? this.titleId,
        type: type ?? this.type,
        number: number.present ? number.value : this.number,
      );
  Release copyWithCompanion(ReleasesCompanion data) {
    return Release(
      id: data.id.present ? data.id.value : this.id,
      titleId: data.titleId.present ? data.titleId.value : this.titleId,
      type: data.type.present ? data.type.value : this.type,
      number: data.number.present ? data.number.value : this.number,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Release(')
          ..write('id: $id, ')
          ..write('titleId: $titleId, ')
          ..write('type: $type, ')
          ..write('number: $number')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, titleId, type, number);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Release &&
          other.id == this.id &&
          other.titleId == this.titleId &&
          other.type == this.type &&
          other.number == this.number);
}

class ReleasesCompanion extends UpdateCompanion<Release> {
  final Value<int> id;
  final Value<int> titleId;
  final Value<String> type;
  final Value<int?> number;
  const ReleasesCompanion({
    this.id = const Value.absent(),
    this.titleId = const Value.absent(),
    this.type = const Value.absent(),
    this.number = const Value.absent(),
  });
  ReleasesCompanion.insert({
    this.id = const Value.absent(),
    required int titleId,
    required String type,
    this.number = const Value.absent(),
  })  : titleId = Value(titleId),
        type = Value(type);
  static Insertable<Release> custom({
    Expression<int>? id,
    Expression<int>? titleId,
    Expression<String>? type,
    Expression<int>? number,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (titleId != null) 'title_id': titleId,
      if (type != null) 'type': type,
      if (number != null) 'number': number,
    });
  }

  ReleasesCompanion copyWith(
      {Value<int>? id,
      Value<int>? titleId,
      Value<String>? type,
      Value<int?>? number}) {
    return ReleasesCompanion(
      id: id ?? this.id,
      titleId: titleId ?? this.titleId,
      type: type ?? this.type,
      number: number ?? this.number,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (titleId.present) {
      map['title_id'] = Variable<int>(titleId.value);
    }
    if (type.present) {
      map['type'] = Variable<String>(type.value);
    }
    if (number.present) {
      map['number'] = Variable<int>(number.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('ReleasesCompanion(')
          ..write('id: $id, ')
          ..write('titleId: $titleId, ')
          ..write('type: $type, ')
          ..write('number: $number')
          ..write(')'))
        .toString();
  }
}

class $EpisodesTable extends Episodes with TableInfo<$EpisodesTable, Episode> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $EpisodesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
      'id', aliasedName, false,
      hasAutoIncrement: true,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('PRIMARY KEY AUTOINCREMENT'));
  static const VerificationMeta _releaseIdMeta =
      const VerificationMeta('releaseId');
  @override
  late final GeneratedColumn<int> releaseId = GeneratedColumn<int>(
      'release_id', aliasedName, false,
      type: DriftSqlType.int,
      requiredDuringInsert: true,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('REFERENCES releases (id)'));
  static const VerificationMeta _numberMeta = const VerificationMeta('number');
  @override
  late final GeneratedColumn<int> number = GeneratedColumn<int>(
      'number', aliasedName, true,
      type: DriftSqlType.int, requiredDuringInsert: false);
  static const VerificationMeta _titleMeta = const VerificationMeta('title');
  @override
  late final GeneratedColumn<String> title = GeneratedColumn<String>(
      'title', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  @override
  List<GeneratedColumn> get $columns => [id, releaseId, number, title];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'episodes';
  @override
  VerificationContext validateIntegrity(Insertable<Episode> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('release_id')) {
      context.handle(_releaseIdMeta,
          releaseId.isAcceptableOrUnknown(data['release_id']!, _releaseIdMeta));
    } else if (isInserting) {
      context.missing(_releaseIdMeta);
    }
    if (data.containsKey('number')) {
      context.handle(_numberMeta,
          number.isAcceptableOrUnknown(data['number']!, _numberMeta));
    }
    if (data.containsKey('title')) {
      context.handle(
          _titleMeta, title.isAcceptableOrUnknown(data['title']!, _titleMeta));
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Episode map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Episode(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}id'])!,
      releaseId: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}release_id'])!,
      number: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}number']),
      title: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}title']),
    );
  }

  @override
  $EpisodesTable createAlias(String alias) {
    return $EpisodesTable(attachedDatabase, alias);
  }
}

class Episode extends DataClass implements Insertable<Episode> {
  final int id;
  final int releaseId;
  final int? number;
  final String? title;
  const Episode(
      {required this.id, required this.releaseId, this.number, this.title});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['release_id'] = Variable<int>(releaseId);
    if (!nullToAbsent || number != null) {
      map['number'] = Variable<int>(number);
    }
    if (!nullToAbsent || title != null) {
      map['title'] = Variable<String>(title);
    }
    return map;
  }

  EpisodesCompanion toCompanion(bool nullToAbsent) {
    return EpisodesCompanion(
      id: Value(id),
      releaseId: Value(releaseId),
      number:
          number == null && nullToAbsent ? const Value.absent() : Value(number),
      title:
          title == null && nullToAbsent ? const Value.absent() : Value(title),
    );
  }

  factory Episode.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Episode(
      id: serializer.fromJson<int>(json['id']),
      releaseId: serializer.fromJson<int>(json['releaseId']),
      number: serializer.fromJson<int?>(json['number']),
      title: serializer.fromJson<String?>(json['title']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'releaseId': serializer.toJson<int>(releaseId),
      'number': serializer.toJson<int?>(number),
      'title': serializer.toJson<String?>(title),
    };
  }

  Episode copyWith(
          {int? id,
          int? releaseId,
          Value<int?> number = const Value.absent(),
          Value<String?> title = const Value.absent()}) =>
      Episode(
        id: id ?? this.id,
        releaseId: releaseId ?? this.releaseId,
        number: number.present ? number.value : this.number,
        title: title.present ? title.value : this.title,
      );
  Episode copyWithCompanion(EpisodesCompanion data) {
    return Episode(
      id: data.id.present ? data.id.value : this.id,
      releaseId: data.releaseId.present ? data.releaseId.value : this.releaseId,
      number: data.number.present ? data.number.value : this.number,
      title: data.title.present ? data.title.value : this.title,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Episode(')
          ..write('id: $id, ')
          ..write('releaseId: $releaseId, ')
          ..write('number: $number, ')
          ..write('title: $title')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, releaseId, number, title);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Episode &&
          other.id == this.id &&
          other.releaseId == this.releaseId &&
          other.number == this.number &&
          other.title == this.title);
}

class EpisodesCompanion extends UpdateCompanion<Episode> {
  final Value<int> id;
  final Value<int> releaseId;
  final Value<int?> number;
  final Value<String?> title;
  const EpisodesCompanion({
    this.id = const Value.absent(),
    this.releaseId = const Value.absent(),
    this.number = const Value.absent(),
    this.title = const Value.absent(),
  });
  EpisodesCompanion.insert({
    this.id = const Value.absent(),
    required int releaseId,
    this.number = const Value.absent(),
    this.title = const Value.absent(),
  }) : releaseId = Value(releaseId);
  static Insertable<Episode> custom({
    Expression<int>? id,
    Expression<int>? releaseId,
    Expression<int>? number,
    Expression<String>? title,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (releaseId != null) 'release_id': releaseId,
      if (number != null) 'number': number,
      if (title != null) 'title': title,
    });
  }

  EpisodesCompanion copyWith(
      {Value<int>? id,
      Value<int>? releaseId,
      Value<int?>? number,
      Value<String?>? title}) {
    return EpisodesCompanion(
      id: id ?? this.id,
      releaseId: releaseId ?? this.releaseId,
      number: number ?? this.number,
      title: title ?? this.title,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (releaseId.present) {
      map['release_id'] = Variable<int>(releaseId.value);
    }
    if (number.present) {
      map['number'] = Variable<int>(number.value);
    }
    if (title.present) {
      map['title'] = Variable<String>(title.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('EpisodesCompanion(')
          ..write('id: $id, ')
          ..write('releaseId: $releaseId, ')
          ..write('number: $number, ')
          ..write('title: $title')
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
  static const VerificationMeta _episodeIdMeta =
      const VerificationMeta('episodeId');
  @override
  late final GeneratedColumn<int> episodeId = GeneratedColumn<int>(
      'episode_id', aliasedName, false,
      type: DriftSqlType.int,
      requiredDuringInsert: true,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('REFERENCES episodes (id)'));
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
  static const VerificationMeta _durationMsMeta =
      const VerificationMeta('durationMs');
  @override
  late final GeneratedColumn<int> durationMs = GeneratedColumn<int>(
      'duration_ms', aliasedName, false,
      type: DriftSqlType.int, requiredDuringInsert: true);
  @override
  List<GeneratedColumn> get $columns =>
      [id, episodeId, title, filePath, durationMs];
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
    if (data.containsKey('episode_id')) {
      context.handle(_episodeIdMeta,
          episodeId.isAcceptableOrUnknown(data['episode_id']!, _episodeIdMeta));
    } else if (isInserting) {
      context.missing(_episodeIdMeta);
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
      episodeId: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}episode_id'])!,
      title: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}title'])!,
      filePath: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}file_path'])!,
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
  final int episodeId;
  final String title;
  final String filePath;
  final int durationMs;
  const Clip(
      {required this.id,
      required this.episodeId,
      required this.title,
      required this.filePath,
      required this.durationMs});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['episode_id'] = Variable<int>(episodeId);
    map['title'] = Variable<String>(title);
    map['file_path'] = Variable<String>(filePath);
    map['duration_ms'] = Variable<int>(durationMs);
    return map;
  }

  ClipsCompanion toCompanion(bool nullToAbsent) {
    return ClipsCompanion(
      id: Value(id),
      episodeId: Value(episodeId),
      title: Value(title),
      filePath: Value(filePath),
      durationMs: Value(durationMs),
    );
  }

  factory Clip.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Clip(
      id: serializer.fromJson<int>(json['id']),
      episodeId: serializer.fromJson<int>(json['episodeId']),
      title: serializer.fromJson<String>(json['title']),
      filePath: serializer.fromJson<String>(json['filePath']),
      durationMs: serializer.fromJson<int>(json['durationMs']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'episodeId': serializer.toJson<int>(episodeId),
      'title': serializer.toJson<String>(title),
      'filePath': serializer.toJson<String>(filePath),
      'durationMs': serializer.toJson<int>(durationMs),
    };
  }

  Clip copyWith(
          {int? id,
          int? episodeId,
          String? title,
          String? filePath,
          int? durationMs}) =>
      Clip(
        id: id ?? this.id,
        episodeId: episodeId ?? this.episodeId,
        title: title ?? this.title,
        filePath: filePath ?? this.filePath,
        durationMs: durationMs ?? this.durationMs,
      );
  Clip copyWithCompanion(ClipsCompanion data) {
    return Clip(
      id: data.id.present ? data.id.value : this.id,
      episodeId: data.episodeId.present ? data.episodeId.value : this.episodeId,
      title: data.title.present ? data.title.value : this.title,
      filePath: data.filePath.present ? data.filePath.value : this.filePath,
      durationMs:
          data.durationMs.present ? data.durationMs.value : this.durationMs,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Clip(')
          ..write('id: $id, ')
          ..write('episodeId: $episodeId, ')
          ..write('title: $title, ')
          ..write('filePath: $filePath, ')
          ..write('durationMs: $durationMs')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, episodeId, title, filePath, durationMs);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Clip &&
          other.id == this.id &&
          other.episodeId == this.episodeId &&
          other.title == this.title &&
          other.filePath == this.filePath &&
          other.durationMs == this.durationMs);
}

class ClipsCompanion extends UpdateCompanion<Clip> {
  final Value<int> id;
  final Value<int> episodeId;
  final Value<String> title;
  final Value<String> filePath;
  final Value<int> durationMs;
  const ClipsCompanion({
    this.id = const Value.absent(),
    this.episodeId = const Value.absent(),
    this.title = const Value.absent(),
    this.filePath = const Value.absent(),
    this.durationMs = const Value.absent(),
  });
  ClipsCompanion.insert({
    this.id = const Value.absent(),
    required int episodeId,
    required String title,
    required String filePath,
    required int durationMs,
  })  : episodeId = Value(episodeId),
        title = Value(title),
        filePath = Value(filePath),
        durationMs = Value(durationMs);
  static Insertable<Clip> custom({
    Expression<int>? id,
    Expression<int>? episodeId,
    Expression<String>? title,
    Expression<String>? filePath,
    Expression<int>? durationMs,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (episodeId != null) 'episode_id': episodeId,
      if (title != null) 'title': title,
      if (filePath != null) 'file_path': filePath,
      if (durationMs != null) 'duration_ms': durationMs,
    });
  }

  ClipsCompanion copyWith(
      {Value<int>? id,
      Value<int>? episodeId,
      Value<String>? title,
      Value<String>? filePath,
      Value<int>? durationMs}) {
    return ClipsCompanion(
      id: id ?? this.id,
      episodeId: episodeId ?? this.episodeId,
      title: title ?? this.title,
      filePath: filePath ?? this.filePath,
      durationMs: durationMs ?? this.durationMs,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (episodeId.present) {
      map['episode_id'] = Variable<int>(episodeId.value);
    }
    if (title.present) {
      map['title'] = Variable<String>(title.value);
    }
    if (filePath.present) {
      map['file_path'] = Variable<String>(filePath.value);
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
          ..write('episodeId: $episodeId, ')
          ..write('title: $title, ')
          ..write('filePath: $filePath, ')
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

abstract class _$PaDatabase extends GeneratedDatabase {
  _$PaDatabase(QueryExecutor e) : super(e);
  $PaDatabaseManager get managers => $PaDatabaseManager(this);
  late final $TitlesTable titles = $TitlesTable(this);
  late final $ReleasesTable releases = $ReleasesTable(this);
  late final $EpisodesTable episodes = $EpisodesTable(this);
  late final $ClipsTable clips = $ClipsTable(this);
  late final $SegmentsTable segments = $SegmentsTable(this);
  late final $TagsTable tags = $TagsTable(this);
  late final $ClipTagsTable clipTags = $ClipTagsTable(this);
  late final $RecentClipViewsTable recentClipViews =
      $RecentClipViewsTable(this);
  late final TitlesDao titlesDao = TitlesDao(this as PaDatabase);
  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities => [
        titles,
        releases,
        episodes,
        clips,
        segments,
        tags,
        clipTags,
        recentClipViews
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

typedef $$TitlesTableCreateCompanionBuilder = TitlesCompanion Function({
  Value<int> id,
  required String name,
  required String nameNative,
});
typedef $$TitlesTableUpdateCompanionBuilder = TitlesCompanion Function({
  Value<int> id,
  Value<String> name,
  Value<String> nameNative,
});

final class $$TitlesTableReferences
    extends BaseReferences<_$PaDatabase, $TitlesTable, Title> {
  $$TitlesTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static MultiTypedResultKey<$ReleasesTable, List<Release>> _releasesRefsTable(
          _$PaDatabase db) =>
      MultiTypedResultKey.fromTable(db.releases,
          aliasName: $_aliasNameGenerator(db.titles.id, db.releases.titleId));

  $$ReleasesTableProcessedTableManager get releasesRefs {
    final manager = $$ReleasesTableTableManager($_db, $_db.releases)
        .filter((f) => f.titleId.id.sqlEquals($_itemColumn<int>('id')!));

    final cache = $_typedResult.readTableOrNull(_releasesRefsTable($_db));
    return ProcessedTableManager(
        manager.$state.copyWith(prefetchedData: cache));
  }
}

class $$TitlesTableFilterComposer extends Composer<_$PaDatabase, $TitlesTable> {
  $$TitlesTableFilterComposer({
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

  ColumnFilters<String> get nameNative => $composableBuilder(
      column: $table.nameNative, builder: (column) => ColumnFilters(column));

  Expression<bool> releasesRefs(
      Expression<bool> Function($$ReleasesTableFilterComposer f) f) {
    final $$ReleasesTableFilterComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.id,
        referencedTable: $db.releases,
        getReferencedColumn: (t) => t.titleId,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$ReleasesTableFilterComposer(
              $db: $db,
              $table: $db.releases,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return f(composer);
  }
}

class $$TitlesTableOrderingComposer
    extends Composer<_$PaDatabase, $TitlesTable> {
  $$TitlesTableOrderingComposer({
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

  ColumnOrderings<String> get nameNative => $composableBuilder(
      column: $table.nameNative, builder: (column) => ColumnOrderings(column));
}

class $$TitlesTableAnnotationComposer
    extends Composer<_$PaDatabase, $TitlesTable> {
  $$TitlesTableAnnotationComposer({
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

  GeneratedColumn<String> get nameNative => $composableBuilder(
      column: $table.nameNative, builder: (column) => column);

  Expression<T> releasesRefs<T extends Object>(
      Expression<T> Function($$ReleasesTableAnnotationComposer a) f) {
    final $$ReleasesTableAnnotationComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.id,
        referencedTable: $db.releases,
        getReferencedColumn: (t) => t.titleId,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$ReleasesTableAnnotationComposer(
              $db: $db,
              $table: $db.releases,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return f(composer);
  }
}

class $$TitlesTableTableManager extends RootTableManager<
    _$PaDatabase,
    $TitlesTable,
    Title,
    $$TitlesTableFilterComposer,
    $$TitlesTableOrderingComposer,
    $$TitlesTableAnnotationComposer,
    $$TitlesTableCreateCompanionBuilder,
    $$TitlesTableUpdateCompanionBuilder,
    (Title, $$TitlesTableReferences),
    Title,
    PrefetchHooks Function({bool releasesRefs})> {
  $$TitlesTableTableManager(_$PaDatabase db, $TitlesTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$TitlesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$TitlesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$TitlesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<int> id = const Value.absent(),
            Value<String> name = const Value.absent(),
            Value<String> nameNative = const Value.absent(),
          }) =>
              TitlesCompanion(
            id: id,
            name: name,
            nameNative: nameNative,
          ),
          createCompanionCallback: ({
            Value<int> id = const Value.absent(),
            required String name,
            required String nameNative,
          }) =>
              TitlesCompanion.insert(
            id: id,
            name: name,
            nameNative: nameNative,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) =>
                  (e.readTable(table), $$TitlesTableReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: ({releasesRefs = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [if (releasesRefs) db.releases],
              addJoins: null,
              getPrefetchedDataCallback: (items) async {
                return [
                  if (releasesRefs)
                    await $_getPrefetchedData<Title, $TitlesTable, Release>(
                        currentTable: table,
                        referencedTable:
                            $$TitlesTableReferences._releasesRefsTable(db),
                        managerFromTypedResult: (p0) =>
                            $$TitlesTableReferences(db, table, p0).releasesRefs,
                        referencedItemsForCurrentItem: (item,
                                referencedItems) =>
                            referencedItems.where((e) => e.titleId == item.id),
                        typedResults: items)
                ];
              },
            );
          },
        ));
}

typedef $$TitlesTableProcessedTableManager = ProcessedTableManager<
    _$PaDatabase,
    $TitlesTable,
    Title,
    $$TitlesTableFilterComposer,
    $$TitlesTableOrderingComposer,
    $$TitlesTableAnnotationComposer,
    $$TitlesTableCreateCompanionBuilder,
    $$TitlesTableUpdateCompanionBuilder,
    (Title, $$TitlesTableReferences),
    Title,
    PrefetchHooks Function({bool releasesRefs})>;
typedef $$ReleasesTableCreateCompanionBuilder = ReleasesCompanion Function({
  Value<int> id,
  required int titleId,
  required String type,
  Value<int?> number,
});
typedef $$ReleasesTableUpdateCompanionBuilder = ReleasesCompanion Function({
  Value<int> id,
  Value<int> titleId,
  Value<String> type,
  Value<int?> number,
});

final class $$ReleasesTableReferences
    extends BaseReferences<_$PaDatabase, $ReleasesTable, Release> {
  $$ReleasesTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static $TitlesTable _titleIdTable(_$PaDatabase db) => db.titles
      .createAlias($_aliasNameGenerator(db.releases.titleId, db.titles.id));

  $$TitlesTableProcessedTableManager get titleId {
    final $_column = $_itemColumn<int>('title_id')!;

    final manager = $$TitlesTableTableManager($_db, $_db.titles)
        .filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_titleIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
        manager.$state.copyWith(prefetchedData: [item]));
  }

  static MultiTypedResultKey<$EpisodesTable, List<Episode>> _episodesRefsTable(
          _$PaDatabase db) =>
      MultiTypedResultKey.fromTable(db.episodes,
          aliasName:
              $_aliasNameGenerator(db.releases.id, db.episodes.releaseId));

  $$EpisodesTableProcessedTableManager get episodesRefs {
    final manager = $$EpisodesTableTableManager($_db, $_db.episodes)
        .filter((f) => f.releaseId.id.sqlEquals($_itemColumn<int>('id')!));

    final cache = $_typedResult.readTableOrNull(_episodesRefsTable($_db));
    return ProcessedTableManager(
        manager.$state.copyWith(prefetchedData: cache));
  }
}

class $$ReleasesTableFilterComposer
    extends Composer<_$PaDatabase, $ReleasesTable> {
  $$ReleasesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get type => $composableBuilder(
      column: $table.type, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get number => $composableBuilder(
      column: $table.number, builder: (column) => ColumnFilters(column));

  $$TitlesTableFilterComposer get titleId {
    final $$TitlesTableFilterComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.titleId,
        referencedTable: $db.titles,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$TitlesTableFilterComposer(
              $db: $db,
              $table: $db.titles,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }

  Expression<bool> episodesRefs(
      Expression<bool> Function($$EpisodesTableFilterComposer f) f) {
    final $$EpisodesTableFilterComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.id,
        referencedTable: $db.episodes,
        getReferencedColumn: (t) => t.releaseId,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$EpisodesTableFilterComposer(
              $db: $db,
              $table: $db.episodes,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return f(composer);
  }
}

class $$ReleasesTableOrderingComposer
    extends Composer<_$PaDatabase, $ReleasesTable> {
  $$ReleasesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get type => $composableBuilder(
      column: $table.type, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get number => $composableBuilder(
      column: $table.number, builder: (column) => ColumnOrderings(column));

  $$TitlesTableOrderingComposer get titleId {
    final $$TitlesTableOrderingComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.titleId,
        referencedTable: $db.titles,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$TitlesTableOrderingComposer(
              $db: $db,
              $table: $db.titles,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }
}

class $$ReleasesTableAnnotationComposer
    extends Composer<_$PaDatabase, $ReleasesTable> {
  $$ReleasesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get type =>
      $composableBuilder(column: $table.type, builder: (column) => column);

  GeneratedColumn<int> get number =>
      $composableBuilder(column: $table.number, builder: (column) => column);

  $$TitlesTableAnnotationComposer get titleId {
    final $$TitlesTableAnnotationComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.titleId,
        referencedTable: $db.titles,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$TitlesTableAnnotationComposer(
              $db: $db,
              $table: $db.titles,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }

  Expression<T> episodesRefs<T extends Object>(
      Expression<T> Function($$EpisodesTableAnnotationComposer a) f) {
    final $$EpisodesTableAnnotationComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.id,
        referencedTable: $db.episodes,
        getReferencedColumn: (t) => t.releaseId,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$EpisodesTableAnnotationComposer(
              $db: $db,
              $table: $db.episodes,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return f(composer);
  }
}

class $$ReleasesTableTableManager extends RootTableManager<
    _$PaDatabase,
    $ReleasesTable,
    Release,
    $$ReleasesTableFilterComposer,
    $$ReleasesTableOrderingComposer,
    $$ReleasesTableAnnotationComposer,
    $$ReleasesTableCreateCompanionBuilder,
    $$ReleasesTableUpdateCompanionBuilder,
    (Release, $$ReleasesTableReferences),
    Release,
    PrefetchHooks Function({bool titleId, bool episodesRefs})> {
  $$ReleasesTableTableManager(_$PaDatabase db, $ReleasesTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$ReleasesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$ReleasesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$ReleasesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<int> id = const Value.absent(),
            Value<int> titleId = const Value.absent(),
            Value<String> type = const Value.absent(),
            Value<int?> number = const Value.absent(),
          }) =>
              ReleasesCompanion(
            id: id,
            titleId: titleId,
            type: type,
            number: number,
          ),
          createCompanionCallback: ({
            Value<int> id = const Value.absent(),
            required int titleId,
            required String type,
            Value<int?> number = const Value.absent(),
          }) =>
              ReleasesCompanion.insert(
            id: id,
            titleId: titleId,
            type: type,
            number: number,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) =>
                  (e.readTable(table), $$ReleasesTableReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: ({titleId = false, episodesRefs = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [if (episodesRefs) db.episodes],
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
                if (titleId) {
                  state = state.withJoin(
                    currentTable: table,
                    currentColumn: table.titleId,
                    referencedTable:
                        $$ReleasesTableReferences._titleIdTable(db),
                    referencedColumn:
                        $$ReleasesTableReferences._titleIdTable(db).id,
                  ) as T;
                }

                return state;
              },
              getPrefetchedDataCallback: (items) async {
                return [
                  if (episodesRefs)
                    await $_getPrefetchedData<Release, $ReleasesTable, Episode>(
                        currentTable: table,
                        referencedTable:
                            $$ReleasesTableReferences._episodesRefsTable(db),
                        managerFromTypedResult: (p0) =>
                            $$ReleasesTableReferences(db, table, p0)
                                .episodesRefs,
                        referencedItemsForCurrentItem:
                            (item, referencedItems) => referencedItems
                                .where((e) => e.releaseId == item.id),
                        typedResults: items)
                ];
              },
            );
          },
        ));
}

typedef $$ReleasesTableProcessedTableManager = ProcessedTableManager<
    _$PaDatabase,
    $ReleasesTable,
    Release,
    $$ReleasesTableFilterComposer,
    $$ReleasesTableOrderingComposer,
    $$ReleasesTableAnnotationComposer,
    $$ReleasesTableCreateCompanionBuilder,
    $$ReleasesTableUpdateCompanionBuilder,
    (Release, $$ReleasesTableReferences),
    Release,
    PrefetchHooks Function({bool titleId, bool episodesRefs})>;
typedef $$EpisodesTableCreateCompanionBuilder = EpisodesCompanion Function({
  Value<int> id,
  required int releaseId,
  Value<int?> number,
  Value<String?> title,
});
typedef $$EpisodesTableUpdateCompanionBuilder = EpisodesCompanion Function({
  Value<int> id,
  Value<int> releaseId,
  Value<int?> number,
  Value<String?> title,
});

final class $$EpisodesTableReferences
    extends BaseReferences<_$PaDatabase, $EpisodesTable, Episode> {
  $$EpisodesTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static $ReleasesTable _releaseIdTable(_$PaDatabase db) => db.releases
      .createAlias($_aliasNameGenerator(db.episodes.releaseId, db.releases.id));

  $$ReleasesTableProcessedTableManager get releaseId {
    final $_column = $_itemColumn<int>('release_id')!;

    final manager = $$ReleasesTableTableManager($_db, $_db.releases)
        .filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_releaseIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
        manager.$state.copyWith(prefetchedData: [item]));
  }

  static MultiTypedResultKey<$ClipsTable, List<Clip>> _clipsRefsTable(
          _$PaDatabase db) =>
      MultiTypedResultKey.fromTable(db.clips,
          aliasName: $_aliasNameGenerator(db.episodes.id, db.clips.episodeId));

  $$ClipsTableProcessedTableManager get clipsRefs {
    final manager = $$ClipsTableTableManager($_db, $_db.clips)
        .filter((f) => f.episodeId.id.sqlEquals($_itemColumn<int>('id')!));

    final cache = $_typedResult.readTableOrNull(_clipsRefsTable($_db));
    return ProcessedTableManager(
        manager.$state.copyWith(prefetchedData: cache));
  }
}

class $$EpisodesTableFilterComposer
    extends Composer<_$PaDatabase, $EpisodesTable> {
  $$EpisodesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get number => $composableBuilder(
      column: $table.number, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get title => $composableBuilder(
      column: $table.title, builder: (column) => ColumnFilters(column));

  $$ReleasesTableFilterComposer get releaseId {
    final $$ReleasesTableFilterComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.releaseId,
        referencedTable: $db.releases,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$ReleasesTableFilterComposer(
              $db: $db,
              $table: $db.releases,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }

  Expression<bool> clipsRefs(
      Expression<bool> Function($$ClipsTableFilterComposer f) f) {
    final $$ClipsTableFilterComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.id,
        referencedTable: $db.clips,
        getReferencedColumn: (t) => t.episodeId,
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
}

class $$EpisodesTableOrderingComposer
    extends Composer<_$PaDatabase, $EpisodesTable> {
  $$EpisodesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get number => $composableBuilder(
      column: $table.number, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get title => $composableBuilder(
      column: $table.title, builder: (column) => ColumnOrderings(column));

  $$ReleasesTableOrderingComposer get releaseId {
    final $$ReleasesTableOrderingComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.releaseId,
        referencedTable: $db.releases,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$ReleasesTableOrderingComposer(
              $db: $db,
              $table: $db.releases,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }
}

class $$EpisodesTableAnnotationComposer
    extends Composer<_$PaDatabase, $EpisodesTable> {
  $$EpisodesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<int> get number =>
      $composableBuilder(column: $table.number, builder: (column) => column);

  GeneratedColumn<String> get title =>
      $composableBuilder(column: $table.title, builder: (column) => column);

  $$ReleasesTableAnnotationComposer get releaseId {
    final $$ReleasesTableAnnotationComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.releaseId,
        referencedTable: $db.releases,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$ReleasesTableAnnotationComposer(
              $db: $db,
              $table: $db.releases,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }

  Expression<T> clipsRefs<T extends Object>(
      Expression<T> Function($$ClipsTableAnnotationComposer a) f) {
    final $$ClipsTableAnnotationComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.id,
        referencedTable: $db.clips,
        getReferencedColumn: (t) => t.episodeId,
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
}

class $$EpisodesTableTableManager extends RootTableManager<
    _$PaDatabase,
    $EpisodesTable,
    Episode,
    $$EpisodesTableFilterComposer,
    $$EpisodesTableOrderingComposer,
    $$EpisodesTableAnnotationComposer,
    $$EpisodesTableCreateCompanionBuilder,
    $$EpisodesTableUpdateCompanionBuilder,
    (Episode, $$EpisodesTableReferences),
    Episode,
    PrefetchHooks Function({bool releaseId, bool clipsRefs})> {
  $$EpisodesTableTableManager(_$PaDatabase db, $EpisodesTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$EpisodesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$EpisodesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$EpisodesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<int> id = const Value.absent(),
            Value<int> releaseId = const Value.absent(),
            Value<int?> number = const Value.absent(),
            Value<String?> title = const Value.absent(),
          }) =>
              EpisodesCompanion(
            id: id,
            releaseId: releaseId,
            number: number,
            title: title,
          ),
          createCompanionCallback: ({
            Value<int> id = const Value.absent(),
            required int releaseId,
            Value<int?> number = const Value.absent(),
            Value<String?> title = const Value.absent(),
          }) =>
              EpisodesCompanion.insert(
            id: id,
            releaseId: releaseId,
            number: number,
            title: title,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) =>
                  (e.readTable(table), $$EpisodesTableReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: ({releaseId = false, clipsRefs = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [if (clipsRefs) db.clips],
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
                if (releaseId) {
                  state = state.withJoin(
                    currentTable: table,
                    currentColumn: table.releaseId,
                    referencedTable:
                        $$EpisodesTableReferences._releaseIdTable(db),
                    referencedColumn:
                        $$EpisodesTableReferences._releaseIdTable(db).id,
                  ) as T;
                }

                return state;
              },
              getPrefetchedDataCallback: (items) async {
                return [
                  if (clipsRefs)
                    await $_getPrefetchedData<Episode, $EpisodesTable, Clip>(
                        currentTable: table,
                        referencedTable:
                            $$EpisodesTableReferences._clipsRefsTable(db),
                        managerFromTypedResult: (p0) =>
                            $$EpisodesTableReferences(db, table, p0).clipsRefs,
                        referencedItemsForCurrentItem:
                            (item, referencedItems) => referencedItems
                                .where((e) => e.episodeId == item.id),
                        typedResults: items)
                ];
              },
            );
          },
        ));
}

typedef $$EpisodesTableProcessedTableManager = ProcessedTableManager<
    _$PaDatabase,
    $EpisodesTable,
    Episode,
    $$EpisodesTableFilterComposer,
    $$EpisodesTableOrderingComposer,
    $$EpisodesTableAnnotationComposer,
    $$EpisodesTableCreateCompanionBuilder,
    $$EpisodesTableUpdateCompanionBuilder,
    (Episode, $$EpisodesTableReferences),
    Episode,
    PrefetchHooks Function({bool releaseId, bool clipsRefs})>;
typedef $$ClipsTableCreateCompanionBuilder = ClipsCompanion Function({
  Value<int> id,
  required int episodeId,
  required String title,
  required String filePath,
  required int durationMs,
});
typedef $$ClipsTableUpdateCompanionBuilder = ClipsCompanion Function({
  Value<int> id,
  Value<int> episodeId,
  Value<String> title,
  Value<String> filePath,
  Value<int> durationMs,
});

final class $$ClipsTableReferences
    extends BaseReferences<_$PaDatabase, $ClipsTable, Clip> {
  $$ClipsTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static $EpisodesTable _episodeIdTable(_$PaDatabase db) => db.episodes
      .createAlias($_aliasNameGenerator(db.clips.episodeId, db.episodes.id));

  $$EpisodesTableProcessedTableManager get episodeId {
    final $_column = $_itemColumn<int>('episode_id')!;

    final manager = $$EpisodesTableTableManager($_db, $_db.episodes)
        .filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_episodeIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
        manager.$state.copyWith(prefetchedData: [item]));
  }

  static MultiTypedResultKey<$SegmentsTable, List<Segment>> _segmentsRefsTable(
          _$PaDatabase db) =>
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
          _$PaDatabase db) =>
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
      _recentClipViewsRefsTable(_$PaDatabase db) =>
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

class $$ClipsTableFilterComposer extends Composer<_$PaDatabase, $ClipsTable> {
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

  ColumnFilters<int> get durationMs => $composableBuilder(
      column: $table.durationMs, builder: (column) => ColumnFilters(column));

  $$EpisodesTableFilterComposer get episodeId {
    final $$EpisodesTableFilterComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.episodeId,
        referencedTable: $db.episodes,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$EpisodesTableFilterComposer(
              $db: $db,
              $table: $db.episodes,
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

class $$ClipsTableOrderingComposer extends Composer<_$PaDatabase, $ClipsTable> {
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

  ColumnOrderings<int> get durationMs => $composableBuilder(
      column: $table.durationMs, builder: (column) => ColumnOrderings(column));

  $$EpisodesTableOrderingComposer get episodeId {
    final $$EpisodesTableOrderingComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.episodeId,
        referencedTable: $db.episodes,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$EpisodesTableOrderingComposer(
              $db: $db,
              $table: $db.episodes,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }
}

class $$ClipsTableAnnotationComposer
    extends Composer<_$PaDatabase, $ClipsTable> {
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

  GeneratedColumn<int> get durationMs => $composableBuilder(
      column: $table.durationMs, builder: (column) => column);

  $$EpisodesTableAnnotationComposer get episodeId {
    final $$EpisodesTableAnnotationComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.episodeId,
        referencedTable: $db.episodes,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$EpisodesTableAnnotationComposer(
              $db: $db,
              $table: $db.episodes,
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
    _$PaDatabase,
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
        {bool episodeId,
        bool segmentsRefs,
        bool clipTagsRefs,
        bool recentClipViewsRefs})> {
  $$ClipsTableTableManager(_$PaDatabase db, $ClipsTable table)
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
            Value<int> episodeId = const Value.absent(),
            Value<String> title = const Value.absent(),
            Value<String> filePath = const Value.absent(),
            Value<int> durationMs = const Value.absent(),
          }) =>
              ClipsCompanion(
            id: id,
            episodeId: episodeId,
            title: title,
            filePath: filePath,
            durationMs: durationMs,
          ),
          createCompanionCallback: ({
            Value<int> id = const Value.absent(),
            required int episodeId,
            required String title,
            required String filePath,
            required int durationMs,
          }) =>
              ClipsCompanion.insert(
            id: id,
            episodeId: episodeId,
            title: title,
            filePath: filePath,
            durationMs: durationMs,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) =>
                  (e.readTable(table), $$ClipsTableReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: (
              {episodeId = false,
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
                if (episodeId) {
                  state = state.withJoin(
                    currentTable: table,
                    currentColumn: table.episodeId,
                    referencedTable: $$ClipsTableReferences._episodeIdTable(db),
                    referencedColumn:
                        $$ClipsTableReferences._episodeIdTable(db).id,
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
    _$PaDatabase,
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
        {bool episodeId,
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
    extends BaseReferences<_$PaDatabase, $SegmentsTable, Segment> {
  $$SegmentsTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static $ClipsTable _clipIdTable(_$PaDatabase db) => db.clips
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
    extends Composer<_$PaDatabase, $SegmentsTable> {
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
    extends Composer<_$PaDatabase, $SegmentsTable> {
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
    extends Composer<_$PaDatabase, $SegmentsTable> {
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
    _$PaDatabase,
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
  $$SegmentsTableTableManager(_$PaDatabase db, $SegmentsTable table)
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
    _$PaDatabase,
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
    extends BaseReferences<_$PaDatabase, $TagsTable, Tag> {
  $$TagsTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static MultiTypedResultKey<$ClipTagsTable, List<ClipTag>> _clipTagsRefsTable(
          _$PaDatabase db) =>
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

class $$TagsTableFilterComposer extends Composer<_$PaDatabase, $TagsTable> {
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

class $$TagsTableOrderingComposer extends Composer<_$PaDatabase, $TagsTable> {
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

class $$TagsTableAnnotationComposer extends Composer<_$PaDatabase, $TagsTable> {
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
    _$PaDatabase,
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
  $$TagsTableTableManager(_$PaDatabase db, $TagsTable table)
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
    _$PaDatabase,
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
    extends BaseReferences<_$PaDatabase, $ClipTagsTable, ClipTag> {
  $$ClipTagsTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static $ClipsTable _clipIdTable(_$PaDatabase db) => db.clips
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

  static $TagsTable _tagIdTable(_$PaDatabase db) =>
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
    extends Composer<_$PaDatabase, $ClipTagsTable> {
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
    extends Composer<_$PaDatabase, $ClipTagsTable> {
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
    extends Composer<_$PaDatabase, $ClipTagsTable> {
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
    _$PaDatabase,
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
  $$ClipTagsTableTableManager(_$PaDatabase db, $ClipTagsTable table)
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
    _$PaDatabase,
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
    _$PaDatabase, $RecentClipViewsTable, RecentClipView> {
  $$RecentClipViewsTableReferences(
      super.$_db, super.$_table, super.$_typedResult);

  static $ClipsTable _clipIdTable(_$PaDatabase db) => db.clips.createAlias(
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
    extends Composer<_$PaDatabase, $RecentClipViewsTable> {
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
    extends Composer<_$PaDatabase, $RecentClipViewsTable> {
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
    extends Composer<_$PaDatabase, $RecentClipViewsTable> {
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
    _$PaDatabase,
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
      _$PaDatabase db, $RecentClipViewsTable table)
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
    _$PaDatabase,
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

class $PaDatabaseManager {
  final _$PaDatabase _db;
  $PaDatabaseManager(this._db);
  $$TitlesTableTableManager get titles =>
      $$TitlesTableTableManager(_db, _db.titles);
  $$ReleasesTableTableManager get releases =>
      $$ReleasesTableTableManager(_db, _db.releases);
  $$EpisodesTableTableManager get episodes =>
      $$EpisodesTableTableManager(_db, _db.episodes);
  $$ClipsTableTableManager get clips =>
      $$ClipsTableTableManager(_db, _db.clips);
  $$SegmentsTableTableManager get segments =>
      $$SegmentsTableTableManager(_db, _db.segments);
  $$TagsTableTableManager get tags => $$TagsTableTableManager(_db, _db.tags);
  $$ClipTagsTableTableManager get clipTags =>
      $$ClipTagsTableTableManager(_db, _db.clipTags);
  $$RecentClipViewsTableTableManager get recentClipViews =>
      $$RecentClipViewsTableTableManager(_db, _db.recentClipViews);
}
