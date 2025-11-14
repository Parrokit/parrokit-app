import 'dart:convert';

import 'package:parrokit/mvp/recom/entities/anime_meta_data.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;


/// Service that communicates with the external recommendation server.
class RecommendationService {
  final String _baseUrl = dotenv.env['RECOMMEND_SERVER_ADDRESS'] ?? '';

  Future<List<AnimeMetadata>> fetchRecommendations({
    required List<String> titles,
    required int topK,
    required double cutoff,
    bool excludeWatched = true,
  }) async {
    final uri =
        Uri.parse(_baseUrl.startsWith('http') ? _baseUrl : 'http://$_baseUrl');
    final body = jsonEncode({
      'titles': titles,
      'top_k': topK,
      'cutoff': cutoff,
      'exclude_watched': excludeWatched,
    });
    final response = await http.post(
      uri,
      headers: {'Content-Type': 'application/json'},
      body: body,
    );
    if (response.statusCode != 200) {
      throw Exception('Server responded with ${response.statusCode}');
    }
    final Map<String, dynamic> data = jsonDecode(response.body);
    final List<dynamic> metaList = data['translated_metadata'] ?? [];
    return metaList
        .map((e) => AnimeMetadata.fromJson(e as Map<String, dynamic>))
        .toList();
  }
}
