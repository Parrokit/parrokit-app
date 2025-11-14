import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:parrokit/data/local/pa_database.dart';
import 'package:parrokit/mvp/recom/recom_presenter.dart';
import 'package:parrokit/mvp/recom/recom_view.dart';
import 'package:parrokit/mvp/recom/screens/recommendation_progress_sheet.dart';
import 'package:parrokit/mvp/recom/screens/recommendation_result_screen.dart';
import 'package:parrokit/mvp/recom/services/recommendation_service.dart';
import 'package:parrokit/utils/show_toast.dart';
import 'package:provider/provider.dart';
import 'package:flutter/cupertino.dart';

/// Main screen where users can select seeds and initiate recommendations.
class RecommendationSelectScreen extends StatefulWidget {
  const RecommendationSelectScreen({super.key});

  @override
  State<RecommendationSelectScreen> createState() =>
      _RecommendationSelectScreenState();
}

class _RecommendationSelectScreenState extends State<RecommendationSelectScreen>
    implements RecomView {
  late final PaDatabase _db;

  final TextEditingController _search = TextEditingController();
  final TextEditingController _custom = TextEditingController();

  final List<String> _candidates = [];
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

  void _selectAllCandidates() {
    setState(() {
      _selected
        ..clear()
        ..addAll(_candidates);
    });
  }

  void _clearSelected() {
    setState(() {
      _selected.clear();
    });
  }

  // ==== 생명주기 ====
  @override
  void initState() {
    super.initState();
    _db = context.read<PaDatabase>();
    _loadCandidates();
  }

  @override
  void dispose() {
    _search.dispose();
    _custom.dispose();
    super.dispose();
  }

  Future<void> _loadCandidates() async {
    final names = await _db.titlesDao.fetchAllTitleNames();
    setState(() {
      _candidates
        ..clear()
        ..addAll(names);
    });
  }

  /// Initiates recommendation by calling the server and navigating to result screen.
  @override
  Future<void> startRecom() async {
    if (_selected.isEmpty) return;
    final service = RecommendationService();
    final result = await showRecommendationProgress(
      context: context,
      titles: _selected,
      run: (onProgress) {
        return service.fetchRecommendationsWithProgress(
          titles: _selected,
          topK: _topK,
          cutoff: _cutoff,
          excludeWatched: _excludeWatched,
          onProgress: onProgress,
        );
      },
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
      body: SafeArea(
        child: Column(
          children: [
            _buildSearchField(),
            _buildSearchHint(),
            _buildInfoBanner(),
            _buildCandidateList(filtered),
          ],
        ),
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
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
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
    final allSelected =
        _candidates.isNotEmpty && _selected.length == _candidates.length;
    final hasSelection = _selected.isNotEmpty;

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
          const SizedBox(width: 8),
          TextButton(
            onPressed: _candidates.isEmpty
                ? null
                : (allSelected ? _clearSelected : _selectAllCandidates),
            child: Text(allSelected ? '전체 해제' : '전체 선택'),
          ),
        ],
      ),
    );
  }

  Widget _buildCandidateList(List<String> filtered) {
    return Expanded(
      child: ListView.builder(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: filtered.length,
        itemBuilder: (_, i) {
          final title = filtered[i];
          final selected = _selected.contains(title);
          return ListTile(
            title: Text(title),
            trailing: selected
                ? const Icon(Icons.check_circle)
                : const Icon(Icons.circle_outlined),
            onTap: () => toggle(title),
          );
        },
      ),
    );
  }

  Widget _buildBottomBar() {
    return SafeArea(
      minimum: const EdgeInsets.fromLTRB(16, 8, 16, 16),
      child: Row(
        children: [
          CupertinoButton(
            padding: EdgeInsets.zero,
            child: Text('$_topK개'),
            onPressed: () {
              final initialIndex = _topK.clamp(1, 20) - 1;
              int tempIndex = initialIndex;
              showCupertinoModalPopup(
                context: context,
                builder: (sheetContext) {
                  return Container(
                    height: 260,
                    color: CupertinoColors.systemBackground,
                    child: Column(
                      children: [
                        SizedBox(
                          height: 44,
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              CupertinoButton(
                                padding:
                                    const EdgeInsets.symmetric(horizontal: 16),
                                onPressed: () => Navigator.pop(sheetContext),
                                child: const Text('취소'),
                              ),
                              CupertinoButton(
                                padding:
                                    const EdgeInsets.symmetric(horizontal: 16),
                                onPressed: () {
                                  setState(() => _topK = tempIndex + 1);
                                  Navigator.pop(sheetContext);
                                },
                                child: const Text('완료'),
                              ),
                            ],
                          ),
                        ),
                        const Divider(height: 0),
                        Expanded(
                          child: CupertinoPicker(
                            scrollController: FixedExtentScrollController(
                              initialItem: initialIndex,
                            ),
                            itemExtent: 36,
                            onSelectedItemChanged: (index) {
                              tempIndex = index;
                            },
                            children: [
                              for (var i = 1; i <= 20; i++)
                                Center(child: Text('$i개')),
                            ],
                          ),
                        ),
                      ],
                    ),
                  );
                },
              );
            },
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
