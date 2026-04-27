import 'package:flutter/material.dart';

class BoardViewScreen extends StatefulWidget {
  final int postId;

  const BoardViewScreen({super.key, required this.postId});

  @override
  State<BoardViewScreen> createState() => _BoardViewScreenState();
}

class _BoardViewScreenState extends State<BoardViewScreen> {
  bool _liked = false;
  bool _scrapped = false;

  @override
  Widget build(BuildContext context) {
    const backgroundColor = Color(0xFFFFFFFF);
    const textMuted = Color(0xFF8B8B8B);
    const likeAccent = Color(0xFF3F72C4); // blue[600] 느낌
    const scrapAccent = Color(0xFFC9AE58); // 부드러운 노랑 느낌

    final likeMetaColor = _liked ? likeAccent : const Color(0xFF9F9F9F);
    final likeIconColor = _liked ? likeAccent : const Color(0xFFB2B2B2);
    final likeCount = _liked ? 19 : 18;

    return Scaffold(
      backgroundColor: backgroundColor,
      bottomNavigationBar: SafeArea(
        top: false,
        child: Container(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
          decoration: const BoxDecoration(
            color: backgroundColor,
            border: Border(top: BorderSide(color: Color(0xFFDCDCDC))),
          ),
          child: Row(
            children: [
              IconButton(
                onPressed: () {},
                icon: const Icon(Icons.photo_outlined, size: 32),
                color: const Color(0xFF707070),
              ),
              const SizedBox(width: 6),
              Expanded(
                child: Container(
                  height: 52,
                  padding: const EdgeInsets.symmetric(horizontal: 18),
                  decoration: BoxDecoration(
                    color: const Color.fromARGB(255, 250, 250, 250),
                    borderRadius: BorderRadius.circular(30),
                  ),
                  child: const Row(
                    children: [
                      Expanded(
                        child: Text(
                          '댓글을 입력해주세요.',
                          style: TextStyle(
                            color: Color(0xFF9B9B9B),
                            fontSize: 18,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                      Icon(Icons.subdirectory_arrow_left,
                          color: Color(0xFF8A8A8A), size: 30),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(8, 10, 8, 0),
              child: Row(
                children: [
                  IconButton(
                    onPressed: () => Navigator.maybePop(context),
                    icon: const Icon(Icons.arrow_back_ios_new, size: 24),
                  ),
                  const Spacer(),
                  IconButton(
                    onPressed: () {},
                    icon:
                        const Icon(Icons.notifications_off_outlined, size: 24),
                  ),
                  IconButton(
                    onPressed: () {},
                    icon: const Icon(Icons.more_vert, size: 24),
                  ),
                ],
              ),
            ),
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 28),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 18),
                      child: Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 16, vertical: 8),
                            decoration: BoxDecoration(
                              color: const Color.fromARGB(255, 245, 245, 245),
                              borderRadius: BorderRadius.circular(24),
                            ),
                            child: const Row(
                              children: [
                                Text(
                                  '추천해요',
                                  style: TextStyle(
                                    fontSize: 30 / 2,
                                    fontWeight: FontWeight.w700,
                                    color: Color(0xFF6E6E6E),
                                  ),
                                ),
                                SizedBox(width: 4),
                                Icon(Icons.chevron_right,
                                    size: 20, color: Color(0xFF7E7E7E)),
                              ],
                            ),
                          ),
                          const Spacer(),
                          const Icon(Icons.remove_red_eye_outlined,
                              color: Color(0xFFB2B2B2), size: 24),
                          const SizedBox(width: 6),
                          const Text(
                            '894',
                            style: TextStyle(
                                color: Color(0xFF9F9F9F),
                                fontSize: 30 / 2,
                                fontWeight: FontWeight.w700),
                          ),
                          const SizedBox(width: 18),
                          Icon(Icons.thumb_up_outlined,
                              color: likeIconColor, size: 24),
                          const SizedBox(width: 6),
                          Text(
                            '$likeCount',
                            style: TextStyle(
                                color: likeMetaColor,
                                fontSize: 30 / 2,
                                fontWeight: FontWeight.w700),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 26),
                    const Padding(
                      padding: EdgeInsets.symmetric(horizontal: 18),
                      child: Row(
                        children: [
                          CircleAvatar(
                            radius: 24,
                            backgroundColor: Color.fromARGB(255, 220, 220, 220),
                            child: Icon(Icons.person,
                                size: 30,
                                color: Color.fromARGB(255, 255, 255, 255)),
                          ),
                          SizedBox(width: 10),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'dd',
                                style: TextStyle(
                                  fontSize: 34 / 2,
                                  fontWeight: FontWeight.w800,
                                ),
                              ),
                              SizedBox(height: 2),
                              Text(
                                '4시간 전',
                                style: TextStyle(
                                  fontSize: 15,
                                  fontWeight: FontWeight.w700,
                                  color: Color(0xFF6E6E6E),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 28),
                    const Padding(
                      padding: EdgeInsets.symmetric(horizontal: 16),
                      child: Text(
                        '플래시 시즌 2 13화 부분에서 괜찮은 문장 찾음',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w800,
                          height: 1.25,
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    const Padding(
                      padding: EdgeInsets.symmetric(horizontal: 16),
                      child: Text(
                        '친구랑 밥먹으러가자고 할 때, 나는 보통 뭐라고\n'
                        '할지 잘 생각 안나는데 여기 나와 있는 대사들이 정말\n'
                        '실생활에서 쓰기 좋고 자연스럽게 느껴졌어요. 꼭 한 번\n'
                        '다시 보면서 따라해보고 싶네요.',
                        style: TextStyle(
                          fontSize: 20 / 1.2,
                          fontWeight: FontWeight.w500,
                          height: 1.6,
                        ),
                      ),
                    ),
                    const SizedBox(height: 44),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        _ActionTile(
                          icon:
                              _liked ? Icons.thumb_up : Icons.thumb_up_outlined,
                          label: '공감',
                          selected: _liked,
                          accentColor: likeAccent,
                          onTap: () => setState(() => _liked = !_liked),
                        ),
                        const SizedBox(width: 26),
                        _ActionTile(
                          icon: _scrapped
                              ? Icons.bookmark
                              : Icons.bookmark_outline,
                          label: '스크랩',
                          selected: _scrapped,
                          accentColor: const Color.fromARGB(255, 255, 226, 130),
                          onTap: () => setState(() => _scrapped = !_scrapped),
                        ),
                      ],
                    ),
                    const SizedBox(height: 40),
                    const Divider(
                        height: 1,
                        thickness: 5,
                        color: Color.fromARGB(255, 239, 239, 239)),
                    const Padding(
                      padding: EdgeInsets.fromLTRB(18, 18, 28, 0),
                      child: Text(
                        '댓글 0',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w800,
                          color: Color(0xFF6A6A6A),
                        ),
                      ),
                    ),
                    const SizedBox(height: 130),
                    const Center(
                      child: Text(
                        '첫 댓글을 남겨보세요',
                        style: TextStyle(
                          fontSize: 16,
                          color: textMuted,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),
                    Center(
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 24, vertical: 12),
                        decoration: BoxDecoration(
                          color: const Color.fromARGB(255, 250, 250, 250),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.edit_outlined,
                                size: 24,
                                color: Color.fromARGB(255, 188, 188, 188)),
                            SizedBox(width: 10),
                            Text(
                              '댓글 쓰기',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w800,
                                color: Color(0xFF3F3F3F),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 280),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ActionTile extends StatefulWidget {
  final IconData icon;
  final String label;
  final bool selected;
  final Color accentColor;
  final VoidCallback onTap;

  const _ActionTile({
    required this.icon,
    required this.label,
    required this.selected,
    required this.accentColor,
    required this.onTap,
  });

  @override
  State<_ActionTile> createState() => _ActionTileState();
}

class _ActionTileState extends State<_ActionTile> {
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    final borderColor =
        widget.selected ? widget.accentColor : const Color(0xFFD8D8D8);
    final borderWidth = _pressed ? 2.0 : 1.4;
    final contentColor = widget.selected
        ? widget.accentColor
        : const Color.fromARGB(255, 193, 193, 193);
    final labelColor =
        widget.selected ? widget.accentColor : const Color(0xFF5E5E5E);

    return AnimatedScale(
      scale: _pressed ? 0.94 : 1,
      duration: const Duration(milliseconds: 110),
      curve: Curves.easeOutCubic,
      child: InkWell(
        onTap: widget.onTap,
        onTapDown: (_) => setState(() => _pressed = true),
        onTapUp: (_) => setState(() => _pressed = false),
        onTapCancel: () => setState(() => _pressed = false),
        borderRadius: BorderRadius.circular(8),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          curve: Curves.easeOutCubic,
          width: 55,
          height: 55,
          decoration: BoxDecoration(
            color: Colors.transparent,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: borderColor, width: borderWidth),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(widget.icon, size: 18, color: contentColor),
              const SizedBox(height: 2),
              Text(
                widget.label,
                style: TextStyle(
                  color: labelColor,
                  fontWeight: FontWeight.w700,
                  fontSize: 12,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
