// ============================================================================
// lib/features/recom/presentation/recom_result_screen.dart
// ============================================================================
//
// [역할]
// 추천 결과 화면.
// 추천된 애니메이션 목록을 정렬/필터링하여 표시.
//
// [레이어]
// Presentation Layer - View
//
// [구성 요소]
// - AnimeDetailDialog: 애니 상세 정보 다이얼로그
// - Poster: 포스터 이미지 위젯
// ============================================================================

import 'package:flutter/material.dart';
import 'package:parrokit/core/theme/app_spacing.dart';
import 'package:parrokit/core/theme/app_radius.dart';
import 'package:parrokit/features/_discovery/recom/domain/anime_meta_data.dart';
import 'package:parrokit/features/_discovery/recom/presentation/widgets/poster.dart';
import 'package:parrokit/features/_discovery/recom/presentation/widgets/anime_detail_dialog.dart';

/// 추천 결과 화면.
///
/// 추천된 애니메이션 목록을 정렬 옵션과 함께 표시.
class RecomResultScreen extends StatefulWidget {
  const RecomResultScreen({
    super.key,
    required this.results,
    required this.titles,
    required this.topK,
    required this.cutoff,
    this.excludeWatched = true,
  });

  final List<AnimeMetadata> results;
  final List<String> titles;
  final int topK;
  final double cutoff;
  final bool excludeWatched;

  @override
  State<RecomResultScreen> createState() => _RecomResultScreenState();
}

class _RecomResultScreenState extends State<RecomResultScreen> {
  // ─────────────────────────────────────────────────────────────────
  // State
  // ─────────────────────────────────────────────────────────────────

  String _sortOption = '추천순';
  late List<AnimeMetadata> _results;

  // ─────────────────────────────────────────────────────────────────
  // Lifecycle
  // ─────────────────────────────────────────────────────────────────

  @override
  void initState() {
    super.initState();
    _results = [...widget.results];
  }

  // ─────────────────────────────────────────────────────────────────
  // Computed
  // ─────────────────────────────────────────────────────────────────

  List<AnimeMetadata> get _sortedResults {
    final list = [..._results];
    switch (_sortOption) {
      case '스코어순':
        list.sort((a, b) => b.score.compareTo(a.score));
        break;
      default: // 추천순
        list.sort((a, b) => b.score.compareTo(a.score));
    }
    return list;
  }

  // ─────────────────────────────────────────────────────────────────
  // Build
  // ─────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('추천 결과'),
        actions: [
          PopupMenuButton<String>(
            initialValue: _sortOption,
            onSelected: (v) => setState(() => _sortOption = v),
            itemBuilder: (_) => const [
              PopupMenuItem(value: '추천순', child: Text('추천순')),
              PopupMenuItem(value: '스코어순', child: Text('스코어순')),
            ],
          ),
        ],
      ),
      body: ListView.separated(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
        itemCount: _sortedResults.length,
        separatorBuilder: (_, __) => const SizedBox(height: 12),
        itemBuilder: (_, i) => _buildResultItem(_sortedResults[i]),
      ),
    );
  }

  Widget _buildResultItem(AnimeMetadata anime) {
    final theme = Theme.of(context);

    return Material(
      elevation: 0,
      borderRadius: BorderRadius.circular(AppRadius.md),
      color: theme.colorScheme.surface,
      child: ListTile(
        contentPadding: const EdgeInsets.all(AppSpacing.md),
        leading: Poster(url: anime.imageUrl),
        title: Text(
          anime.nameKo,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              anime.synopsisKo,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 4),
            Text(
              '${anime.type} · ${anime.genres}',
              style: theme.textTheme.bodySmall,
            ),
          ],
        ),
        isThreeLine: true,
        trailing: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.star_rate_rounded),
            Text(anime.score.toStringAsFixed(2)),
          ],
        ),
        onTap: () => showAnimeDetailDialog(context, anime),
      ),
    );
  }
}
