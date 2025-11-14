import 'package:flutter/material.dart';
import 'package:parrokit/mvp/recom/entities/anime_meta_data.dart';
import 'package:parrokit/mvp/recom/entities/recmmendation_runner.dart';
import 'package:parrokit/mvp/recom/widgets/grabber.dart';


/// Shows a modal bottom sheet with progress indications while the recommendations
/// are being fetched. Returns the list of results or null if cancelled.
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

/// Internal widget used by [showRecommendationProgress].
class _RecommendationProgressSheet extends StatefulWidget {
  const _RecommendationProgressSheet({required this.titles, required this.run});

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
      setState(() {
        _status = '선호 분석 중';
        _progress = 0.3;
      });
      await Future.delayed(const Duration(milliseconds: 400));

      setState(() {
        _status = '후보 군집화 중';
        _progress = 0.6;
      });
      await Future.delayed(const Duration(milliseconds: 400));

      setState(() {
        _status = '점수 산정 중';
        _progress = 0.85;
      });
      final r = await widget.run();

      if (!mounted) return;
      setState(() {
        _status = '정렬 및 정리 중';
        _progress = 1.0;
      });
      await Future.delayed(const Duration(milliseconds: 200));

      if (!mounted) return;
      Navigator.of(context).pop(r);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('추천 실패: $e')),
      );
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
          Text('선택: ${widget.titles.join(", ")}', textAlign: TextAlign.center),
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
