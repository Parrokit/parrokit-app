// ============================================================================
// lib/features/recom/presentation/recom_select_screen.dart
// ============================================================================
//
// [역할]
// 추천 시드 선택 화면.
// 사용자가 좋아하는 애니메이션을 선택하여 추천을 요청.
//
// [레이어]
// Presentation Layer - View
//
// [구성 요소]
// - SearchSection: 검색 입력 영역
// - CandidateListSection: 후보 목록
// - BottomActionBar: 하단 액션 버튼
// ============================================================================

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/cupertino.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import 'package:parrokit/data/local/app_database.dart';
import 'package:parrokit/core/router/app_router.dart';
import 'package:parrokit/core/utils/show_toast.dart';
import 'package:parrokit/features/recom/domain/recom_result_args.dart';
import 'package:parrokit/features/recom/data/recommendation_service.dart';

import 'recommendation_progress_sheet.dart';
import 'sections/search_section.dart';
import 'sections/candidate_list_section.dart';
import 'widgets/top_k_picker.dart';

/// 추천 시드 선택 화면.
class RecomSelectScreen extends StatefulWidget {
  const RecomSelectScreen({super.key});

  @override
  State<RecomSelectScreen> createState() => _RecomSelectScreenState();
}

class _RecomSelectScreenState extends State<RecomSelectScreen> {
  // ─────────────────────────────────────────────────────────────────
  // State & Controllers
  // ─────────────────────────────────────────────────────────────────

  late final AppDatabase _db;
  final TextEditingController _searchController = TextEditingController();

  final List<String> _candidates = [];
  final List<String> _selected = [];

  int _topK = 10;
  final double _cutoff = 0.55;
  final bool _excludeWatched = true;

  // ─────────────────────────────────────────────────────────────────
  // Lifecycle
  // ─────────────────────────────────────────────────────────────────

  @override
  void initState() {
    super.initState();
    _db = context.read<AppDatabase>();
    _loadCandidates();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  // ─────────────────────────────────────────────────────────────────
  // Data Loading
  // ─────────────────────────────────────────────────────────────────

  Future<void> _loadCandidates() async {
    final names = await _db.titlesDao.fetchAllTitleNames();
    setState(() {
      _candidates
        ..clear()
        ..addAll(names);
    });
  }

  // ─────────────────────────────────────────────────────────────────
  // Actions
  // ─────────────────────────────────────────────────────────────────

  void _toggleSelection(String title) {
    setState(() {
      if (_selected.contains(title)) {
        _selected.remove(title);
      } else {
        _selected.add(title);
      }
    });
  }

  void _addFromSearch() {
    final term = _searchController.text.trim();
    if (term.isEmpty) return;

    if (!_candidates.contains(term)) {
      _candidates.insert(0, term);
    }
    if (!_selected.contains(term)) {
      _selected.add(term);
    }
    _searchController.clear();
    setState(() {});

    HapticFeedback.lightImpact();
    showToast(context, '검색어를 선택 목록에 추가했어요.');
  }

  void _selectAll() {
    setState(() {
      _selected
        ..clear()
        ..addAll(_candidates);
    });
  }

  void _clearSelection() {
    setState(() => _selected.clear());
  }

  Future<void> _startRecommendation() async {
    if (_selected.isEmpty) return;

    final service = RecommendationService();
    final result = await showRecommendationProgress(
      context: context,
      titles: _selected,
      run: (onProgress) => service.fetchRecommendationsWithProgress(
        titles: _selected,
        topK: _topK,
        cutoff: _cutoff,
        excludeWatched: _excludeWatched,
        onProgress: onProgress,
      ),
    );

    if (!mounted || result == null) return;

    context.pushNamed(
      AppRoutes.recomResult,
      extra: RecomResultArgs(
        results: result,
        titles: List<String>.from(_selected),
        topK: _topK,
        cutoff: _cutoff,
        excludeWatched: _excludeWatched,
      ),
    );
  }

  void _showTopKPicker() {
    showTopKPicker(
      context: context,
      initialValue: _topK,
      onSelected: (value) => setState(() => _topK = value),
    );
  }

  // ─────────────────────────────────────────────────────────────────
  // Build
  // ─────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    final searchTerm = _searchController.text.trim();
    final filtered = _candidates.where((e) => e.contains(searchTerm)).toList();

    final allSelected =
        _candidates.isNotEmpty && _selected.length == _candidates.length;

    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            // 검색 영역
            SearchSection(
              controller: _searchController,
              onChanged: () => setState(() {}),
              onSubmit: _addFromSearch,
              onAddFromSearch: _addFromSearch,
              showAddHint:
                  searchTerm.isNotEmpty && !_candidates.contains(searchTerm),
              searchTerm: searchTerm,
            ),

            // 정보 배너 + 전체 선택/해제
            _buildInfoBanner(allSelected),

            // 후보 목록
            CandidateListSection(
              candidates: filtered,
              selected: _selected,
              onToggle: _toggleSelection,
            ),
          ],
        ),
      ),
      bottomNavigationBar: _buildBottomBar(),
    );
  }

  Widget _buildInfoBanner(bool allSelected) {
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
                : (allSelected ? _clearSelection : _selectAll),
            child: Text(allSelected ? '전체 해제' : '전체 선택'),
          ),
        ],
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
            onPressed: _showTopKPicker,
            child: Text('$_topK개'),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: FilledButton.icon(
              onPressed: _selected.isEmpty ? null : _startRecommendation,
              icon: const Icon(Icons.auto_awesome),
              label: const Text('추천 받기'),
            ),
          ),
        ],
      ),
    );
  }
}
