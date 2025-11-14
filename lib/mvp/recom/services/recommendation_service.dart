import 'dart:convert';
import 'dart:async';

import 'package:parrokit/mvp/recom/entities/anime_meta_data.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/foundation.dart';
import 'package:web_socket_channel/web_socket_channel.dart';

typedef RecommendationProgressCallback = void Function(
  String status,
  double progress,
);

/// Service that communicates with the external recommendation server.
class RecommendationService {
  final String _baseUrl = dotenv.env['RECOMMEND_SERVER_ADDRESS'] ?? '';

  Future<List<AnimeMetadata>> fetchRecommendations({
    required List<String> titles,
    required int topK,
    required double cutoff,
    bool excludeWatched = true,
  }) async {
    // [추천 시작] 입력 파라미터 로깅
    debugPrint('[추천 시작] titles=${titles.join(', ')} topK=$topK cutoff=$cutoff excludeWatched=$excludeWatched');

    if (_baseUrl.isEmpty) {
      debugPrint('[추천 오류] RECOMMEND_SERVER_ADDRESS(.env)가 비어 있습니다.');
      throw Exception('RECOMMEND_SERVER_ADDRESS is not configured');
    }

    final uri =
        Uri.parse(_baseUrl.startsWith('http') ? _baseUrl : 'http://$_baseUrl');

    final body = jsonEncode({
      'titles': titles,
      'top_k': topK,
      'cutoff': cutoff,
      'exclude_watched': excludeWatched,
    });

    debugPrint('[추천 요청 URI] $uri');
    debugPrint('[추천 요청 바디] $body');

    final stopwatch = Stopwatch()..start();
    final response = await http.post(
      uri,
      headers: {'Content-Type': 'application/json'},
      body: body,
    );
    stopwatch.stop();

    debugPrint('[추천 응답 코드] ${response.statusCode}');
    debugPrint('[추천 응답 시간(ms)] ${stopwatch.elapsedMilliseconds}');
    debugPrint('[추천 응답 원문] ${response.body}');

    if (response.statusCode != 200) {
      debugPrint('[추천 오류] status=${response.statusCode} body=${response.body}');
      throw Exception('추천 서버 오류 (status: ${response.statusCode})');
    }

    final Map<String, dynamic> data = jsonDecode(response.body);
    final List<dynamic> metaList = data['translated_metadata'] ?? [];

    debugPrint('[추천 파싱] translated_metadata 개수=${metaList.length}');

    final results = metaList
        .map((e) => AnimeMetadata.fromJson(e as Map<String, dynamic>))
        .toList();

    debugPrint('[추천 완료] 결과 개수=${results.length}');
    return results;
  }

  Future<List<AnimeMetadata>> fetchRecommendationsWithProgress({
    required List<String> titles,
    required int topK,
    required double cutoff,
    bool excludeWatched = true,
    required RecommendationProgressCallback onProgress,
  }) async {
    // WebSocket용 주소: RECOMMEND_WS_ADDRESS 우선, 없으면 RECOMMEND_SERVER_ADDRESS 기반으로 구성
    String wsAddress = dotenv.env['RECOMMEND_WS_ADDRESS'] ?? _baseUrl;

    if (wsAddress.isEmpty) {
      debugPrint('[추천(WebSocket) 오류] RECOMMEND_SERVER_ADDRESS/RECOMMEND_WS_ADDRESS(.env)가 비어 있습니다.');
      throw Exception('RECOMMEND_SERVER_ADDRESS / RECOMMEND_WS_ADDRESS is not configured');
    }

    // 스킴 변환: http -> ws, https -> wss, 그 외는 ws:// prefix
    if (wsAddress.startsWith('http://')) {
      wsAddress = wsAddress.replaceFirst('http://', 'ws://');
    } else if (wsAddress.startsWith('https://')) {
      wsAddress = wsAddress.replaceFirst('https://', 'wss://');
    } else if (!wsAddress.startsWith('ws://') && !wsAddress.startsWith('wss://')) {
      wsAddress = 'ws://$wsAddress';
    }

    final uri = Uri.parse(wsAddress);

    debugPrint('[추천(WebSocket) 시작] uri=$uri');
    debugPrint('[추천(WebSocket) titles=${titles.join(', ')} topK=$topK cutoff=$cutoff excludeWatched=$excludeWatched]');

    final channel = WebSocketChannel.connect(uri);

    final payload = {
      'titles': titles,
      'top_k': topK,
      'cutoff': cutoff,
      'exclude_watched': excludeWatched,
    };

    channel.sink.add(jsonEncode(payload));

    final completer = Completer<List<AnimeMetadata>>();
    final stopwatch = Stopwatch()..start();

    void safeCompleteError(Object error) {
      if (!completer.isCompleted) {
        completer.completeError(error);
      }
    }

    channel.stream.listen(
      (raw) {
        try {
          final data = jsonDecode(raw as String) as Map<String, dynamic>;
          final event = data['event'] as String?;

          switch (event) {
            case 'search_completed':
              debugPrint('[추천(WebSocket) 이벤트] search_completed');
              onProgress('선호 분석 중', 0.3);
              break;
            case 'recommendation_completed':
              debugPrint('[추천(WebSocket) 이벤트] recommendation_completed');
              onProgress('후보 점수 산정 중', 0.7);
              break;
            case 'done':
              debugPrint('[추천(WebSocket) 이벤트] done');
              onProgress('정렬 및 정리 중', 0.95);

              final result = data['result'] as Map<String, dynamic>? ?? {};
              final List<dynamic> metaList = result['translated_metadata'] ?? [];

              debugPrint('[추천(WebSocket) 파싱] translated_metadata 개수=${metaList.length}');

              final results = metaList
                  .map((e) => AnimeMetadata.fromJson(e as Map<String, dynamic>))
                  .toList();

              onProgress('완료', 1.0);
              stopwatch.stop();
              debugPrint('[추천(WebSocket) 완료] 결과 개수=${results.length} 경과(ms)=${stopwatch.elapsedMilliseconds}');

              if (!completer.isCompleted) {
                completer.complete(results);
              }
              channel.sink.close();
              break;
            case 'error':
              final message = data['message']?.toString() ?? '알 수 없는 서버 오류';
              debugPrint('[추천(WebSocket) 이벤트] error: $message');
              safeCompleteError(Exception(message));
              channel.sink.close();
              break;
            default:
              debugPrint('[추천(WebSocket) 이벤트] 기타: $event');
              break;
          }
        } catch (e, st) {
          debugPrint('[추천(WebSocket) 파싱 오류] $e\n$st');
          safeCompleteError(e);
          channel.sink.close();
        }
      },
      onError: (err) {
        debugPrint('[추천(WebSocket) 스트림 오류] $err');
        safeCompleteError(err);
        channel.sink.close();
      },
      onDone: () {
        debugPrint('[추천(WebSocket) 스트림 종료]');
        if (!completer.isCompleted) {
          safeCompleteError(Exception('서버 연결이 예기치 않게 종료되었습니다.'));
        }
      },
      cancelOnError: true,
    );

    return completer.future;
  }
}
