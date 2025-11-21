import 'package:drift/drift.dart';
import 'package:parrokit/data/local/pa_database.dart';
import '../tables/titles.dart';
import '../tables/releases.dart';
import '../tables/episodes.dart';
import '../tables/clips.dart';

part 'titles_dao.g.dart';

@DriftAccessor(tables: [Titles, Releases, Episodes, Clips])
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

  /// 🔹 작품명(name)으로 찾아서, nameNative가 채워져 있으면 돌려주는 함수
  Future<String?> findNativeByName(String name) async {
    final query = select(titles)
      ..where((t) => t.name.equals(name))
      ..limit(1);

    final row = await query.getSingleOrNull();
    if (row == null) return null;

    final native = row.nameNative.trim();

    // 비어있거나, 기본값 '-'인 경우는 의미 없는 걸로 보고 null 처리
    if (native.isEmpty || native == '-') {
      return null;
    }

    return native;
  }

  /// 주어진 작품명(name)에 해당하는 시즌 번호 목록을 오름차순으로 반환
  Future<List<int>> fetchSeasonNumbersByTitleName(String titleName) async {
    final q = select(releases).join([
      innerJoin(
        titles,
        titles.id.equalsExp(releases.titleId),
      ),
    ])
      ..where(
        titles.name.equals(titleName) &
        releases.type.equals('season'),
      );

    final rows = await q.get();

    final seasonNumbers = rows
        .map((row) => row.readTable(releases).number)
        .whereType<int>() // null 제거
        .toSet()          // 중복 제거
        .toList()
      ..sort();

    return seasonNumbers;
  }

  /// 주어진 작품/시즌에 속한 회차 번호 목록을 오름차순으로 반환
  Future<List<int>> fetchEpisodeNumbers({
    required String titleName,
    required int seasonNumber,
  }) async {
    final q = select(episodes).join([
      innerJoin(
        releases,
        releases.id.equalsExp(episodes.releaseId),
      ),
      innerJoin(
        titles,
        titles.id.equalsExp(releases.titleId),
      ),
    ])
      ..where(
        titles.name.equals(titleName) &
        releases.type.equals('season') &
        releases.number.equals(seasonNumber),
      );

    final rows = await q.get();

    final episodeNumbers = rows
        .map((row) => row.readTable(episodes).number)
        .whereType<int>()
        .toSet()
        .toList()
      ..sort();

    return episodeNumbers;
  }

  /// 주어진 작품/시즌/화에 해당하는 에피소드 제목을 찾아 반환
  Future<String?> findEpisodeTitle({
    required String titleName,
    required int seasonNumber,
    required int episodeNumber,
  }) async {
    final q = select(episodes).join([
      innerJoin(
        releases,
        releases.id.equalsExp(episodes.releaseId),
      ),
      innerJoin(
        titles,
        titles.id.equalsExp(releases.titleId),
      ),
    ])
      ..where(
        titles.name.equals(titleName) &
        releases.type.equals('season') &
        releases.number.equals(seasonNumber) &
        episodes.number.equals(episodeNumber),
      )
      ..limit(1);

    final row = await q.getSingleOrNull();
    if (row == null) return null;

    return row.readTable(episodes).title;
  }

  /// 주어진 작품/시즌/화에 속한 클립 제목들을 모두 가져오기
  Future<List<String>> fetchClipTitles({
    required String titleName,
    required int seasonNumber,
    required int episodeNumber,
  }) async {
    // 먼저 해당 episode를 한 개 찾고
    final episodeQuery = select(episodes).join([
      innerJoin(
        releases,
        releases.id.equalsExp(episodes.releaseId),
      ),
      innerJoin(
        titles,
        titles.id.equalsExp(releases.titleId),
      ),
    ])
      ..where(
        titles.name.equals(titleName) &
        releases.type.equals('season') &
        releases.number.equals(seasonNumber) &
        episodes.number.equals(episodeNumber),
      )
      ..limit(1);

    final episodeRow = await episodeQuery.getSingleOrNull();
    if (episodeRow == null) return [];

    final episode = episodeRow.readTable(episodes);

    // 그 episodeId에 속한 클립 제목들 가져오기
    final clipRows = await (select(clips)
      ..where((c) => c.episodeId.equals(episode.id)))
        .get();

    return clipRows.map((c) => c.title).toList();
  }
}