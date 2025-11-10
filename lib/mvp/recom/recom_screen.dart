import 'package:flutter/material.dart';
import 'dart:math';

class RecomScreen extends StatefulWidget {
  const RecomScreen({super.key});

  @override
  State<RecomScreen> createState() => _RecomScreenState();
}

class RecomMockRepo {
  final _rnd = Random(42);

  Future<List<RecomItem>> recommend(List<String> seeds) async {
    await Future.delayed(const Duration(milliseconds: 800));
    // 목: seed 조합으로 가중 랜덤
    return List.generate(12, (i) {
      final base = seeds.isNotEmpty ? seeds[_rnd.nextInt(seeds.length)] : '추천작';
      final title = '$base 추천작 #${i + 1}';
      return RecomItem(
        title: title,
        overview: '“$base”를 좋아하는 이용자들이 함께 본 작품입니다. 액션/모험 요소가 강합니다.',
        imageUrl: 'https://picsum.photos/seed/$title/200/300',
        rating: (_rnd.nextDouble() * 4.0) + 6.0,     // 6.0~10.0
        score: _rnd.nextDouble(),                    // 0~1
        year: 2012 + _rnd.nextInt(13),               // 2012~2024
      );
    });
  }
}
class _RecomScreenState extends State<RecomScreen> {
  @override
  Widget build(BuildContext context) {
    return const RecomSelectScreen();
  }
}

class RecomSelectScreen extends StatefulWidget {
  const RecomSelectScreen({super.key});

  @override
  State<RecomSelectScreen> createState() => _RecomSelectScreenState();
}

class _RecomSelectScreenState extends State<RecomSelectScreen> {
  final TextEditingController _search = TextEditingController();
  final List<String> _candidates = [
    "귀멸의 칼날","주술회전","하이큐!!","블루록","진격의 거인","나루토","원피스","스파이 패밀리","체인소맨","단다단"
  ];
  final List<String> _selected = [];

  void _toggle(String title) {
    setState(() {
      if (_selected.contains(title)) {
        _selected.remove(title);
      } else {
        _selected.add(title);
      }
    });
  }

  Future<void> _startRecom() async {
    if (_selected.isEmpty) return;

    // 진행 모달
    final result = await showRecomProgress(
      context: context,
      titles: _selected,
      run: () => RecomMockRepo().recommend(_selected),
    );
    if (!mounted) return;
    if (result != null) {
      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (_) => RecomResultScreen(results: result),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final filtered = _candidates
        .where((e) => e.contains(_search.text.trim()))
        .toList();

    return Scaffold(
      appBar: AppBar(title: const Text('애니 추천')),
      body: Column(
        children: [
          // 검색
          Padding(
            padding: const EdgeInsets.all(16),
            child: TextField(
              controller: _search,
              decoration: InputDecoration(
                hintText: '애니 제목으로 검색',
                prefixIcon: const Icon(Icons.search),
                border: const OutlineInputBorder(borderSide: BorderSide.none),
                filled: true,
              ),
              onChanged: (_) => setState(() {}),
            ),
          ),

          // 선택된 목록 (가로)
          if (_selected.isNotEmpty)
            SizedBox(
              height: 64,
              child: ListView.separated(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                scrollDirection: Axis.horizontal,
                itemCount: _selected.length,
                separatorBuilder: (_, __) => const SizedBox(width: 8),
                itemBuilder: (_, i) {
                  final t = _selected[i];
                  return InputChip(
                    label: Text(t),
                    onDeleted: () => _toggle(t),
                  );
                },
              ),
            ),

          const SizedBox(height: 8),

          // 후보 Chip 그리드
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: SingleChildScrollView(
                child: Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    for (final title in filtered)
                      FilterChip(
                        selected: _selected.contains(title),
                        label: Text(title),
                        onSelected: (_) => _toggle(title),
                      ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),

      // 고정 CTA
      bottomNavigationBar: SafeArea(
        minimum: const EdgeInsets.fromLTRB(16, 8, 16, 16),
        child: FilledButton.icon(
          onPressed: _selected.isEmpty ? null : _startRecom,
          icon: const Icon(Icons.auto_awesome),
          label: const Text('추천 받기'),
        ),
      ),
    );
  }
}


typedef RecomRunner = Future<List<RecomItem>> Function();

Future<List<RecomItem>?> showRecomProgress({
  required BuildContext context,
  required List<String> titles,
  required RecomRunner run,
}) async {
  return showModalBottomSheet<List<RecomItem>>(
    context: context,
    isDismissible: true,
    enableDrag: true,
    isScrollControlled: false,
    builder: (_) => _RecomProgressSheet(titles: titles, run: run),
  );
}

class _RecomProgressSheet extends StatefulWidget {
  const _RecomProgressSheet({required this.titles, required this.run});
  final List<String> titles;
  final RecomRunner run;

  @override
  State<_RecomProgressSheet> createState() => _RecomProgressSheetState();
}

class _RecomProgressSheetState extends State<_RecomProgressSheet> {
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
      // 단계적 상태 텍스트 (UX: 사용자가 기다릴 이유를 부여)
      setState(() { _status = '선호 분석 중'; _progress = 0.3; });
      await Future.delayed(const Duration(milliseconds: 400));

      setState(() { _status = '후보 군집화 중'; _progress = 0.6; });
      await Future.delayed(const Duration(milliseconds: 400));

      setState(() { _status = '점수 산정 중'; _progress = 0.85; });
      final r = await widget.run();

      if (!mounted) return;
      setState(() { _status = '정렬 및 정리 중'; _progress = 1.0; });
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
          const _Grabber(),
          const SizedBox(height: 8),
          Text('추천 준비 중', style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 8),
          Text('선택: ${widget.titles.join(", ")}',
              textAlign: TextAlign.center),
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

class _Grabber extends StatelessWidget {
  const _Grabber();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 36, height: 4,
      decoration: BoxDecoration(
        color: Theme.of(context).dividerColor,
        borderRadius: BorderRadius.circular(2),
      ),
    );
  }
}

class RecomResultScreen extends StatefulWidget {
  const RecomResultScreen({super.key, required this.results});
  final List<RecomItem> results;

  @override
  State<RecomResultScreen> createState() => _RecomResultScreenState();
}

class _RecomResultScreenState extends State<RecomResultScreen> {
  String _sort = '추천순';

  List<RecomItem> get _sorted {
    final list = [...widget.results];
    switch (_sort) {
      case '평점순':
        list.sort((a, b) => b.rating.compareTo(a.rating));
        break;
      case '신작순':
        list.sort((a, b) => b.year.compareTo(a.year));
        break;
      default: // 추천순(기본)
        list.sort((a, b) => b.score.compareTo(a.score));
    }
    return list;
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
              PopupMenuItem(value: '평점순', child: Text('평점순')),
              PopupMenuItem(value: '신작순', child: Text('신작순')),
            ],
          )
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          // TODO: 재추천 로직 연결 (seed 동일)
          await Future.delayed(const Duration(milliseconds: 400));
        },
        child: ListView.separated(
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
                leading: _Poster(url: it.imageUrl),
                title: Text(it.title, maxLines: 1, overflow: TextOverflow.ellipsis),
                subtitle: Text(it.overview, maxLines: 2, overflow: TextOverflow.ellipsis),
                trailing: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.star_rate_rounded),
                    Text(it.rating.toStringAsFixed(1)),
                  ],
                ),
                onTap: () {
                  // TODO: 상세로 이동
                },
              ),
            );
          },
        ),
      ),
    );
  }
}

class _Poster extends StatelessWidget {
  const _Poster({required this.url});
  final String url;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(8),
      child: Image.network(
        url,
        width: 56, height: 56, fit: BoxFit.cover,
        errorBuilder: (_, __, ___) => Container(
          width: 56, height: 56,
          color: Theme.of(context).colorScheme.surfaceVariant,
          child: const Icon(Icons.image_not_supported),
        ),
      ),
    );
  }
}

// recom_models.dart
class RecomItem {
  final String title;
  final String overview;
  final String imageUrl;
  final double rating; // 0~10
  final double score;  // 내부 점수
  final int year;

  RecomItem({
    required this.title,
    required this.overview,
    required this.imageUrl,
    required this.rating,
    required this.score,
    required this.year,
  });
}