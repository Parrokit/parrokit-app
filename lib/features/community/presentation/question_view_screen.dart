// ============================================================================
// lib/features/community/presentation/question_view_screen.dart
// ============================================================================
//
// [역할]
// 트위터(X) 스레드 스타일의 Q&A 상세 화면.
// 질문글을 메인 트윗(Main Tweet) 형태로 배치하고, 하단 답변들을 댓글 스레드 형식으로 연동.
// 스레드 아바타 연결선, 인라인 아이콘 동작, 하단 고정 답글창(Sticky Reply Bar) 제공.
//
// [레이어]
// Presentation Layer > Screens
// ============================================================================

import 'package:flutter/material.dart';

class QuestionViewScreen extends StatefulWidget {
  final int questionId;

  const QuestionViewScreen({super.key, required this.questionId});

  @override
  State<QuestionViewScreen> createState() => _QuestionViewScreenState();
}

class _QuestionViewScreenState extends State<QuestionViewScreen> {
  // ─────────────────────────────────────────────────────────────────
  // 상태 & 데이터 (Mock)
  // ─────────────────────────────────────────────────────────────────
  late _TwitterQuestionData _question;
  late List<_TwitterAnswerData> _answers;

  final TextEditingController _replyController = TextEditingController();

  bool _isLiked = false;
  bool _isBookmarked = false;

  @override
  void initState() {
    super.initState();
    _loadMockQuestionDetail();
  }

  void _loadMockQuestionDetail() {
    final isResolved = widget.questionId % 2 == 0;
    _question = _TwitterQuestionData(
      id: widget.questionId,
      author: '플러터초보_${widget.questionId}',
      handle: '@flutter_novice_${widget.questionId}',
      authorAvatar: 'https://picsum.photos/seed/user${widget.questionId}/100/100',
      timeAgo: '오후 5:32 · 2026년 5월 20일',
      title: '영국식 발음과 미국식 발음 중 어떤 것을 쉐도잉하는 게 좋을까요?',
      content: '비즈니스 영어 실력을 기르려고 쉐도잉을 새로 시작하려 합니다. 영드 셜록이나 미드 오피스 중 무엇을 골라야 할지 고민입니다. 주로 비즈니스 실무에서는 어떤 억양이 더 널리 쓰이나요?',
      targetExpression: 'Business Accents (UK vs US)',
      category: '발음/스피킹',
      views: 148 + widget.questionId * 12,
      upvotes: 24,
      isResolved: isResolved,
    );

    _answers = [
      _TwitterAnswerData(
        id: 201,
        author: '영어마스터_킴',
        handle: '@eng_master_kim',
        authorAvatar: 'https://picsum.photos/seed/ans1/100/100',
        content: '국제 비즈니스 표준으로는 미국식 영어가 거래처 등에서 가장 널리 통용되지만, 유럽권이나 싱가포르 등 영연방 출신들과 일할 때는 영국식 영어 억양이 매우 큰 신뢰를 줍니다. 셜록은 대사가 지나치게 빠르므로 오피스로 시작해 미국식 기초 발음을 다진 후 영국 뉴스로 귀를 트시는 걸 추천합니다.',
        timeAgo: '2시간 전',
        upvotes: 18,
        isAdopted: isResolved,
        commentsCount: 3,
      ),
      _TwitterAnswerData(
        id: 202,
        author: '실무영어코치',
        handle: '@biz_eng_coach',
        authorAvatar: 'https://picsum.photos/seed/ans2/100/100',
        content: '현직 대기업 통역사입니다. 실제 실무에서는 억양 자체보다 끊어 읽기(Phrasing)와 강세가 훨씬 중요합니다. 영국식이든 미국식이든 본인 목소리 톤에 잘 맞는 캐릭터를 선정해서 시작해 보세요. 남성분이면 오피스의 짐(Jim)을 추천하고, 여성분이면 다양한 비즈니스 롤이 나오는 시트콤이 좋습니다.',
        timeAgo: '1시간 전',
        upvotes: 7,
        isAdopted: false,
        commentsCount: 0,
      ),
    ];
  }

  // ─────────────────────────────────────────────────────────────────
  // Actions
  // ─────────────────────────────────────────────────────────────────
  void _submitReply() {
    final text = _replyController.text.trim();
    if (text.isEmpty) return;

    setState(() {
      _answers.add(_TwitterAnswerData(
        id: DateTime.now().millisecondsSinceEpoch,
        author: '나의계정',
        handle: '@my_account',
        authorAvatar: 'https://picsum.photos/seed/composer/100/100',
        content: text,
        timeAgo: '방금 전',
        upvotes: 0,
        isAdopted: false,
        commentsCount: 0,
      ));
      _replyController.clear();
    });

    FocusScope.of(context).unfocus();
  }

  void _upvoteAnswer(int index) {
    setState(() {
      _answers[index] = _answers[index].copyWith(upvotes: _answers[index].upvotes + 1);
    });
  }

  // ─────────────────────────────────────────────────────────────────
  // Build
  // ─────────────────────────────────────────────────────────────────
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: _buildAppBar(),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  _buildMainQuestionTweet(),
                  _buildDivider(),
                  _buildRepliesSection(),
                ],
              ),
            ),
          ),
          _buildStickyReplyBar(),
        ],
      ),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      backgroundColor: Colors.white,
      elevation: 0,
      scrolledUnderElevation: 0,
      leading: IconButton(
        icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.black, size: 20),
        onPressed: () => Navigator.maybePop(context),
      ),
      title: const Text(
        '질문 스레드',
        style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold, fontSize: 16),
      ),
      bottom: PreferredSize(
        preferredSize: const Size.fromHeight(1),
        child: Container(color: const Color(0xFFF1F3F5), height: 1),
      ),
    );
  }

  Widget _buildMainQuestionTweet() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // User Info Header Row
          Row(
            children: [
              CircleAvatar(
                radius: 22,
                backgroundImage: NetworkImage(_question.authorAvatar),
                backgroundColor: const Color(0xFFF1F3F5),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(
                          _question.author,
                          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Color(0xFF212529)),
                        ),
                        if (_question.isResolved) ...[
                          const SizedBox(width: 4),
                          const Icon(Icons.verified, color: Colors.green, size: 16),
                        ],
                      ],
                    ),
                    Text(
                      _question.handle,
                      style: TextStyle(color: Colors.grey[500], fontSize: 14),
                    ),
                  ],
                ),
              ),
              IconButton(
                icon: const Icon(Icons.more_horiz_rounded, color: Colors.grey),
                onPressed: () {},
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Question Title & Content
          Text(
            _question.title,
            style: const TextStyle(
              fontSize: 19,
              fontWeight: FontWeight.w800,
              color: Color(0xFF212529),
              height: 1.35,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            _question.content,
            style: const TextStyle(
              fontSize: 16,
              color: Color(0xFF495057),
              height: 1.5,
            ),
          ),
          const SizedBox(height: 16),


          // Date & Stats View (Twitter Thread Style)
          Text(
            '${_question.timeAgo} · 조회 ${_question.views}회',
            style: TextStyle(fontSize: 14, color: Colors.grey[500]),
          ),
          const Divider(height: 24, color: Color(0xFFF1F3F5)),

          // Stats summary
          Row(
            children: [
              Text(
                '${_question.upvotes}',
                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: Color(0xFF212529)),
              ),
              const SizedBox(width: 4),
              Text('유용해요', style: TextStyle(color: Colors.grey[500], fontSize: 14)),
              const SizedBox(width: 16),
              Text(
                '${_answers.length}',
                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: Color(0xFF212529)),
              ),
              const SizedBox(width: 4),
              Text('답글', style: TextStyle(color: Colors.grey[500], fontSize: 14)),
            ],
          ),
          const Divider(height: 24, color: Color(0xFFF1F3F5)),

          // Top Action Buttons
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              IconButton(
                icon: const Icon(Icons.mode_comment_outlined, size: 20, color: Color(0xFF65676B)),
                onPressed: () {
                  FocusScope.of(context).requestFocus(FocusNode());
                },
              ),
              IconButton(
                icon: Icon(
                  _isLiked ? Icons.bolt : Icons.bolt_outlined,
                  size: 22,
                  color: _isLiked ? Colors.orange[600] : const Color(0xFF65676B),
                ),
                onPressed: () {
                  setState(() {
                    _isLiked = !_isLiked;
                    if (_isLiked) {
                      _question = _question.copyWith(upvotes: _question.upvotes + 1);
                    } else {
                      _question = _question.copyWith(upvotes: _question.upvotes - 1);
                    }
                  });
                },
              ),
              IconButton(
                icon: Icon(
                  _isBookmarked ? Icons.bookmark : Icons.bookmark_border_rounded,
                  size: 20,
                  color: _isBookmarked ? Colors.orange[600] : const Color(0xFF65676B),
                ),
                onPressed: () {
                  setState(() {
                    _isBookmarked = !_isBookmarked;
                  });
                },
              ),
              IconButton(
                icon: const Icon(Icons.ios_share_rounded, size: 20, color: Color(0xFF65676B)),
                onPressed: () {},
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildDivider() {
    return Container(
      height: 8,
      color: const Color(0xFFF1F3F5),
    );
  }

  Widget _buildRepliesSection() {
    if (_answers.isEmpty) {
      return const Padding(
        padding: EdgeInsets.symmetric(vertical: 40.0),
        child: Center(
          child: Text(
            '아직 답글이 없습니다.\n첫 번째 답글을 남겨보세요!',
            textAlign: TextAlign.center,
            style: TextStyle(color: Colors.grey, height: 1.4),
          ),
        ),
      );
    }

    // Sort to place Adopted Answer at the top
    final sortedReplies = List<_TwitterAnswerData>.from(_answers);
    sortedReplies.sort((a, b) => (b.isAdopted ? 1 : 0).compareTo(a.isAdopted ? 1 : 0));

    return ListView.separated(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: sortedReplies.length,
      separatorBuilder: (context, index) => const Divider(height: 1, color: Color(0xFFF1F3F5)),
      itemBuilder: (context, index) {
        final answer = sortedReplies[index];
        final originalIndex = _answers.indexWhere((element) => element.id == answer.id);
        return _buildReplyItem(answer, originalIndex);
      },
    );
  }

  Widget _buildReplyItem(_TwitterAnswerData answer, int originalIndex) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Left column: Avatar and Thread Connecting Line
          Column(
            children: [
              CircleAvatar(
                radius: 18,
                backgroundImage: NetworkImage(answer.authorAvatar),
                backgroundColor: const Color(0xFFF1F3F5),
                child: answer.authorAvatar.isEmpty
                    ? const Icon(Icons.person, size: 18, color: Colors.white)
                    : null,
              ),
              // Thread vertical line
              Container(
                width: 2,
                height: 40,
                color: const Color(0xFFE9ECEF),
              ),
            ],
          ),
          const SizedBox(width: 12),

          // Right column: User Meta, Content, and Inline Actions
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      answer.author,
                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: Color(0xFF212529)),
                    ),
                    const SizedBox(width: 4),
                    Text(
                      answer.handle,
                      style: TextStyle(color: Colors.grey[500], fontSize: 13),
                    ),
                    const Spacer(),
                    Text(
                      answer.timeAgo,
                      style: TextStyle(color: Colors.grey[400], fontSize: 12),
                    ),
                  ],
                ),
                const SizedBox(height: 4),

                // Adopted badge if verified
                if (answer.isAdopted) ...[
                  Container(
                    margin: const EdgeInsets.symmetric(vertical: 4),
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                    decoration: BoxDecoration(
                      color: Colors.green[50],
                      borderRadius: BorderRadius.circular(6),
                      border: Border.all(color: Colors.green[200]!),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: const [
                        Icon(Icons.verified, color: Colors.green, size: 12),
                        SizedBox(width: 4),
                        Text(
                          '채택된 답변',
                          style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.green),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 4),
                ],

                // Reply text
                Text(
                  answer.content,
                  style: const TextStyle(fontSize: 15, color: Color(0xFF343A40), height: 1.45),
                ),
                const SizedBox(height: 12),

                // Reply Actions Row
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        IconButton(
                          icon: const Icon(Icons.mode_comment_outlined, size: 16, color: Color(0xFF65676B)),
                          onPressed: () {},
                          padding: EdgeInsets.zero,
                          constraints: const BoxConstraints(),
                        ),
                        const SizedBox(width: 4),
                        Text(
                          '${answer.commentsCount}',
                          style: TextStyle(color: Colors.grey[500], fontSize: 12),
                        ),
                      ],
                    ),
                    Row(
                      children: [
                        IconButton(
                          icon: const Icon(Icons.bolt_outlined, size: 18, color: Color(0xFF65676B)),
                          onPressed: () => _upvoteAnswer(originalIndex),
                          padding: EdgeInsets.zero,
                          constraints: const BoxConstraints(),
                        ),
                        const SizedBox(width: 4),
                        Text(
                          '${answer.upvotes}',
                          style: TextStyle(color: Colors.grey[500], fontSize: 12),
                        ),
                      ],
                    ),
                    IconButton(
                      icon: const Icon(Icons.ios_share_rounded, size: 16, color: Color(0xFF65676B)),
                      onPressed: () {},
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(),
                    ),

                    // Adopt Button (only visible if the question is not resolved yet and viewer is author)
                    if (!_question.isResolved)
                      GestureDetector(
                        onTap: () {
                          setState(() {
                            _question = _question.copyWith(isResolved: true);
                            _answers[originalIndex] = _answers[originalIndex].copyWith(isAdopted: true);
                          });
                        },
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: Colors.green[50],
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: const Text(
                            '채택하기',
                            style: TextStyle(color: Colors.green, fontSize: 11, fontWeight: FontWeight.bold),
                          ),
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
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(top: BorderSide(color: Color(0xFFF1F3F5))),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      child: SafeArea(
        child: Row(
          children: [
            const CircleAvatar(
              radius: 14,
              backgroundImage: NetworkImage('https://picsum.photos/seed/composer/100/100'),
              backgroundColor: Color(0xFFF1F3F5),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: TextField(
                controller: _replyController,
                decoration: const InputDecoration(
                  hintText: '답글 남기기...',
                  hintStyle: TextStyle(fontSize: 14, color: Color(0xFFADB5BD)),
                  border: InputBorder.none,
                ),
                style: const TextStyle(fontSize: 14),
              ),
            ),
            TextButton(
              onPressed: _submitReply,
              child: Text(
                '답글',
                style: TextStyle(
                  color: Colors.orange[600],
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Data Models
// ─────────────────────────────────────────────────────────────────────────────

class _TwitterQuestionData {
  final int id;
  final String author;
  final String handle;
  final String authorAvatar;
  final String timeAgo;
  final String title;
  final String content;
  final String targetExpression;
  final String category;
  final int views;
  final int upvotes;
  final bool isResolved;

  _TwitterQuestionData({
    required this.id,
    required this.author,
    required this.handle,
    required this.authorAvatar,
    required this.timeAgo,
    required this.title,
    required this.content,
    required this.targetExpression,
    required this.category,
    required this.views,
    required this.upvotes,
    required this.isResolved,
  });

  _TwitterQuestionData copyWith({
    int? id,
    String? author,
    String? handle,
    String? authorAvatar,
    String? timeAgo,
    String? title,
    String? content,
    String? targetExpression,
    String? category,
    int? views,
    int? upvotes,
    bool? isResolved,
  }) {
    return _TwitterQuestionData(
      id: id ?? this.id,
      author: author ?? this.author,
      handle: handle ?? this.handle,
      authorAvatar: authorAvatar ?? this.authorAvatar,
      timeAgo: timeAgo ?? this.timeAgo,
      title: title ?? this.title,
      content: content ?? this.content,
      targetExpression: targetExpression ?? this.targetExpression,
      category: category ?? this.category,
      views: views ?? this.views,
      upvotes: upvotes ?? this.upvotes,
      isResolved: isResolved ?? this.isResolved,
    );
  }
}

class _TwitterAnswerData {
  final int id;
  final String author;
  final String handle;
  final String authorAvatar;
  final String content;
  final String timeAgo;
  final int upvotes;
  final bool isAdopted;
  final int commentsCount;

  _TwitterAnswerData({
    required this.id,
    required this.author,
    required this.handle,
    required this.authorAvatar,
    required this.content,
    required this.timeAgo,
    required this.upvotes,
    required this.isAdopted,
    required this.commentsCount,
  });

  _TwitterAnswerData copyWith({
    int? id,
    String? author,
    String? handle,
    String? authorAvatar,
    String? content,
    String? timeAgo,
    int? upvotes,
    bool? isAdopted,
    int? commentsCount,
  }) {
    return _TwitterAnswerData(
      id: id ?? this.id,
      author: author ?? this.author,
      handle: handle ?? this.handle,
      authorAvatar: authorAvatar ?? this.authorAvatar,
      content: content ?? this.content,
      timeAgo: timeAgo ?? this.timeAgo,
      upvotes: upvotes ?? this.upvotes,
      isAdopted: isAdopted ?? this.isAdopted,
      commentsCount: commentsCount ?? this.commentsCount,
    );
  }
}
