import 'package:parrokit/mvp/recom/entities/anime_meta_data.dart';
import 'package:flutter/material.dart';
import 'package:parrokit/mvp/recom/widgets/poster.dart';

/// Screen that displays the list of recommended anime with sorting and pull-to-refresh.
class RecommendationResultScreen extends StatefulWidget {
  const RecommendationResultScreen({
    Key? key,
    required this.results,
    required this.titles,
    required this.topK,
    required this.cutoff,
    this.excludeWatched = true,
  }) : super(key: key);

  final List<AnimeMetadata> results;
  final List<String> titles;
  final int topK;
  final double cutoff;
  final bool excludeWatched;

  @override
  State<RecommendationResultScreen> createState() =>
      _RecommendationResultScreenState();
}

class _RecommendationResultScreenState
    extends State<RecommendationResultScreen> {
  String _sort = '추천순';
  late List<AnimeMetadata> _results;

  @override
  void initState() {
    super.initState();
    _results = [...widget.results];
  }

  List<AnimeMetadata> get _sorted {
    final list = [..._results];
    switch (_sort) {
      case '스코어순':
        list.sort((a, b) => b.score.compareTo(a.score));
        break;
      default:
        list.sort((a, b) => b.score.compareTo(a.score));
    }
    return list;
  }

  void _showAnimeDialog(BuildContext context, AnimeMetadata it) {
    showDialog(
      context: context,
      builder: (ctx) {
        final theme = Theme.of(ctx);
        final size = MediaQuery.of(ctx).size;

        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          insetPadding:
              const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
          child: ConstrainedBox(
            constraints: BoxConstraints(
              maxWidth: 520,
              maxHeight: size.height * 0.70,
            ),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                mainAxisSize: MainAxisSize.max,
                children: [
                  // 상단 X 버튼
                  Align(
                    alignment: Alignment.topRight,
                    child: IconButton(
                      icon: const Icon(Icons.close),
                      onPressed: () => Navigator.of(ctx).pop(),
                    ),
                  ),

                  // ⬆️ 위: 이미지 + 제목/평점/장르/타입
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // 왼쪽 포스터
                      Flexible(
                        flex: 3,
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child: AspectRatio(
                            aspectRatio: 3 / 4,
                            child: Image.network(
                              it.imageUrl,
                              fit: BoxFit.cover,
                              errorBuilder: (_, __, ___) => Container(
                                color: theme.colorScheme.surfaceVariant,
                                child: const Icon(Icons.image_not_supported),
                              ),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 16),

                      // 오른쪽 정보
                      Expanded(
                        flex: 5,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              it.nameKo,
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                              style: theme.textTheme.titleMedium?.copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Row(
                              children: [
                                const Icon(Icons.star_rate_rounded, size: 18),
                                const SizedBox(width: 4),
                                Text(it.score.toStringAsFixed(2)),
                                const SizedBox(width: 12),
                                Text(
                                  it.type,
                                  style: theme.textTheme.bodySmall,
                                ),
                              ],
                            ),
                            const SizedBox(height: 6),
                            Text(
                              it.genres,
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                              style: theme.textTheme.bodySmall,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 16),

                  // ⬇️ 아래: 시놉시스 (전체 폭, 스크롤 가능)
                  Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      "개요",
                      style: theme.textTheme.bodyLarge,
                    ),
                  ),
                  Expanded(
                    child: Scrollbar(
                      thumbVisibility: true,
                      child: SingleChildScrollView(
                        child: Text(
                          it.synopsisKo,
                          style: theme.textTheme.bodyMedium,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('추천 결과'),
        actions: [
          PopupMenuButton<String>(
            initialValue: _sort,
            onSelected: (v) => setState(() => _sort = v),
            itemBuilder: (_) => const [
              PopupMenuItem(value: '추천순', child: Text('추천순')),
              PopupMenuItem(value: '스코어순', child: Text('스코어순')),
            ],
          ),
        ],
      ),
      body: ListView.separated(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
        itemCount: _sorted.length,
        separatorBuilder: (_, __) => const SizedBox(height: 12),
        itemBuilder: (_, i) {
          final it = _sorted[i];
          return Material(
            elevation: 0,
            borderRadius: BorderRadius.circular(12),
            color: Theme.of(context).colorScheme.surface,
            child: ListTile(
              contentPadding: const EdgeInsets.all(12),
              leading: Poster(url: it.imageUrl),
              title:
                  Text(it.nameKo, maxLines: 1, overflow: TextOverflow.ellipsis),
              subtitle: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(it.synopsisKo,
                      maxLines: 2, overflow: TextOverflow.ellipsis),
                  const SizedBox(height: 4),
                  Text(
                    '${it.type} · ${it.genres}',
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                ],
              ),
              isThreeLine: true,
              trailing: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.star_rate_rounded),
                  Text(it.score.toStringAsFixed(2)),
                ],
              ),
              onTap: () {
                _showAnimeDialog(context, it);
              },
            ),
          );
        },
      ),
    );
  }
}
