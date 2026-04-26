import 'package:flutter/material.dart';
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

  String _selectedBoardFilter = '최신';
  String _selectedQuestionFilter = '답변 대기중';
  String _selectedVoteFilter = '미정';

  final List<String> _boardFilters = ['최신', '자유', '추천해요', '일상', '분석'];
  final List<String> _questionFilters = ['채택 완료', '답변 대기중', '화제의 질문', '오래된 질문'];
  final List<String> _voteFilters = ['미정'];

  int _currentIndex = 0;
  bool _isFabExtended = true;

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
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: NotificationListener<ScrollNotification>(
          onNotification: (notification) {
            if (notification.metrics.axis == Axis.vertical) {
              if (notification is ScrollUpdateNotification) {
                // 내부 리스트(피드)가 맨 위(0)에 도달했을 때만 펴기
                if (notification.depth > 0 && notification.metrics.pixels <= 0) {
                  if (!_isFabExtended) {
                    setState(() {
                      _isFabExtended = true;
                    });
                  }
                } 
                // 스크롤을 내리면(어디서든) 무조건 접기
                else if (notification.scrollDelta != null && notification.scrollDelta! > 0) {
                  if (_isFabExtended) {
                    setState(() {
                      _isFabExtended = false;
                    });
                  }
                }
              }
            }
            return false;
          },
          child: NestedScrollView(
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
                              icon: const Icon(Icons.search, color: Colors.black),
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
            children: [
              BoardScreen(selectedFilter: _selectedBoardFilter),
              QuestionScreen(selectedFilter: _selectedQuestionFilter),
              VoteScreen(selectedFilter: _selectedVoteFilter),
            ],
          ),
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
            onTap: () {},
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: _isFabExtended ? 20.0 : 16.0),
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
        itemCount: _boardFilters.length,
        itemBuilder: (context, index) {
          final filter = _boardFilters[index];
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
        itemCount: _questionFilters.length,
        itemBuilder: (context, index) {
          final filter = _questionFilters[index];
          return Padding(
            padding: const EdgeInsets.only(right: 16.0),
            child: _buildQuestionSubTab(filter),
          );
        },
      );
    } else {
      return ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16.0),
        itemCount: _voteFilters.length,
        itemBuilder: (context, index) {
          final filter = _voteFilters[index];
          return Padding(
            padding: const EdgeInsets.only(right: 16.0),
            child: _buildQuestionSubTab(filter),
          );
        },
      );
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
