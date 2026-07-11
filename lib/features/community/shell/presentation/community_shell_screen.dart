import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:parrokit/core/app/router/app_routes.dart';
import 'package:parrokit/core/state/provider/user_provider.dart';
import 'package:parrokit/features/community/board/presentation/board_screen.dart';
import 'package:parrokit/features/community/question/presentation/question_screen.dart';
import 'package:parrokit/features/community/vote/presentation/vote_screen.dart';
import 'package:parrokit/features/community/shell/domain/data/community_filters.dart';
import 'package:parrokit/features/community/shell/presentation/sections/community_shell_filters_section.dart';
import 'package:parrokit/features/community/shell/presentation/sections/community_shell_write_sheet.dart';
import 'package:parrokit/features/community/shell/presentation/widgets/community_header_delegate.dart';
import 'package:parrokit/core/shared/theme/app_colors.dart';
import 'package:parrokit/core/shared/widgets/expandable_action_fab.dart';
import 'package:parrokit/core/shared/widgets/shell_fab_padding.dart';

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
    return CommunityFilters.vote.contains(value)
        ? value
        : CommunityFilters.defaultVote;
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
      floatingActionButton: ShellFabPadding(
        child: ExpandableActionFab(
          isExtended: _isFabExtended,
          icon: Icons.add,
          label: '글쓰기',
          onTap: () => showCommunityWriteBottomSheet(context),
          backgroundColor: AppColors.communityBoardAccent,
          foregroundColor: colorScheme.onPrimary,
          boxShadow: [
            BoxShadow(
              color: colorScheme.shadow.withValues(alpha: 0.22),
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
          iconSize: 24,
        ),
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
              Consumer<UserProvider>(
                builder: (context, userProvider, _) {
                  final unreadCount = userProvider.unreadNotificationCount;

                  return Stack(
                    clipBehavior: Clip.none,
                    children: [
                      IconButton(
                        icon: Icon(Icons.notifications_none,
                            color: colorScheme.onSurface),
                        onPressed: () => context
                            .push(AppRoutes.communityNotificationPath),
                      ),
                      if (unreadCount > 0)
                        Positioned(
                          right: 1,
                          bottom: 1,
                          child: Container(
                            constraints: const BoxConstraints(
                                minWidth: 20, minHeight: 20),
                            padding: const EdgeInsets.all(2),
                            decoration: BoxDecoration(
                              color: colorScheme.primary,
                              shape: BoxShape.circle,
                              border: Border.all(
                                  color: colorScheme.surface, width: 2),
                            ),
                            child: Text(
                              unreadCount > 99 ? '99+' : unreadCount.toString(),
                              textAlign: TextAlign.center,
                              style: const TextStyle(
                                fontSize: 9,
                                fontWeight: FontWeight.w800,
                                color: Colors.white,
                                height: 1,
                              ),
                            ),
                          ),
                        ),
                    ],
                  );
                },
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
      unselectedLabelStyle:
          const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
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
            onBoardFilterSelected: (value) =>
                setState(() => _selectedBoardFilter = value),
            onQuestionFilterSelected: (value) =>
                setState(() => _selectedQuestionFilter = value),
            onVoteFilterSelected: (value) => setState(
                () => _selectedVoteFilter = _normalizedVoteFilter(value)),
          ),
        ),
        const SizedBox(height: 11),
        const Divider(color: AppColors.disabled, height: 1),
      ],
    );
  }
}
