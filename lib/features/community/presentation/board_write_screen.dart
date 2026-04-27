import 'package:flutter/material.dart';

class BoardWriteScreen extends StatefulWidget {
  const BoardWriteScreen({super.key});

  @override
  State<BoardWriteScreen> createState() => _BoardWriteScreenState();
}

class _BoardWriteScreenState extends State<BoardWriteScreen> {
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _contentController = TextEditingController();

  bool get _hasContent => _contentController.text.trim().isNotEmpty;

  @override
  void dispose() {
    _titleController.dispose();
    _contentController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    const lineColor = Color(0xFFEDEDED);
    const mutedText = Color(0xFFB8BEC9);
    const tipBlue = Color(0xFF2F67BF);
    const panelBg = Color(0xFFF6F7F8);
    const contentBaseHeight = 230.0;
    const tipAreaHeight = 190.0;
    final contentFieldHeight =
        _hasContent ? contentBaseHeight + tipAreaHeight : contentBaseHeight;

    return Scaffold(
      backgroundColor: Colors.white,
      resizeToAvoidBottomInset: true,
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(14, 18, 18, 10),
              child: Row(
                children: [
                  IconButton(
                    onPressed: () => Navigator.maybePop(context),
                    icon:
                        const Icon(Icons.close, size: 34, color: Colors.black),
                  ),
                  const Spacer(),
                  TextButton(
                    onPressed: () {},
                    child: const Text(
                      '완료',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFFD3D6DB),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const Divider(height: 1, thickness: 1, color: lineColor),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(0, 0, 0, 16),
                keyboardDismissBehavior:
                    ScrollViewKeyboardDismissBehavior.onDrag,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    InkWell(
                      onTap: () {},
                      child: const Padding(
                        padding: EdgeInsets.fromLTRB(16, 24, 16, 24),
                        child: Row(
                          children: [
                            Text(
                              '주제를 선택해주세요.',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.w500,
                                color: Color(0xFF202225),
                              ),
                            ),
                            SizedBox(width: 8),
                            Icon(Icons.keyboard_arrow_down_rounded, size: 32),
                          ],
                        ),
                      ),
                    ),
                    const Padding(
                      padding: EdgeInsets.symmetric(horizontal: 8),
                      child: Divider(height: 1, thickness: 1, color: lineColor),
                    ),
                    Padding(
                      padding: const EdgeInsets.fromLTRB(16, 20, 32, 0),
                      child: TextField(
                        controller: _titleController,
                        decoration: const InputDecoration(
                          hintText: '제목을 입력하세요.',
                          hintStyle: TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.w700,
                            color: mutedText,
                          ),
                          border: InputBorder.none,
                          enabledBorder: InputBorder.none,
                          focusedBorder: InputBorder.none,
                          errorBorder: InputBorder.none,
                          disabledBorder: InputBorder.none,
                          contentPadding: EdgeInsets.zero,
                        ),
                        style: const TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.w700,
                          color: Color(0xFF202225),
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.fromLTRB(16, 18, 32, 0),
                      child: SizedBox(
                        height: contentFieldHeight,
                        child: TextField(
                          controller: _contentController,
                          onChanged: (_) => setState(() {}),
                          minLines: null,
                          maxLines: null,
                          expands: true,
                          textAlignVertical: TextAlignVertical.top,
                          decoration: const InputDecoration(
                            hintText:
                                '쉐도잉에 도움 된 표현, 자막 활용 팁, 학습 루틴을 자유롭게 나눠보세요.\n#자막 #쉐도잉 #발음 #미드추천',
                            hintStyle: TextStyle(
                              fontSize: 16,
                              height: 1.6,
                              fontWeight: FontWeight.w500,
                              color: mutedText,
                            ),
                            border: InputBorder.none,
                            enabledBorder: InputBorder.none,
                            focusedBorder: InputBorder.none,
                            errorBorder: InputBorder.none,
                            disabledBorder: InputBorder.none,
                            contentPadding: EdgeInsets.zero,
                          ),
                          style: const TextStyle(
                            fontSize: 18,
                            height: 1.6,
                            fontWeight: FontWeight.w500,
                            color: Color(0xFF202225),
                          ),
                        ),
                      ),
                    ),
                    if (!_hasContent) ...[
                      const SizedBox(height: 20),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        child: Row(
                          children: const [
                            _TipBadge(),
                            SizedBox(width: 10),
                            Expanded(
                              child: Text(
                                '쉐도잉 학습과 영상 자막 활용 경험을 나눠보세요',
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w700,
                                  color: tipBlue,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 14),
                      Container(
                        margin: const EdgeInsets.symmetric(horizontal: 16),
                        padding: const EdgeInsets.fromLTRB(18, 20, 18, 20),
                        decoration: BoxDecoration(
                          color: panelBg,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: const Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _TipBullet(
                              text: '영상 자막 자동 생성, 쉐도잉 팁, 학습 루틴을 자유롭게 공유해요.',
                            ),
                            SizedBox(height: 14),
                            _TipBullet(
                              text:
                                  '외국어 표현, 추천 콘텐츠, 발음 연습 경험처럼 학습에 도움이 되는 이야기를 나눠요.',
                            ),
                            SizedBox(height: 14),
                            _TipBullet(
                              text: '저작권을 침해하거나 학습 커뮤니티 성격에 맞지 않는 글은 제한될 수 있어요.',
                            ),
                          ],
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ),
            Container(
              decoration: const BoxDecoration(
                border: Border(top: BorderSide(color: lineColor)),
              ),
              padding: const EdgeInsets.fromLTRB(28, 16, 28, 18),
              child: Row(
                children: const [
                  _BottomTool(icon: Icons.image_outlined, label: '사진'),
                  SizedBox(width: 28),
                  _BottomTool(icon: Icons.tag_rounded, label: '태그'),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _TipBadge extends StatelessWidget {
  const _TipBadge();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: const Color(0xFFEAF2FF),
        borderRadius: BorderRadius.circular(5),
      ),
      child: const Text(
        'TIP',
        style: TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w800,
          color: Color(0xFF2F67BF),
        ),
      ),
    );
  }
}

class _TipBullet extends StatelessWidget {
  final String text;

  const _TipBullet({required this.text});

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.only(top: 6),
          child: Icon(Icons.circle, size: 8, color: Color(0xFF222222)),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            text,
            style: const TextStyle(
              fontSize: 14,
              height: 1.45,
              fontWeight: FontWeight.w500,
              color: Color(0xFF222222),
            ),
          ),
        ),
      ],
    );
  }
}

class _BottomTool extends StatelessWidget {
  final IconData icon;
  final String label;

  const _BottomTool({
    required this.icon,
    required this.label,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 28, color: const Color(0xFF9EA4AF)),
        const SizedBox(width: 8),
        Text(
          label,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: Color(0xFF9EA4AF),
          ),
        ),
      ],
    );
  }
}
