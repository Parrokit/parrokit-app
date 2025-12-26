// ============================================================================
// lib/features/recom/presentation/recommendation_progress_sheet.dart
// ============================================================================
//
// [역할]
// 추천 진행 상태를 표시하는 바텀 시트.
// 서버 요청 중 진행률과 상태 메시지 표시.
//
// [레이어]
// Presentation Layer
// ============================================================================

import 'package:flutter/material.dart';
import 'package:parrokit/features/_discovery/recom/domain/anime_meta_data.dart';
import 'package:parrokit/features/_discovery/recom/presentation/widgets/grabber.dart';
import 'package:parrokit/core/utils/show_toast.dart';

/// 진행 콜백 타입.
typedef ProgressCallback = void Function(String status, double progress);

/// 추천 실행 함수 타입.
typedef RecommendationRunner = Future<List<AnimeMetadata>> Function(
  ProgressCallback onProgress,
);

/// 추천 진행 시트 표시.
///
/// [run]: 진행 콜백을 받아 추천 결과를 반환하는 함수.
/// Returns: 추천 결과 리스트 또는 취소 시 null.
Future<List<AnimeMetadata>?> showRecommendationProgress({
  required BuildContext context,
  required List<String> titles,
  required RecommendationRunner run,
}) async {
  return showModalBottomSheet<List<AnimeMetadata>>(
    context: context,
    isDismissible: true,
    enableDrag: true,
    isScrollControlled: false,
    builder: (_) => _RecommendationProgressSheet(titles: titles, run: run),
  );
}

class _RecommendationProgressSheet extends StatefulWidget {
  const _RecommendationProgressSheet({
    required this.titles,
    required this.run,
  });

  final List<String> titles;
  final RecommendationRunner run;

  @override
  State<_RecommendationProgressSheet> createState() =>
      _RecommendationProgressSheetState();
}

class _RecommendationProgressSheetState
    extends State<_RecommendationProgressSheet> {
  double _progress = 0.1;
  String _status = '초기화 중...';
  bool _running = true;

  @override
  void initState() {
    super.initState();
    _kick();
  }

  Future<void> _kick() async {
    try {
      final results = await widget.run((status, progress) {
        if (!mounted) return;
        setState(() {
          _status = status;
          _progress = progress;
        });
      });

      if (!mounted) return;
      setState(() {
        _status = '정렬 및 정리 중';
        _progress = 1.0;
      });

      await Future.delayed(const Duration(milliseconds: 200));
      if (!mounted) return;
      Navigator.of(context).pop(results);
    } catch (e) {
      if (!mounted) return;
      showToast(context, '추천에 실패했습니다!');
      debugPrint('추천 실패: $e');
      Navigator.of(context).pop(null);
    } finally {
      if (mounted) setState(() => _running = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      minimum: const EdgeInsets.fromLTRB(16, 20, 16, 16),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Grabber(),
          const SizedBox(height: 8),
          Text('추천 준비 중', style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 8),
          Text(
            '선택: ${widget.titles.join(", ")}',
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          LinearProgressIndicator(value: _progress),
          const SizedBox(height: 12),
          Text(_status),
          const SizedBox(height: 16),
          TextButton.icon(
            onPressed: _running ? () => Navigator.of(context).pop(null) : null,
            icon: const Icon(Icons.close),
            label: const Text('중단'),
          ),
        ],
      ),
    );
  }
}
