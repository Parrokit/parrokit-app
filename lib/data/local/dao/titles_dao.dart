import 'package:drift/drift.dart';
import 'package:parrokit/data/local/pa_database.dart';
import '../tables/titles.dart';

part 'titles_dao.g.dart';

@DriftAccessor(tables: [Titles])
class TitlesDao extends DatabaseAccessor<PaDatabase> with _$TitlesDaoMixin {
  TitlesDao(PaDatabase db) : super(db);

  /// name만 쭉 가져오기 (필터/정렬 포함)
  Future<List<String>> fetchAllTitleNames() async {
    final rows = await (select(titles)
      ..orderBy([(t) => OrderingTerm.asc(t.name)]))
        .get();

    return rows.map((e) => e.name).toList();
  }

  /// 전체 row 필요할 때 (id, name, nameNative 다 보고 싶을 때)
  Future<List<Title>> fetchAllRows() => select(titles).get();
}