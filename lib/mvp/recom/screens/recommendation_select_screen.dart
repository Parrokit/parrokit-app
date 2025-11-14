import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:parrokit/mvp/recom/recom_presenter.dart';
import 'package:parrokit/mvp/recom/recom_view.dart';
import 'package:parrokit/mvp/recom/screens/recommendation_progress_sheet.dart';
import 'package:parrokit/mvp/recom/screens/recommendation_result_screen.dart';
import 'package:parrokit/mvp/recom/services/recommendation_service.dart';
import 'package:parrokit/utils/show_toast.dart';

/// Main screen where users can select seeds and initiate recommendations.
class RecommendationSelectScreen extends StatefulWidget {
  const RecommendationSelectScreen({super.key});

  @override
  State<RecommendationSelectScreen> createState() =>
      _RecommendationSelectScreenState();
}

class _RecommendationSelectScreenState extends State<RecommendationSelectScreen>
    implements RecomView {
  late final RecomPresenter _presenter;

  final TextEditingController _search = TextEditingController();
  final TextEditingController _custom = TextEditingController();

  final List<String> _candidates = [
    '귀멸의 칼날',
    '주술회전',
    '하이큐!!',
    '블루록',
    '진격의 거인',
    '나루토',
    '원피스',
    '스파이 패밀리',
    '체인소맨',
    '단다단',
  ];
  final List<String> _selected = [];

  int _topK = 10;
  final double _cutoff = 0.55;
  final bool _excludeWatched = true;

  // ==== RecomView 구현부 ====
  @override
  BuildContext get context => super.context;

  @override
  List<String> get candidates => _candidates;

  @override
  String get search => _search.text;

  @override
  String get custom => _custom.text;

  @override
  List<String> get selected => _selected;

  @override
  int get topK => _topK;

  @override
  double get cutoff => _cutoff;

  @override
  bool get excludeWatched => _excludeWatched;

  @override
  void toggle(String title) {
    setState(() {
      if (_selected.contains(title)) {
        _selected.remove(title);
      } else {
        _selected.add(title);
      }
    });
  }

  @override
  void addFromSearch() {
    final t = _search.text.trim();
    if (t.isEmpty) return;
    if (!_candidates.contains(t)) {
      _candidates.insert(0, t);
    }
    if (!_selected.contains(t)) {
      _selected.add(t);
    }
    _search.clear();
    setState(() {});
    HapticFeedback.lightImpact();
    showToast(context, '검색어를 선택 목록에 추가했어요.');
  }

  // ==== 생명주기 ====
  @override
  void initState() {
    super.initState();
    _presenter = RecomPresenter(this);
  }

  @override
  void dispose() {
    _search.dispose();
    _custom.dispose();
    super.dispose();
  }

  Future<void> _showAddSheet() async {
    final TextEditingController ctrl = TextEditingController();
    final result = await showModalBottomSheet<String>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      builder: (ctx) {
        final bottom = MediaQuery.of(ctx).viewInsets.bottom;
        return Padding(
          padding: EdgeInsets.only(bottom: bottom),
          child: SafeArea(
            top: false,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 36,
                    height: 4,
                    margin: const EdgeInsets.only(bottom: 12),
                    decoration: BoxDecoration(
                      color: Theme.of(ctx).dividerColor,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                  Row(
                    children: [
                      const Icon(Icons.add_circle_outline),
                      const SizedBox(width: 8),
                      Expanded(
                        child: TextField(
                          controller: ctrl,
                          autofocus: true,
                          textInputAction: TextInputAction.done,
                          onSubmitted: (_) =>
                              Navigator.of(ctx).pop(ctrl.text.trim()),
                          decoration: const InputDecoration(
                            hintText: '애니 제목 입력 (예: 단다단 1기)',
                            border:
                                OutlineInputBorder(borderSide: BorderSide.none),
                            filled: true,
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      FilledButton(
                        onPressed: () =>
                            Navigator.of(ctx).pop(ctrl.text.trim()),
                        child: const Text('담기'),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      '제목을 구체적으로 쓸수록 선호도에 더 가까운 추천이 나와요!',
                      style: Theme.of(ctx).textTheme.bodySmall,
                    ),
                  ),
                  const SizedBox(height: 8),
                  if (_search.text.trim().isNotEmpty)
                    Align(
                      alignment: Alignment.centerLeft,
                      child: Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: [
                          ActionChip(
                            avatar:
                                const Icon(Icons.tips_and_updates, size: 16),
                            label: Text('‘${_search.text.trim()}’ 담기'),
                            onPressed: () =>
                                Navigator.of(ctx).pop(_search.text.trim()),
                          ),
                        ],
                      ),
                    ),
                  const SizedBox(height: 8),
                ],
              ),
            ),
          ),
        );
      },
    );
    if (result != null) {
      final t = result.trim();
      if (t.isNotEmpty) {
        if (!_candidates.contains(t)) {
          _candidates.insert(0, t);
        }
        if (!_selected.contains(t)) {
          _selected.add(t);
        }
        setState(() {});
        HapticFeedback.lightImpact();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('‘$t’을(를) 선택 목록에 추가했어요.')),
        );
      }
    }
  }

  /// Initiates recommendation by calling the server and navigating to result screen.
  @override
  Future<void> startRecom() async {
    if (_selected.isEmpty) return;
    final service = RecommendationService();
    final result = await showRecommendationProgress(
      context: context,
      titles: _selected,
      run: () => service.fetchRecommendations(
        titles: _selected,
        topK: _topK,
        cutoff: _cutoff,
        excludeWatched: _excludeWatched,
      ),
    );
    if (!mounted) return;
    if (result != null) {
      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (_) => RecommendationResultScreen(
            results: result,
            titles: List<String>.from(_selected),
            topK: _topK,
            cutoff: _cutoff,
            excludeWatched: _excludeWatched,
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final filtered =
        _candidates.where((e) => e.contains(_search.text.trim())).toList();

    return Scaffold(
      appBar: AppBar(title: const Text('애니 추천')),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _showAddSheet,
        label: const Text('애니 추가'),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
      body: Column(
        children: [
          _buildSearchField(),
          _buildSearchHint(),
          _buildInfoBanner(),
          _buildSelectedChips(),
          const SizedBox(height: 8),
          _buildCandidateChips(filtered),
        ],
      ),
      bottomNavigationBar: _buildBottomBar(),
    );
  }

  Widget _buildSearchField() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: TextField(
        controller: _search,
        textInputAction: TextInputAction.search,
        decoration: InputDecoration(
          hintText: '애니 제목으로 검색',
          prefixIcon: const Icon(Icons.search),
          suffixIcon: (_search.text.trim().isEmpty)
              ? null
              : IconButton(
                  tooltip: '이 제목 추가',
                  icon: const Icon(Icons.add_circle_outline),
                  onPressed: addFromSearch,
                ),
          border: const OutlineInputBorder(borderSide: BorderSide.none),
          filled: true,
        ),
        onChanged: (_) => setState(() {}),
        onSubmitted: (_) {
          if (_search.text.trim().isNotEmpty) addFromSearch();
        },
      ),
    );
  }

  Widget _buildSearchHint() {
    final term = _search.text.trim();
    final shouldShow = term.isNotEmpty && !_candidates.contains(term);

    if (!shouldShow) {
      return const SizedBox.shrink();
    }

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
      child: Align(
        alignment: Alignment.centerLeft,
        child: Wrap(
          spacing: 8,
          children: [
            InputChip(
              avatar: const Icon(Icons.tips_and_updates, size: 18),
              label: Text('‘$term’ 추가'),
              onPressed: addFromSearch,
            ),
            const SizedBox(width: 4),
            Text(
              'Enter 키 또는 + 버튼으로 빠르게 담을 수 있어요.',
              style: Theme.of(context).textTheme.bodySmall,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoBanner() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            Icons.info_outline,
            size: 18,
            color: Theme.of(context).colorScheme.secondary,
          ),
          const SizedBox(width: 6),
          Expanded(
            child: Text(
              '애니 제목을 구체적으로 작성할수록, 추천이 당신의 선호도와 더 가깝게 나올 가능성이 높아요!',
              style: Theme.of(context).textTheme.bodySmall,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSelectedChips() {
    if (_selected.isEmpty) {
      return const SizedBox.shrink();
    }

    return SizedBox(
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
            onDeleted: () => toggle(t),
          );
        },
      ),
    );
  }

  Widget _buildCandidateChips(List<String> filtered) {
    return Expanded(
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
                  onSelected: (_) => toggle(title),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBottomBar() {
    return SafeArea(
      minimum: const EdgeInsets.fromLTRB(16, 8, 16, 16),
      child: Row(
        children: [
          DropdownButton<int>(
            value: _topK,
            onChanged: (int? v) {
              if (v != null) setState(() => _topK = v);
            },
            items: [
              for (var i = 1; i <= 20; i++)
                DropdownMenuItem<int>(
                  value: i,
                  child: Text('$i개'),
                ),
            ],
          ),
          const SizedBox(width: 8),
          Expanded(
            child: FilledButton.icon(
              onPressed: _selected.isEmpty ? null : startRecom,
              icon: const Icon(Icons.auto_awesome),
              label: const Text('추천 받기'),
            ),
          ),
        ],
      ),
    );
  }
}
