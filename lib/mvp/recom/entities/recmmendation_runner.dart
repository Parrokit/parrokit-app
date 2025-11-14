import 'package:parrokit/mvp/recom/entities/anime_meta_data.dart';

/// Alias for the recommendation runner used in the progress sheet.
typedef RecommendationRunner = Future<List<AnimeMetadata>> Function();
