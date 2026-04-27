import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:parrokit/core/router/app_routes.dart';
import 'package:parrokit/core/theme/app_spacing.dart';
import '../domain/data/community_filters.dart';
import 'board_screen.dart';
import 'question_screen.dart';
import 'vote_screen.dart';

class CommunityScreen extends StatefulWidget {
  const CommunityScreen({super.key});

  @override
  State<CommunityScreen> createState() => _CommunityScreenState();
}

class _CommunityScreenState extends State<CommunityScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final ScrollController _outerScrollController = ScrollController();

  String _selectedBoardFilter = CommunityFilters.defaultBoard;
  String _selectedQuestionFilter = CommunityFilters.defaultQuestion;
  String _selectedVoteFilter = CommunityFilters.defaultVote;

  int _currentIndex = 0;
  bool _isFabExtended = true;
  bool _headerVisible = true; // 헤더(탭바) 노출 여부

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _tabController.addListener(() {
      if (_currentIndex != _tabController.index) {
        setState(() {
          _currentIndex = _tabController.index;
        });
      }
    });
    _outerScrollController.addListener(_checkHeaderVisibility);
  }

  void _checkHeaderVisibility() {
    // offset 0 = 헤더 완전히 펼쳐짐, offset > 0 = 헤더가 접히기 시작
    final fullyVisible = _outerScrollController.offset <= 1.0;
    if (_headerVisible != fullyVisible) {
      setState(() {
        _headerVisible = fullyVisible;
        // FAB 텍스트는 헤더 완전 노출 상태와 동일하게 동기화
        _isFabExtended = fullyVisible;
      });
    }
  }

  @override
  void dispose() {
    _outerScrollController.removeListener(_checkHeaderVisibility);
    _outerScrollController.dispose();
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: NestedScrollView(
          controller: _outerScrollController,
          floatHeaderSlivers: true,
          headerSliverBuilder: (context, innerBoxIsScrolled) {
            return [
              SliverPersistentHeader(
                floating: true,
                delegate: _CommunityHeaderDelegate(
                  titleWidget: Padding(
                    padding: const EdgeInsets.fromLTRB(16.0, 4.0, 4.0, 4.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          '커뮤니티',
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: Colors.black,
                          ),
                        ),
                        Row(
                          children: [
                            IconButton(
                              icon:
                                  const Icon(Icons.search, color: Colors.black),
                              onPressed: () {},
                            ),
                            IconButton(
                              icon: const Icon(Icons.notifications_none,
                                  color: Colors.black),
                              onPressed: () {},
                            ),
                            IconButton(
                              icon: const Icon(Icons.menu, color: Colors.black),
                              onPressed: () {},
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  zone1Widget: TabBar(
                    controller: _tabController,
                    isScrollable: true,
                    tabAlignment: TabAlignment.start,
                    labelColor: Colors.black,
                    labelStyle: const TextStyle(
                        fontSize: 18, fontWeight: FontWeight.bold),
                    unselectedLabelColor: Colors.grey,
                    unselectedLabelStyle: const TextStyle(
                        fontSize: 18, fontWeight: FontWeight.bold),
                    indicatorColor: Colors.black,
                    indicatorSize: TabBarIndicatorSize.label,
                    dividerColor: Colors.transparent,
                    padding: EdgeInsets.zero,
                    labelPadding: const EdgeInsets.symmetric(horizontal: 16.0),
                    tabs: const [
                      Tab(text: '게시판'),
                      Tab(text: '질문'),
                      Tab(text: '투표'),
                    ],
                  ),
                  zone2Widget: Column(
                    children: [
                      const SizedBox(height: 12),
                      SizedBox(
                        height: 36,
                        child: _buildZone2Filters(),
                      ),
                      const SizedBox(height: 11),
                      const Divider(color: Color(0xFFEEEEEE), height: 1),
                    ],
                  ),
                ),
              ),
            ];
          },
          body: TabBarView(
            controller: _tabController,
            // 헤더가 완전히 보일 때만 탭 스와이프 허용
            physics: _headerVisible
                ? const AlwaysScrollableScrollPhysics()
                : const NeverScrollableScrollPhysics(),
            children: [
              BoardScreen(selectedFilter: _selectedBoardFilter),
              QuestionScreen(selectedFilter: _selectedQuestionFilter),
              VoteScreen(
                selectedFilter: _selectedVoteFilter,
                swipeEnabled: !_headerVisible,
              ),
            ],
          ),
        ),
      ),
      floatingActionButton: AnimatedContainer(
        duration: const Duration(milliseconds: 250),
        curve: Curves.easeInOut,
        height: 56,
        decoration: BoxDecoration(
          color: Colors.blue[600],
          borderRadius: BorderRadius.circular(28),
          boxShadow: const [
            BoxShadow(
              color: Colors.black26,
              blurRadius: 4,
              offset: Offset(0, 2),
            ),
          ],
        ),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            borderRadius: BorderRadius.circular(28),
            onTap: _showWriteBottomSheet,
            child: Padding(
              padding: EdgeInsets.symmetric(
                  horizontal: _isFabExtended ? 20.0 : 16.0),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.add, color: Colors.white, size: 24),
                  AnimatedSize(
                    duration: const Duration(milliseconds: 250),
                    curve: Curves.easeInOut,
                    child: SizedBox(
                      width: _isFabExtended ? null : 0,
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const SizedBox(width: 8),
                          const Text(
                            '글쓰기',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.clip,
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildZone2Filters() {
    if (_tabController.index == 0) {
      return ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16.0),
        itemCount: CommunityFilters.board.length,
        itemBuilder: (context, index) {
          final filter = CommunityFilters.board[index];
          return Padding(
            padding: const EdgeInsets.only(right: 8.0),
            child: _buildBoardChip(filter),
          );
        },
      );
    } else if (_tabController.index == 1) {
      return ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16.0),
        itemCount: CommunityFilters.question.length,
        itemBuilder: (context, index) {
          final filter = CommunityFilters.question[index];
          return Padding(
            padding: const EdgeInsets.only(right: 16.0),
            child: _buildQuestionSubTab(filter),
          );
        },
      );
    } else {
      return _buildVoteToggle();
    }
  }

  Widget _buildBoardChip(String label) {
    final isSelected = _selectedBoardFilter == label;
    final isDropdown = label == '최신';

    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedBoardFilter = label;
        });
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14),
        decoration: BoxDecoration(
          color: isSelected ? Colors.blue[600] : Colors.grey[100],
          borderRadius: BorderRadius.circular(18),
        ),
        alignment: Alignment.center,
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              label,
              style: TextStyle(
                color: isSelected ? Colors.white : Colors.black87,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.w600,
                fontSize: 14,
              ),
            ),
            if (isDropdown) ...[
              const SizedBox(width: 4),
              Icon(Icons.keyboard_arrow_down,
                  color: isSelected ? Colors.white : Colors.black87, size: 18),
            ]
          ],
        ),
      ),
    );
  }

  Widget _buildQuestionSubTab(String title) {
    final isSelected = _tabController.index == 1
        ? _selectedQuestionFilter == title
        : _selectedVoteFilter == title;

    return GestureDetector(
      onTap: () {
        setState(() {
          if (_tabController.index == 1) {
            _selectedQuestionFilter = title;
          } else {
            _selectedVoteFilter = title;
          }
        });
      },
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 4.0),
        decoration: BoxDecoration(
          border: Border(
            bottom: BorderSide(
              color: isSelected ? Colors.blue[600]! : Colors.transparent,
              width: 2.0,
            ),
          ),
        ),
        child: Center(
          child: Text(
            title,
            style: TextStyle(
              fontSize: 15,
              fontWeight: isSelected ? FontWeight.bold : FontWeight.w600,
              color: isSelected ? Colors.black : Colors.grey[500],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildVoteToggle() {
    final cs = Theme.of(context).colorScheme;
    final isRandom = _selectedVoteFilter == CommunityFilters.vote[0];
    const h = 36.0;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
      child: SizedBox(
        height: h,
        child: Stack(
          children: [
            // 슬라이딩 배경
            AnimatedAlign(
              alignment:
                  isRandom ? Alignment.centerLeft : Alignment.centerRight,
              duration: const Duration(milliseconds: 250),
              curve: Curves.easeInOut,
              child: FractionallySizedBox(
                widthFactor: 0.5,
                child: Container(
                  height: h,
                  decoration: BoxDecoration(
                    color: Colors.blue[600],
                    borderRadius: BorderRadius.circular(6),
                  ),
                ),
              ),
            ),
            // 버튼들
            Row(
              children: [
                // 랜덤 보기
                Expanded(
                  child: GestureDetector(
                    onTap: () => setState(
                        () => _selectedVoteFilter = CommunityFilters.vote[0]),
                    behavior: HitTestBehavior.opaque,
                    child: Center(
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.style_rounded,
                              size: 16,
                              color: isRandom
                                  ? Colors.white
                                  : cs.onSurface.withValues(alpha: 0.4)),
                          const SizedBox(width: 6),
                          Text(CommunityFilters.vote[0],
                              style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.bold,
                                  color: isRandom
                                      ? Colors.white
                                      : cs.onSurface.withValues(alpha: 0.4))),
                        ],
                      ),
                    ),
                  ),
                ),
                // 한눈에 보기
                Expanded(
                  child: GestureDetector(
                    onTap: () => setState(
                        () => _selectedVoteFilter = CommunityFilters.vote[1]),
                    behavior: HitTestBehavior.opaque,
                    child: Center(
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.menu,
                              size: 16,
                              color: !isRandom
                                  ? Colors.white
                                  : cs.onSurface.withValues(alpha: 0.4)),
                          const SizedBox(width: 6),
                          Text(CommunityFilters.vote[1],
                              style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.bold,
                                  color: !isRandom
                                      ? Colors.white
                                      : cs.onSurface.withValues(alpha: 0.4))),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _showWriteBottomSheet() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) {
        return SafeArea(
          child: Padding(
            padding:
                const EdgeInsets.only(left: 24.0, right: 24.0, bottom: 32.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  '커뮤니티 글쓰기',
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                ),
                const SizedBox(height: 20),
                _buildWriteOption(
                  icon: Icons.edit_rounded,
                  iconColor: Colors.blue[600]!,
                  bgColor: Colors.blue[50]!,
                  title: '게시판 작성',
                  subtitle: '자유롭게 대화해보세요',
                  onTap: () {
                    Navigator.pop(context);
                    context.push(AppRoutes.communityBoardWritePath);
                  },
                ),
                const SizedBox(height: 12),
                _buildWriteOption(
                  icon: Icons.live_help_rounded,
                  iconColor: Colors.orange[500]!,
                  bgColor: Colors.orange[50]!,
                  title: '질문하기',
                  subtitle: '모르는 지식을 습득해보세요',
                  onTap: () {
                    Navigator.pop(context);
                  },
                ),
                const SizedBox(height: 12),
                _buildWriteOption(
                  icon: Icons.how_to_vote_rounded,
                  iconColor: Colors.amber[500]!,
                  bgColor: Colors.amber[50]!,
                  title: '투표 만들기',
                  subtitle: '투표를 진행하여 다양한 의견을 받아보세요',
                  onTap: () {
                    Navigator.pop(context);
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildWriteOption({
    required IconData icon,
    required Color iconColor,
    required Color bgColor,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8.0),
        child: Row(
          children: [
            Container(
              width: 52,
              height: 52,
              decoration: BoxDecoration(
                color: bgColor,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Icon(icon, color: iconColor, size: 28),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey[500],
                    ),
                  ),
                ],
              ),
            ),
            Icon(Icons.chevron_right, color: Colors.grey[400], size: 28),
          ],
        ),
      ),
    );
  }
}

class _CommunityHeaderDelegate extends SliverPersistentHeaderDelegate {
  final double titleHeight = 56.0;
  final double zone1Height = 48.0;
  final double zone2Height = 60.0;

  final Widget titleWidget;
  final Widget zone1Widget;
  final Widget zone2Widget;

  _CommunityHeaderDelegate({
    required this.titleWidget,
    required this.zone1Widget,
    required this.zone2Widget,
  });

  @override
  double get minExtent => 0;

  @override
  double get maxExtent => titleHeight + zone1Height + zone2Height;

  @override
  Widget build(
      BuildContext context, double shrinkOffset, bool overlapsContent) {
    // 1. 타이틀 영역 처리
    double titleTop = -shrinkOffset;

    // 2. 1구역(게시판 탭) 영역 처리
    // 타이틀이 사라지는 동안에는 타이틀 바로 아래 위치
    // 타이틀이 사라지고 2구역이 숨겨지는 동안에는 상단에 고정 (0)
    // 2구역이 다 숨겨지면 화면 밖으로 스크롤 아웃
    double zone1Top;
    if (shrinkOffset <= titleHeight) {
      zone1Top = titleHeight - shrinkOffset;
    } else if (shrinkOffset <= titleHeight + zone2Height) {
      zone1Top = 0;
    } else {
      zone1Top = -(shrinkOffset - (titleHeight + zone2Height));
    }

    // 3. 2구역(필터) 영역 처리
    // 자연스럽게 스크롤을 따라 올라감 (결과적으로 1구역 아래로 미끄러져 들어감)
    double zone2Top = (titleHeight + zone1Height) - shrinkOffset;

    return Container(
      color: Colors.white,
      child: Stack(
        clipBehavior: Clip.hardEdge,
        children: [
          // 2구역 (Background, 1구역 아래로 들어가야 하므로 가장 먼저 배치)
          Positioned(
            top: zone2Top,
            left: 0,
            right: 0,
            height: zone2Height,
            child: Container(
              color: Colors.white,
              child: zone2Widget,
            ),
          ),
          // 타이틀 (Background)
          Positioned(
            top: titleTop,
            left: 0,
            right: 0,
            height: titleHeight,
            child: Container(
              color: Colors.white,
              child: titleWidget,
            ),
          ),
          // 1구역 (Foreground, 2구역을 가려야 함)
          Positioned(
            top: zone1Top,
            left: 0,
            right: 0,
            height: zone1Height,
            child: Container(
              color: Colors.white,
              child: zone1Widget,
            ),
          ),
        ],
      ),
    );
  }

  @override
  bool shouldRebuild(covariant _CommunityHeaderDelegate oldDelegate) {
    return true;
  }
}
