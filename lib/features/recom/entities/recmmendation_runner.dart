import 'package:parrokit/features/recom/entities/anime_meta_data.dart';

typedef RecommendationProgressCallback = void Function(
    String status,
    double progress,
    );

typedef RecommendationRunner = Future<List<AnimeMetadata>> Function(
    RecommendationProgressCallback onProgress,
    );