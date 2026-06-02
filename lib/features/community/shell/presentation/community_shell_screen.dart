import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:parrokit/core/router/app_routes.dart';
import 'package:parrokit/features/community/board/presentation/board_screen.dart';
import 'package:parrokit/features/community/question/presentation/question_screen.dart';
import 'package:parrokit/features/community/vote/presentation/vote_screen.dart';
import 'package:parrokit/features/community/shell/domain/data/community_filters.dart';
import 'package:parrokit/features/community/shell/presentation/sections/community_shell_filters_section.dart';
import 'package:parrokit/features/community/shell/presentation/sections/community_shell_write_sheet.dart';
import 'package:parrokit/features/community/shell/presentation/widgets/community_header_delegate.dart';
import 'package:parrokit/features/community/shell/presentation/widgets/community_write_fab.dart';
import 'package:parrokit/core/theme/app_colors.dart';

class CommunityShellScreen extends StatefulWidget {
  const CommunityShellScreen({super.key});

  @override
  State<CommunityShellScreen> createState() => _CommunityShellScreenState();
}

class _CommunityShellScreenState extends State<CommunityShellScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final ScrollController _outerScrollController = ScrollController();

  String _selectedBoardFilter = CommunityFilters.defaultBoard;
  String _selectedQuestionFilter = CommunityFilters.defaultQuestion;
  String _selectedVoteFilter = CommunityFilters.defaultVote;

  int _currentIndex = 0;
  bool _isFabExtended = true;
  bool _headerVisible = true;

  String _normalizedVoteFilter(String value) {
    if (value == '랜덤 보기') return CommunityFilters.vote[0];
    return CommunityFilters.vote.contains(value) ? value : CommunityFilters.defaultVote;
  }

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this)
      ..addListener(_onTabChanged);
    _outerScrollController.addListener(_checkHeaderVisibility);
  }

  void _onTabChanged() {
    if (_currentIndex == _tabController.index) return;
    setState(() => _currentIndex = _tabController.index);
  }

  void _checkHeaderVisibility() {
    final fullyVisible = _outerScrollController.offset <= 1.0;
    if (_headerVisible == fullyVisible) return;
    setState(() {
      _headerVisible = fullyVisible;
      _isFabExtended = fullyVisible;
    });
  }

  @override
  void dispose() {
    _tabController.removeListener(_onTabChanged);
    _outerScrollController.removeListener(_checkHeaderVisibility);
    _outerScrollController.dispose();
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      backgroundColor: colorScheme.surface,
      body: SafeArea(
        child: NestedScrollView(
          controller: _outerScrollController,
          floatHeaderSlivers: true,
          headerSliverBuilder: (context, innerBoxIsScrolled) {
            return [
              SliverPersistentHeader(
                floating: true,
                delegate: CommunityHeaderDelegate(
                  titleWidget: _buildTitleBar(context),
                  zone1Widget: _buildTabBar(context),
                  zone2Widget: _buildFilterSection(),
                ),
              ),
            ];
          },
          body: TabBarView(
            controller: _tabController,
            physics: _headerVisible
                ? const AlwaysScrollableScrollPhysics()
                : const NeverScrollableScrollPhysics(),
            children: [
              BoardScreen(selectedFilter: _selectedBoardFilter),
              QuestionScreen(selectedFilter: _selectedQuestionFilter),
              VoteScreen(
                selectedFilter: _normalizedVoteFilter(_selectedVoteFilter),
                swipeEnabled: !_headerVisible,
              ),
            ],
          ),
        ),
      ),
      floatingActionButton: CommunityWriteFab(
        isExtended: _isFabExtended,
        onTap: () => showCommunityWriteBottomSheet(context),
      ),
    );
  }

  Widget _buildTitleBar(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Padding(
      padding: const EdgeInsets.fromLTRB(16.0, 4.0, 4.0, 4.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            '커뮤니티',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: colorScheme.onSurface,
            ),
          ),
          Row(
            children: [
              IconButton(
                icon: Icon(Icons.search, color: colorScheme.onSurface),
                onPressed: () {},
              ),
              IconButton(
                icon: Icon(Icons.notifications_none, color: colorScheme.onSurface),
                onPressed: () => context.push(AppRoutes.communityNotificationPath),
              ),
              IconButton(
                icon: Icon(Icons.menu, color: colorScheme.onSurface),
                onPressed: () => context.push(AppRoutes.communityMenuPath),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildTabBar(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return TabBar(
      controller: _tabController,
      isScrollable: true,
      tabAlignment: TabAlignment.start,
      labelColor: colorScheme.onSurface,
      labelStyle: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
      unselectedLabelColor: colorScheme.onSurfaceVariant,
      unselectedLabelStyle: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
      indicatorColor: colorScheme.onSurface,
      indicatorSize: TabBarIndicatorSize.label,
      dividerColor: Colors.transparent,
      padding: EdgeInsets.zero,
      labelPadding: const EdgeInsets.symmetric(horizontal: 16.0),
      tabs: const [
        Tab(text: '게시판'),
        Tab(text: '질문'),
        Tab(text: '투표'),
      ],
    );
  }

  Widget _buildFilterSection() {
    return Column(
      children: [
        const SizedBox(height: 12),
        SizedBox(
          height: 36,
          child: CommunityShellFiltersSection(
            tabIndex: _tabController.index,
            selectedBoardFilter: _selectedBoardFilter,
            selectedQuestionFilter: _selectedQuestionFilter,
            selectedVoteFilter: _selectedVoteFilter,
            onBoardFilterSelected: (value) => setState(() => _selectedBoardFilter = value),
            onQuestionFilterSelected: (value) => setState(() => _selectedQuestionFilter = value),
            onVoteFilterSelected: (value) =>
                setState(() => _selectedVoteFilter = _normalizedVoteFilter(value)),
          ),
        ),
        const SizedBox(height: 11),
        const Divider(color: AppColors.disabled, height: 1),
      ],
    );
  }
}
