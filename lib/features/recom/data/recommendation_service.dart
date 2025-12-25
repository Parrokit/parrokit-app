// ============================================================================
// lib/features/recom/data/recommendation_service.dart
// ============================================================================
//
// [역할]
// 추천 서버와 통신하는 서비스.
// REST API 및 WebSocket을 통해 애니메이션 추천 결과를 가져옴.
//
// [레이어]
// Data Layer - Service
//
// [환경 변수]
// - RECOMMEND_SERVER_ADDRESS: REST API 서버 주소
// - RECOMMEND_WS_ADDRESS: WebSocket 서버 주소 (선택)
// ============================================================================

import 'dart:convert';
import 'dart:async';

import 'package:parrokit/features/recom/domain/anime_meta_data.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/foundation.dart';
import 'package:web_socket_channel/web_socket_channel.dart';

/// 추천 진행 콜백 타입.
typedef RecommendationProgressCallback = void Function(
  String status,
  double progress,
);

/// 추천 서버 통신 서비스.
///
/// REST API와 WebSocket 두 가지 방식 지원:
/// - [fetchRecommendations]: 단순 HTTP POST 요청
/// - [fetchRecommendationsWithProgress]: WebSocket으로 진행 상태 수신
class RecommendationService {
  /// 추천 서버 기본 주소 (.env에서 로드)
  final String _baseUrl = dotenv.env['RECOMMEND_SERVER_ADDRESS'] ?? '';

  // ─────────────────────────────────────────────────────────────────
  // REST API 방식
  // ─────────────────────────────────────────────────────────────────

  /// REST API로 추천 결과 요청.
  ///
  /// [titles]: 시드 애니메이션 제목 목록
  /// [topK]: 반환할 추천 개수
  /// [cutoff]: 유사도 임계값
  /// [excludeWatched]: 시청한 작품 제외 여부
  Future<List<AnimeMetadata>> fetchRecommendations({
    required List<String> titles,
    required int topK,
    required double cutoff,
    bool excludeWatched = true,
  }) async {
    debugPrint('[추천 시작] titles=${titles.join(', ')} topK=$topK cutoff=$cutoff');

    if (_baseUrl.isEmpty) {
      debugPrint('[추천 오류] RECOMMEND_SERVER_ADDRESS(.env)가 비어 있습니다.');
      throw Exception('RECOMMEND_SERVER_ADDRESS is not configured');
    }

    final uri = Uri.parse(
      _baseUrl.startsWith('http') ? _baseUrl : 'http://$_baseUrl',
    );

    final body = jsonEncode({
      'titles': titles,
      'top_k': topK,
      'cutoff': cutoff,
      'exclude_watched': excludeWatched,
    });

    debugPrint('[추천 요청] $uri');

    final stopwatch = Stopwatch()..start();
    final response = await http.post(
      uri,
      headers: {'Content-Type': 'application/json'},
      body: body,
    );
    stopwatch.stop();

    debugPrint(
        '[추천 응답] ${response.statusCode} (${stopwatch.elapsedMilliseconds}ms)');

    if (response.statusCode != 200) {
      throw Exception('추천 서버 오류 (status: ${response.statusCode})');
    }

    final data = jsonDecode(response.body) as Map<String, dynamic>;
    final metaList = data['translated_metadata'] as List<dynamic>? ?? [];

    return metaList
        .map((e) => AnimeMetadata.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  // ─────────────────────────────────────────────────────────────────
  // WebSocket 방식 (진행 상태 포함)
  // ─────────────────────────────────────────────────────────────────

  /// WebSocket으로 추천 결과 요청 (진행 상태 콜백 지원).
  ///
  /// 서버에서 다음 이벤트를 순차적으로 전송:
  /// 1. `search_completed`: 검색 완료 (30%)
  /// 2. `recommendation_completed`: 추천 완료 (70%)
  /// 3. `done`: 전체 완료 + 결과 반환 (100%)
  ///
  /// [onProgress]: 진행 상태 콜백
  Future<List<AnimeMetadata>> fetchRecommendationsWithProgress({
    required List<String> titles,
    required int topK,
    required double cutoff,
    bool excludeWatched = true,
    required RecommendationProgressCallback onProgress,
  }) async {
    String wsAddress = dotenv.env['RECOMMEND_WS_ADDRESS'] ?? _baseUrl;

    if (wsAddress.isEmpty) {
      throw Exception('RECOMMEND_WS_ADDRESS is not configured');
    }

    // 스킴 변환: http → ws, https → wss
    wsAddress = _convertToWebSocketUrl(wsAddress);

    final uri = Uri.parse(wsAddress);
    debugPrint('[추천(WS)] 연결: $uri');

    final channel = WebSocketChannel.connect(uri);

    // 요청 전송
    channel.sink.add(jsonEncode({
      'titles': titles,
      'top_k': topK,
      'cutoff': cutoff,
      'exclude_watched': excludeWatched,
    }));

    return _handleWebSocketStream(channel, onProgress);
  }

  /// HTTP URL을 WebSocket URL로 변환.
  String _convertToWebSocketUrl(String url) {
    if (url.startsWith('http://')) {
      return url.replaceFirst('http://', 'ws://');
    } else if (url.startsWith('https://')) {
      return url.replaceFirst('https://', 'wss://');
    } else if (!url.startsWith('ws://') && !url.startsWith('wss://')) {
      return 'ws://$url';
    }
    return url;
  }

  /// WebSocket 스트림 처리.
  Future<List<AnimeMetadata>> _handleWebSocketStream(
    WebSocketChannel channel,
    RecommendationProgressCallback onProgress,
  ) {
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
              debugPrint('[추천(WS)] search_completed');
              onProgress('선호 분석 중', 0.3);
              break;

            case 'recommendation_completed':
              debugPrint('[추천(WS)] recommendation_completed');
              onProgress('후보 점수 산정 중', 0.7);
              break;

            case 'done':
              stopwatch.stop();
              debugPrint('[추천(WS)] done (${stopwatch.elapsedMilliseconds}ms)');
              onProgress('정렬 및 정리 중', 0.95);

              final result = data['result'] as Map<String, dynamic>? ?? {};
              final metaList = result['translated_metadata'] as List? ?? [];

              final results = metaList
                  .map((e) => AnimeMetadata.fromJson(e as Map<String, dynamic>))
                  .toList();

              onProgress('완료', 1.0);

              if (!completer.isCompleted) {
                completer.complete(results);
              }
              channel.sink.close();
              break;

            case 'error':
              final message = data['message']?.toString() ?? '알 수 없는 오류';
              debugPrint('[추천(WS)] error: $message');
              safeCompleteError(Exception(message));
              channel.sink.close();
              break;

            default:
              debugPrint('[추천(WS)] 기타 이벤트: $event');
          }
        } catch (e) {
          debugPrint('[추천(WS)] 파싱 오류: $e');
          safeCompleteError(e);
          channel.sink.close();
        }
      },
      onError: (err) {
        debugPrint('[추천(WS)] 스트림 오류: $err');
        safeCompleteError(err);
        channel.sink.close();
      },
      onDone: () {
        debugPrint('[추천(WS)] 스트림 종료');
        if (!completer.isCompleted) {
          safeCompleteError(Exception('서버 연결이 예기치 않게 종료되었습니다.'));
        }
      },
      cancelOnError: true,
    );

    return completer.future;
  }
}
