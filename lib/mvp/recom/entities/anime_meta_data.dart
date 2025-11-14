/// Representation of an anime recommendation item.
class AnimeMetadata {
  final int animeId;
  final String nameKo;
  final String synopsisKo;
  final String imageUrl;
  final String type;
  final String genres;
  final double score;

  AnimeMetadata({
    required this.animeId,
    required this.nameKo,
    required this.synopsisKo,
    required this.imageUrl,
    required this.type,
    required this.genres,
    required this.score,
  });

  factory AnimeMetadata.fromJson(Map<String, dynamic> json) {
    return AnimeMetadata(
      animeId: json['anime_id'] as int,
      nameKo: (json['name_ko'] ?? json['name_jp'] ?? '') as String,
      synopsisKo: (json['synopsis_ko'] ?? json['synopsis_jp'] ?? '') as String,
      imageUrl: json['image_url'] as String,
      type: json['type'] as String? ?? '',
      genres: json['genres'] as String? ?? '',
      score: json['score'] is double
          ? json['score'] as double
          : double.tryParse(json['score']?.toString() ?? '') ?? 0.0,
    );
  }
  // factory AnimeMetadata.fromJson(Map<String, dynamic> json) {
  //   return AnimeMetadata(
  //     animeId: json['anime_id'] as int,
  //     nameKo: (json['name_jp'] ?? json['name_jp'] ?? '') as String,
  //     synopsisKo: (json['synopsis_jp'] ?? json['synopsis_jp'] ?? '') as String,
  //     imageUrl: json['image_url'] as String,
  //     type: json['type'] as String? ?? '',
  //     genres: json['genres'] as String? ?? '',
  //     score: json['score'] is double
  //         ? json['score'] as double
  //         : double.tryParse(json['score']?.toString() ?? '') ?? 0.0,
  //   );
  // }
}
