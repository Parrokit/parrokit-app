import 'dart:math';
import 'package:flutter/material.dart';

class CommunityScreen extends StatefulWidget {
  const CommunityScreen({super.key});

  @override
  State<CommunityScreen> createState() => _CommunityScreenState();
}

class _CommunityScreenState extends State<CommunityScreen> {
  String _selectedFilter = '최신'; // '최신' means 'All'
  late List<_PostData> _allPosts;

  @override
  void initState() {
    super.initState();
    _generateRandomPosts();
  }

  void _generateRandomPosts() {
    final random = Random();
    final nicknames = ['춘배', '아무것도하기', '지나가는행인', '개발자', '고양이', '토끼', '플러터'];

    String getRandomNickname() => nicknames[random.nextInt(nicknames.length)];

    String getRandomTimeAgo() {
      if (random.nextBool()) {
        return '${random.nextInt(23) + 1}시간 전';
      } else {
        return '${random.nextInt(6) + 1}일 전';
      }
    }

    _allPosts = [
      _PostData(
        category: '추천해요',
        title: '플래시 시즌 2 13화 부분에서 괜찮은 문장 찾음',
        snippet:
            '친구랑 밥먹으러가자고 할 때, 나는 보통 뭐라고 할지 잘 생각 안나는데 여기 나와 있는 대사들이 정말 실생활에서 쓰기 좋고 자연스럽게 느껴졌어요. 꼭 한 번 다시 보면서 따라해보고 싶네요.',
        author: getRandomNickname(),
        timeAgo: getRandomTimeAgo(),
        viewCount: random.nextInt(1000),
        likeCount: random.nextInt(50),
        commentCount: random.nextInt(20),
      ),
      _PostData(
        category: '자유',
        title: '비 오니까 국물 있는 게 땡기네요 ㅋㅋ',
        snippet:
            '오늘 날씨가 좀 꾸리꾸리해서 그런가... 점심부터 계속 칼국수나 짬뽕 생각만 나네요. 근처에 맛있는 국물 요리집 아시는 분 계신가요? 비오는 날에는 역시 얼큰한 게 최고인 것 같습니다.',
        author: getRandomNickname(),
        timeAgo: getRandomTimeAgo(),
        viewCount: random.nextInt(1000),
        likeCount: random.nextInt(50),
        commentCount: random.nextInt(20),
      ),
      _PostData(
        category: '일상',
        title: '와... 오늘 아침에 진짜 역대급으로 늦잠 잤네',
        snippet:
            '분명히 알람 5개 맞췄는데 하나도 못 듣고 쥐죽은 듯이 잤는데.. ㅠㅠ 겨우 씻고 나와서 지금 정신없이 버스 타고 가는 중입니다. 이런 날은 진짜 하루 종일 피곤하더라고요.',
        author: getRandomNickname(),
        timeAgo: getRandomTimeAgo(),
        viewCount: random.nextInt(1000),
        likeCount: random.nextInt(50),
        commentCount: random.nextInt(20),
      ),
      _PostData(
        category: '자유',
        title: '넷플릭스에 볼 거 왜 이렇게 없죠?',
        snippet:
            '한 시간째 메인 화면만 스크롤하고 있네요... 다들 요즘 뭐 보세요? 너무 무거운 주제보다는 가볍게 웃으면서 볼 수 있는 킬링타임용 코미디 영화나 시트콤 같은 거 있으면 추천 좀 부탁드립니다!',
        author: getRandomNickname(),
        timeAgo: getRandomTimeAgo(),
        viewCount: random.nextInt(1000),
        likeCount: random.nextInt(50),
        commentCount: random.nextInt(20),
      ),
      _PostData(
        category: '분석',
        title: '요즘 넷플릭스 자막이랑 실제 대사랑 다른 거 저만 느끼나요?',
        snippet:
            '제 스파이 패밀리 보는데, 캐릭터가 말하는 뉘앙스랑 자막 번역이 묘하게 달라서 몰입이 살짝 깨지는 느낌이네요. 원래 일본어 표현이 조금 더 귀여운 것 같은데 한국어로 오면서 약간 딱딱해진 것 같아요.',
        author: getRandomNickname(),
        timeAgo: getRandomTimeAgo(),
        viewCount: random.nextInt(1000),
        likeCount: random.nextInt(50),
        commentCount: random.nextInt(20),
      ),
    ];
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 3,
      child: Scaffold(
        backgroundColor: Colors.white,
        body: SafeArea(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Top App Bar
              Padding(
                padding: const EdgeInsets.fromLTRB(16.0, 8.0, 8.0, 8.0),
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

              // Tab Bar
              const TabBar(
                isScrollable: true,
                tabAlignment: TabAlignment.start,
                labelColor: Colors.black,
                labelStyle:
                    TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                unselectedLabelColor: Colors.grey,
                unselectedLabelStyle:
                    TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                indicatorColor: Colors.black,
                indicatorSize: TabBarIndicatorSize.label,
                dividerColor: Colors.transparent,
                padding: EdgeInsets.zero,
                labelPadding: EdgeInsets.symmetric(horizontal: 16.0),
                tabs: [
                  Tab(text: '게시판'),
                  Tab(text: '질문'),
                  Tab(text: '투표'),
                ],
              ),
              const SizedBox(height: 8),

              // Filter Chips
              SizedBox(
                height: 36,
                child: ListView(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  children: [
                    _buildFilterChip('최신', isDropdown: true),
                    const SizedBox(width: 8),
                    _buildFilterChip('자유'),
                    const SizedBox(width: 8),
                    _buildFilterChip('추천해요'),
                    const SizedBox(width: 8),
                    _buildFilterChip('일상'),
                    const SizedBox(width: 8),
                    _buildFilterChip('분석'),
                  ],
                ),
              ),
              const Divider(color: Color(0xFFEEEEEE), height: 32),

              // Post List
              Expanded(
                child: TabBarView(
                  children: [
                    _buildPostList(),
                    const Center(child: Text('질문 탭')),
                    const Center(child: Text('투표 탭')),
                  ],
                ),
              ),
            ],
          ),
        ),
        floatingActionButton: FloatingActionButton.extended(
          onPressed: () {},
          backgroundColor: Colors.blue[600],
          foregroundColor: Colors.white,
          elevation: 2,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(30),
          ),
          icon: const Icon(Icons.add, size: 24),
          label: const Text(
            '글쓰기',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildFilterChip(String label, {bool isDropdown = false}) {
    final isSelected = _selectedFilter == label;

    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedFilter = label;
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

  Widget _buildPostList() {
    final filteredPosts = _selectedFilter == '최신'
        ? _allPosts
        : _allPosts.where((p) => p.category == _selectedFilter).toList();

    if (filteredPosts.isEmpty) {
      return Center(
        child: Text(
          '등록된 게시글이 없습니다.',
          style: TextStyle(color: Colors.grey[600], fontSize: 16),
        ),
      );
    }

    return ListView.separated(
      padding: const EdgeInsets.only(bottom: 16),
      itemCount: filteredPosts.length,
      separatorBuilder: (context, index) =>
          const Divider(color: Color(0xFFEEEEEE), height: 1),
      itemBuilder: (context, index) {
        return _buildPostItem(filteredPosts[index]);
      },
    );
  }

  Widget _buildPostItem(_PostData post) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
            decoration: BoxDecoration(
              color: Colors.grey[100],
              borderRadius: BorderRadius.circular(4),
            ),
            child: Text(
              post.category,
              style: TextStyle(
                fontSize: 11,
                color: Colors.grey[700],
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            post.title,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color: Colors.black,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            post.snippet,
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[600],
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '${post.author} · ${post.timeAgo}',
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey[500],
                ),
              ),
              Row(
                children: [
                  Icon(Icons.remove_red_eye, size: 14, color: Colors.grey[400]),
                  const SizedBox(width: 4),
                  Text('${post.viewCount}',
                      style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey[500],
                          fontWeight: FontWeight.w600)),
                  const SizedBox(width: 12),
                  Icon(Icons.thumb_up, size: 14, color: Colors.grey[400]),
                  const SizedBox(width: 4),
                  Text('${post.likeCount}',
                      style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey[500],
                          fontWeight: FontWeight.w600)),
                  const SizedBox(width: 12),
                  Icon(Icons.chat_bubble, size: 14, color: Colors.grey[400]),
                  const SizedBox(width: 4),
                  Text('${post.commentCount}',
                      style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey[500],
                          fontWeight: FontWeight.w600)),
                ],
              )
            ],
          )
        ],
      ),
    );
  }
}

class _PostData {
  final String category;
  final String title;
  final String snippet;
  final String author;
  final String timeAgo;
  final int viewCount;
  final int likeCount;
  final int commentCount;

  _PostData({
    required this.category,
    required this.title,
    required this.snippet,
    required this.author,
    required this.timeAgo,
    required this.viewCount,
    required this.likeCount,
    required this.commentCount,
  });
}
