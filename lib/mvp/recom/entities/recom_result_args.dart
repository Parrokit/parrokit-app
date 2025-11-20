import 'package:parrokit/mvp/recom/entities/anime_meta_data.dart';

class RecomResultArgs {
  final List<AnimeMetadata> results;
  final List<String> titles;
  final int topK;
  final double cutoff;
  final bool excludeWatched;

  RecomResultArgs({
    required this.results,
    required this.titles,
    required this.topK,
    required this.cutoff,
    required this.excludeWatched,
  });
}