import 'dart:ffi';

import 'package:drift/drift.dart';
import 'titles.dart';

class Releases extends Table {
  IntColumn get id => integer().autoIncrement()();
  IntColumn get titleId => integer().references(Titles, #id)();
  TextColumn get type => text()(); // 'season', 'movie'
  IntColumn get number => integer().nullable()(); // 몇 기 (시즌일 경우)

  @override
  List<Set<Column>> get uniqueKeys => [
    { titleId, type, number }, // 같은 (titleId, type, number) 조합은 유일
  ];
}
