import 'package:flutter/material.dart';
import '../domain/data/community_filters.dart';

// ─── 더미 데이터 ───────────────────────────────────────────────────────────────
class _VoteItem {
  final String title;
  final String description;
  final List<String> options;
  final List<int> votes;
  final String author;
  final String time;
  final String expiresIn;
  final int likes;
  final int comments;

  const _VoteItem({
    required this.title,
    required this.description,
    required this.options,
    required this.votes,
    required this.author,
    required this.time,
    required this.expiresIn,
    required this.likes,
    required this.comments,
  });

  int get totalVotes => votes.fold(0, (a, b) => a + b);
}

const _dummyVotes = [
  _VoteItem(
    title: '재택 vs 사무실',
    description: '어느 환경에서 일할 때 생산성이 더 높다고 느끼시나요?',
    options: ['재택 근무', '사무실 출근', '혼합 근무'],
    votes: [260, 80, 190],
    author: '워라밸러',
    time: '3일 전',
    expiresIn: '5시간 38분 후 종료!',
    likes: 9,
    comments: 4,
  ),
  _VoteItem(
    title: 'Flutter vs React Native, 2025년엔?',
    description: '크로스플랫폼 앱 개발을 시작한다면 어떤 프레임워크를 선택하시겠어요?',
    options: ['Flutter', 'React Native'],
    votes: [142, 87],
    author: '개발자뚝딱',
    time: '2시간 전',
    expiresIn: '3시간 12분 후 종료!',
    likes: 12,
    comments: 7,
  ),
  _VoteItem(
    title: '사이드 프로젝트 스택 선택',
    description: '새로운 사이드 프로젝트를 시작한다면 어떤 웹 프레임워크를 고르시겠어요?',
    options: ['Next.js', 'Nuxt.js', 'SvelteKit'],
    votes: [98, 34, 56],
    author: '코딩하는고양이',
    time: '5시간 전',
    expiresIn: '1일 후 종료!',
    likes: 5,
    comments: 3,
  ),
  _VoteItem(
    title: '코드 리뷰 주기, 어떻게 생각해요?',
    description: '팀에서 코드 리뷰를 어느 주기로 진행하는 게 가장 효율적일까요?',
    options: ['PR마다', '매일 1회', '주 1회'],
    votes: [201, 60, 45],
    author: '리뷰왕',
    time: '1일 전',
    expiresIn: '5시간 38분 후 종료!',
    likes: 9,
    comments: 4,
  ),
  _VoteItem(
    title: '개발할 때 음악 듣나요?',
    description: '코딩할 때 배경 음악을 틀어놓는 편인가요?',
    options: ['항상 들어요', '가끔만', '안 들어요'],
    votes: [320, 210, 88],
    author: '집중력마스터',
    time: '2일 전',
    expiresIn: '2일 후 종료!',
    likes: 24,
    comments: 11,
  ),
];

// ─── VoteScreen ────────────────────────────────────────────────────────────────
class VoteScreen extends StatefulWidget {
  final String selectedFilter;
  final bool swipeEnabled;
  const VoteScreen(
      {super.key, required this.selectedFilter, this.swipeEnabled = true});

  @override
  State<VoteScreen> createState() => _VoteScreenState();
}

class _VoteScreenState extends State<VoteScreen> {
  int _currentCardIndex = 0;
  final Map<int, int> _selectedOptions = {};
  final Map<int, bool> _showResults = {};

  @override
  Widget build(BuildContext context) {
    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 220),
      transitionBuilder: (child, anim) =>
          FadeTransition(opacity: anim, child: child),
      child: widget.selectedFilter == CommunityFilters.vote[0]
          ? _buildRandomView(key: const ValueKey('random'))
          : _buildListView(key: const ValueKey('list')),
    );
  }

  // ── 랜덤 보기 (스와이프) ─────────────────────────────────────────────────────
  Widget _buildRandomView({Key? key}) {
    if (_currentCardIndex >= _dummyVotes.length) {
      return Center(
        key: key,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text('🎉', style: TextStyle(fontSize: 52)),
            const SizedBox(height: 16),
            const Text('모든 투표를 확인했어요!',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Text('새 투표가 올라오면 알려드릴게요',
                style: TextStyle(
                    fontSize: 14,
                    color: Theme.of(context)
                        .colorScheme
                        .onSurface
                        .withValues(alpha: 0.45))),
            const SizedBox(height: 28),
            OutlinedButton(
              onPressed: () => setState(() {
                _currentCardIndex = 0;
                _selectedOptions.clear();
                _showResults.clear();
              }),
              child: const Text('처음부터 다시 보기'),
            ),
          ],
        ),
      );
    }

    return Column(
      key: key,
      children: [
        // 카드 영역 (구역 높이 고정, 카드는 내용에 맞춤)
        Expanded(
          child: LayoutBuilder(
            builder: (context, constraints) {
              return Padding(
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
                child: Align(
                  alignment: Alignment.center,
                  child: ConstrainedBox(
                    constraints: BoxConstraints(
                      maxHeight: constraints.maxHeight - 16,
                    ),
                    child: _SwipeableCard(
                      key: ValueKey(_currentCardIndex),
                      enabled: widget.swipeEnabled,
                      onDismiss: () => setState(() => _currentCardIndex++),
                      child: _VoteCard(
                        item: _dummyVotes[_currentCardIndex],
                        selectedOption: _selectedOptions[_currentCardIndex],
                        showResult: _showResults[_currentCardIndex] ?? false,
                        onSelect: (idx) => setState(
                            () => _selectedOptions[_currentCardIndex] = idx),
                        onToggleResult: () => setState(() {
                          _showResults[_currentCardIndex] =
                              !(_showResults[_currentCardIndex] ?? false);
                        }),
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
        ),
        // 하단 고정 네비게이션
        Container(
          padding: const EdgeInsets.symmetric(vertical: 24),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _NavButton(
                icon: Icons.arrow_back_ios_new_rounded,
                enabled: _currentCardIndex > 0,
                onTap: _currentCardIndex > 0
                    ? () => setState(() => _currentCardIndex--)
                    : null,
              ),
              const SizedBox(width: 36),
              _NavButton(
                icon: Icons.arrow_forward_ios_rounded,
                enabled: _currentCardIndex < _dummyVotes.length,
                onTap: _currentCardIndex < _dummyVotes.length
                    ? () => setState(() => _currentCardIndex++)
                    : null,
              ),
            ],
          ),
        ),
      ],
    );
  }

  // ── 한눈에 보기 (리스트) ─────────────────────────────────────────────────────
  Widget _buildListView({Key? key}) {
    return ListView.builder(
      key: key,
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 100),
      itemCount: _dummyVotes.length,
      itemBuilder: (context, i) => Padding(
        padding: const EdgeInsets.only(bottom: 12),
        child: _VoteCard(
          item: _dummyVotes[i],
          selectedOption: _selectedOptions[i],
          showResult: _showResults[i] ?? false,
          onSelect: (idx) => setState(() => _selectedOptions[i] = idx),
          onToggleResult: () => setState(() {
            _showResults[i] = !(_showResults[i] ?? false);
          }),
        ),
      ),
    );
  }
}

// ─── 네비게이션 버튼 (원형) ──────────────────────────────────────────────────────
class _NavButton extends StatelessWidget {
  final IconData icon;
  final bool enabled;
  final VoidCallback? onTap;

  const _NavButton({
    required this.icon,
    required this.enabled,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedOpacity(
        duration: const Duration(milliseconds: 200),
        opacity: enabled ? 1.0 : 0.3,
        child: Container(
          width: 48,
          height: 48,
          decoration: BoxDecoration(
            color: enabled ? Colors.black87 : Colors.grey[200],
            shape: BoxShape.circle,
          ),
          child: Icon(
            icon,
            size: 18,
            color: enabled ? Colors.white : Colors.grey,
          ),
        ),
      ),
    );
  }
}

// ─── 스와이프 래퍼 ─────────────────────────────────────────────────────────────
class _SwipeableCard extends StatefulWidget {
  final Widget child;
  final VoidCallback onDismiss;
  final bool enabled;
  const _SwipeableCard(
      {super.key,
      required this.child,
      required this.onDismiss,
      this.enabled = true});

  @override
  State<_SwipeableCard> createState() => _SwipeableCardState();
}

class _SwipeableCardState extends State<_SwipeableCard> {
  Offset _offset = Offset.zero;
  bool _dragging = false;

  @override
  Widget build(BuildContext context) {
    final w = MediaQuery.of(context).size.width;
    final angle = (_offset.dx / w).clamp(-1.0, 1.0) * 0.08;

    return GestureDetector(
      onPanStart:
          widget.enabled ? (_) => setState(() => _dragging = true) : null,
      onPanUpdate:
          widget.enabled ? (d) => setState(() => _offset += d.delta) : null,
      onPanEnd: widget.enabled
          ? (details) {
              final velocity = details.velocity.pixelsPerSecond.dx.abs();
              // 화면의 20% 이상 드래그 or 빠른 flick(800px/s 이상)
              final shouldDismiss =
                  _offset.dx.abs() > w * 0.10 || velocity > 800;
              if (shouldDismiss) {
                setState(
                    () => _offset = Offset(_offset.dx > 0 ? 900 : -900, 0));
                Future.delayed(
                    const Duration(milliseconds: 160), widget.onDismiss);
              } else {
                setState(() {
                  _offset = Offset.zero;
                  _dragging = false;
                });
              }
            }
          : null,
      child: AnimatedContainer(
        duration: _dragging ? Duration.zero : const Duration(milliseconds: 300),
        curve: Curves.easeOut,
        transform: Matrix4.identity()
          ..translate(_offset.dx, _offset.dy * 0.2)
          ..rotateZ(angle),
        transformAlignment: Alignment.bottomCenter,
        child: widget.child,
      ),
    );
  }
}

// ─── 투표 카드 (이미지 1:1 매치, 테두리 없음) ──────────────────────────────────
class _VoteCard extends StatelessWidget {
  final _VoteItem item;
  final int? selectedOption;
  final bool showResult;
  final ValueChanged<int> onSelect;
  final VoidCallback onToggleResult;

  const _VoteCard({
    super.key,
    required this.item,
    required this.selectedOption,
    required this.showResult,
    required this.onSelect,
    required this.onToggleResult,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.12),
            blurRadius: 20,
            spreadRadius: 1,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      padding: const EdgeInsets.all(20),
      clipBehavior: Clip.antiAlias,
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            // ── 타이머 + 메뉴 ──
            Row(
              children: [
                const Spacer(),
                Text(
                  item.expiresIn,
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: Colors.orange[600],
                  ),
                ),
                const Spacer(),
                const Icon(Icons.more_horiz, size: 22, color: Colors.grey),
              ],
            ),
            const SizedBox(height: 14),

            // ── 작성자 행 ──
            Row(
              children: [
                CircleAvatar(
                  radius: 18,
                  backgroundColor: Colors.grey[300],
                  child: const Icon(Icons.person, color: Colors.white),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(item.author,
                          style: const TextStyle(
                              fontSize: 15, fontWeight: FontWeight.bold)),
                      Text(item.time,
                          style:
                              TextStyle(fontSize: 12, color: Colors.grey[500])),
                    ],
                  ),
                ),
                Text(
                  '${item.totalVotes}명 참여',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: Colors.grey[500],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 14),

            // ── 제목 ──
            Text(
              item.title,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w700,
                color: Colors.black,
                height: 1.3,
              ),
            ),
            const SizedBox(height: 6),

            // ── 설명 ──
            Text(
              item.description,
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[600],
                height: 1.45,
              ),
            ),
            const SizedBox(height: 20),

            // ── 옵션 or 결과 ──
            !showResult ? _buildOptions(cs) : _buildResults(cs),
            const SizedBox(height: 16),

            // ── 결과 보기 / 리셋 버튼 ──
            Center(
              child: SizedBox(
                width: 180,
                height: 46,
                child: OutlinedButton(
                  onPressed: onToggleResult,
                  style: OutlinedButton.styleFrom(
                    foregroundColor: Colors.black87,
                    side: const BorderSide(color: Colors.black54, width: 1.2),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(999),
                    ),
                  ),
                  child: showResult
                      ? const Icon(Icons.refresh_rounded,
                          color: Colors.black87, size: 22)
                      : const Text('결과 보기',
                          style: TextStyle(
                              fontSize: 16, fontWeight: FontWeight.bold)),
                ),
              ),
            ),
            const SizedBox(height: 14),

            // ── 좋아요 + 댓글 ──
            Row(
              children: [
                const Icon(Icons.favorite_border,
                    size: 24, color: Colors.black87),
                const SizedBox(width: 6),
                Text('${item.likes}',
                    style: const TextStyle(
                        fontSize: 14, fontWeight: FontWeight.w600)),
                const SizedBox(width: 16),
                const Icon(Icons.chat_bubble_outline,
                    size: 22, color: Colors.black87),
                const SizedBox(width: 6),
                Text('${item.comments}',
                    style: const TextStyle(
                        fontSize: 14, fontWeight: FontWeight.w600)),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildOptions(ColorScheme cs) {
    return Column(
      children: List.generate(item.options.length, (i) {
        final isSelected = selectedOption == i;
        return Padding(
          padding: const EdgeInsets.only(bottom: 10),
          child: GestureDetector(
            onTap: () => onSelect(i),
            child: Container(
              width: double.infinity,
              height: 52,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: isSelected ? cs.primary : Colors.grey[100],
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                item.options[i],
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: isSelected ? Colors.white : cs.onSurface,
                ),
              ),
            ),
          ),
        );
      }),
    );
  }

  Widget _buildResults(ColorScheme cs) {
    return Column(
      children: List.generate(item.options.length, (i) {
        final pct =
            item.totalVotes == 0 ? 0.0 : item.votes[i] / item.totalVotes;
        final isSelected = selectedOption == i;
        return Padding(
          padding: const EdgeInsets.only(bottom: 10),
          child: Row(
            children: [
              SizedBox(
                width: 72,
                child: Text(
                  item.options[i],
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                    color: isSelected ? cs.primary : cs.onSurface,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Container(
                  height: 26,
                  decoration: BoxDecoration(
                    color: Colors.grey[200],
                    borderRadius: BorderRadius.circular(6),
                  ),
                  clipBehavior: Clip.hardEdge,
                  child: FractionallySizedBox(
                    alignment: Alignment.centerLeft,
                    widthFactor: pct,
                    child: Container(
                      decoration: BoxDecoration(
                        color: isSelected
                            ? cs.primary
                            : cs.primary.withValues(alpha: 0.45),
                        borderRadius: BorderRadius.circular(6),
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              SizedBox(
                width: 40,
                child: Text(
                  '${(pct * 100).round()}%',
                  textAlign: TextAlign.right,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: isSelected
                        ? cs.primary
                        : cs.onSurface.withValues(alpha: 0.5),
                  ),
                ),
              ),
            ],
          ),
        );
      }),
    );
  }
}
