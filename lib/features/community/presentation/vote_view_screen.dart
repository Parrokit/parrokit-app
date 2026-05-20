// ============================================================================
// lib/features/community/presentation/vote_view_screen.dart
// ============================================================================
//
// [역할]
// 투표 상세 보기 및 토론 피드 화면.
// 상단에 투표 카드(VoteCard)를 그대로 노출하여 직관성을 유지하고,
// 하단에 해당 주제에 대한 의견/토론 댓글 리스트와 스티키 입력 창을 배치.
//
// [레이어]
// Presentation Layer > Screens
// ============================================================================

import 'package:flutter/material.dart';
import 'vote_screen.dart';

class VoteViewScreen extends StatefulWidget {
  final int voteId;

  const VoteViewScreen({super.key, required this.voteId});

  @override
  State<VoteViewScreen> createState() => _VoteViewScreenState();
}

class _VoteViewScreenState extends State<VoteViewScreen> {
  // ─────────────────────────────────────────────────────────────────
  // 상태 & 데이터
  // ─────────────────────────────────────────────────────────────────
  late VoteItem _voteItem;
  int? _selectedOption;
  bool _showResult = false;

  final TextEditingController _commentController = TextEditingController();
  late List<_VoteComment> _comments;

  @override
  void initState() {
    super.initState();
    _loadVoteItem();
    _loadMockComments();
  }

  void _loadVoteItem() {
    // ID가 일치하는 투표 항목 찾기 (없으면 첫 번째 항목으로 폴백)
    _voteItem = dummyVotes.firstWhere(
      (v) => v.id == widget.voteId,
      orElse: () => dummyVotes.first,
    );
  }

  void _loadMockComments() {
    // 주제별 맞춤 댓글 생성
    if (_voteItem.id == 1) {
      _comments = [
        _VoteComment(
          author: '워라밸러',
          handle: '@worklife_balance',
          avatarUrl: 'https://picsum.photos/seed/user_work/100/100',
          content: '역시 재택근무가 최고죠. 통근 시간 왕복 2시간 아끼는 것만으로도 저녁 있는 삶이 가능하고 스트레스가 훨씬 덜합니다.',
          timeAgo: '2시간 전',
          likes: 12,
        ),
        _VoteComment(
          author: '협업킹',
          handle: '@collaboration_king',
          avatarUrl: 'https://picsum.photos/seed/user_coll/100/100',
          content: '업무 성격에 따라 달라요. 기획이나 마케팅 브레인스토밍 등 협업이 집중적으로 필요할 때는 사무실에서 페이스투페이스로 얘기하는 게 훨씬 효율적입니다.',
          timeAgo: '1시간 전',
          likes: 8,
        ),
        _VoteComment(
          author: 'HR전문가',
          handle: '@hr_expert',
          avatarUrl: 'https://picsum.photos/seed/user_hr/100/100',
          content: '저희 회사 설문조사 결과로는 주 3회 출근 / 주 2회 재택의 하이브리드가 만족도와 생산성 밸런스 면에서 가장 높은 점수를 받았습니다.',
          timeAgo: '30분 전',
          likes: 5,
        ),
      ];
    } else if (_voteItem.id == 2) {
      _comments = [
        _VoteComment(
          author: '플러터덕후',
          handle: '@flutter_dev',
          avatarUrl: 'https://picsum.photos/seed/user_flut/100/100',
          content: 'Flutter의 고성능 렌더링 엔진과 핫 리로드 기능은 한번 경험하면 정말 벗어나기 어렵습니다. 크로스플랫폼의 최고봉이라고 생각해요.',
          timeAgo: '3시간 전',
          likes: 15,
        ),
        _VoteComment(
          author: 'RN빌더',
          handle: '@rn_builder',
          avatarUrl: 'https://picsum.photos/seed/user_rn/100/100',
          content: '국내 대기업이나 스타트업 채용 시장에서는 아직 자바스크립트 생태계의 강점을 업은 React Native가 채용 풀이 훨씬 넓고 유연합니다.',
          timeAgo: '2시간 전',
          likes: 9,
        ),
      ];
    } else {
      _comments = [
        _VoteComment(
          author: '개발자토끼',
          handle: '@rabbit_coder',
          avatarUrl: 'https://picsum.photos/seed/user_rab/100/100',
          content: '좋은 주제네요! 투표 결과가 어떻게 끝날지 정말 흥미진진하게 보고 있습니다.',
          timeAgo: '5시간 전',
          likes: 4,
        ),
        _VoteComment(
          author: '지나가는행인',
          handle: '@passer_by',
          avatarUrl: 'https://picsum.photos/seed/user_pass/100/100',
          content: '이견이 꽤 갈릴 수 있는 문제 같은데 댓글창 보면서 다양한 관점 배워가네요.',
          timeAgo: '4시간 전',
          likes: 2,
        ),
      ];
    }
  }

  void _submitComment() {
    final text = _commentController.text.trim();
    if (text.isEmpty) return;

    setState(() {
      _comments.insert(
        0, // 최신 댓글을 맨 위에 추가
        _VoteComment(
          author: '나의계정',
          handle: '@my_account',
          avatarUrl: 'https://picsum.photos/seed/myaccount/100/100',
          content: text,
          timeAgo: '방금 전',
          likes: 0,
        ),
      );
      _commentController.clear();
    });

    FocusScope.of(context).unfocus();
  }

  // ─────────────────────────────────────────────────────────────────
  // Build
  // ─────────────────────────────────────────────────────────────────
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        scrolledUnderElevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.black, size: 20),
          onPressed: () => Navigator.maybePop(context),
        ),
        title: const Text(
          '투표 상세 토론',
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold, fontSize: 16),
        ),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Container(color: const Color(0xFFF1F3F5), height: 1),
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // 투표 카드 표시
                  Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: VoteCard(
                      item: _voteItem,
                      selectedOption: _selectedOption,
                      showResult: _showResult,
                      onSelect: (idx) {
                        setState(() {
                          _selectedOption = idx;
                        });
                      },
                      onToggleResult: () {
                        setState(() {
                          _showResult = !_showResult;
                        });
                      },
                    ),
                  ),

                  // Divider
                  Container(
                    height: 8,
                    color: const Color(0xFFF1F3F5),
                  ),

                  // Comments section header
                  Padding(
                    padding: const EdgeInsets.fromLTRB(16, 20, 16, 8),
                    child: Text(
                      '토론 & 의견 (${_comments.length})',
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF212529),
                      ),
                    ),
                  ),

                  // List of comments
                  if (_comments.isEmpty)
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 40.0),
                      child: Center(
                        child: Text(
                          '첫 의견을 작성해 투표 토론에 참여해보세요!',
                          style: TextStyle(color: Colors.grey[500], fontSize: 14),
                        ),
                      ),
                    )
                  else
                    ListView.separated(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: _comments.length,
                      separatorBuilder: (context, index) => const Divider(
                        color: Color(0xFFF1F3F5),
                        height: 1,
                      ),
                      itemBuilder: (context, index) {
                        final comment = _comments[index];
                        return _buildCommentItem(comment);
                      },
                    ),
                ],
              ),
            ),
          ),

          // Sticky Reply Input Bar
          _buildStickyReplyBar(),
        ],
      ),
    );
  }

  Widget _buildCommentItem(_VoteComment comment) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CircleAvatar(
            radius: 18,
            backgroundImage: NetworkImage(comment.avatarUrl),
            backgroundColor: const Color(0xFFF1F3F5),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.baseline,
                  textBaseline: TextBaseline.alphabetic,
                  children: [
                    Text(
                      comment.author,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                        color: Color(0xFF212529),
                      ),
                    ),
                    const SizedBox(width: 6),
                    Text(
                      comment.handle,
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey[500],
                      ),
                    ),
                    const Spacer(),
                    Text(
                      comment.timeAgo,
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey[400],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                Text(
                  comment.content,
                  style: const TextStyle(
                    fontSize: 14,
                    color: Color(0xFF495057),
                    height: 1.45,
                  ),
                ),
                const SizedBox(height: 12),
                // Comment Actions (Like button)
                Row(
                  children: [
                    InkWell(
                      onTap: () {
                        setState(() {
                          comment.likes++;
                        });
                      },
                      child: Row(
                        children: [
                          Icon(
                            Icons.favorite_border_rounded,
                            size: 15,
                            color: Colors.grey[400],
                          ),
                          const SizedBox(width: 4),
                          Text(
                            '${comment.likes}',
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey[500],
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStickyReplyBar() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, -4),
          ),
        ],
        border: const Border(
          top: BorderSide(color: Color(0xFFE9ECEF), width: 1),
        ),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      child: SafeArea(
        child: Row(
          children: [
            const CircleAvatar(
              radius: 16,
              backgroundImage: NetworkImage('https://picsum.photos/seed/composer/100/100'),
              backgroundColor: Color(0xFFF1F3F5),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Container(
                decoration: BoxDecoration(
                  color: const Color(0xFFF1F3F5),
                  borderRadius: BorderRadius.circular(20),
                ),
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: TextField(
                  controller: _commentController,
                  decoration: const InputDecoration(
                    hintText: '투표 의견 남기기...',
                    border: InputBorder.none,
                    focusedBorder: InputBorder.none,
                    enabledBorder: InputBorder.none,
                    isDense: true,
                    contentPadding: EdgeInsets.symmetric(vertical: 8.0),
                  ),
                  style: const TextStyle(fontSize: 14),
                ),
              ),
            ),
            const SizedBox(width: 8),
            IconButton(
              icon: Icon(
                Icons.send_rounded,
                color: Colors.blue[600],
                size: 22,
              ),
              onPressed: _submitComment,
            ),
          ],
        ),
      ),
    );
  }
}

class _VoteComment {
  final String author;
  final String handle;
  final String avatarUrl;
  final String content;
  final String timeAgo;
  int likes;

  _VoteComment({
    required this.author,
    required this.handle,
    required this.avatarUrl,
    required this.content,
    required this.timeAgo,
    required this.likes,
  });
}
