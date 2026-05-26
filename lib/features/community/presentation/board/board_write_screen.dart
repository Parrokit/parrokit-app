import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:parrokit/features/community/providers/community_provider.dart';
import 'package:parrokit/core/provider/user_provider.dart';
import 'package:parrokit/features/community/domain/data/community_filters.dart';

class BoardWriteScreen extends StatefulWidget {
  const BoardWriteScreen({super.key});

  @override
  State<BoardWriteScreen> createState() => _BoardWriteScreenState();
}

class _BoardWriteScreenState extends State<BoardWriteScreen> {
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _contentController = TextEditingController();
  final TextEditingController _tagController = TextEditingController();
  final FocusNode _tagFocusNode = FocusNode();
  String? _selectedBoardTopic;
  
  List<String> _tags = [];
  bool _isTagInputActive = false;

  bool get _hasTitle => _titleController.text.trim().isNotEmpty;
  bool get _hasContent => _contentController.text.trim().isNotEmpty;
  bool get _canComplete => _hasTitle && _hasContent && _selectedBoardTopic != null;

  void _showBoardTopicSheet() {
    final blue600 = Colors.blue[600]!;

    showModalBottomSheet<void>(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const Padding(
                  padding: EdgeInsets.only(bottom: 12),
                  child: Text(
                    '게시판 주제 선택',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF202225),
                    ),
                  ),
                ),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: CommunityFilters.board.where((t) => t != '전체').map((topic) {
                    final selected = topic == _selectedBoardTopic;
                    return ChoiceChip(
                      label: Text(topic),
                      selected: selected,
                      showCheckmark: false,
                      onSelected: (_) {
                        setState(() => _selectedBoardTopic = topic);
                        Navigator.pop(context);
                      },
                      selectedColor: blue600,
                      backgroundColor: const Color.fromARGB(255, 250, 250, 250),
                      labelStyle: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color:
                            selected ? Colors.white : const Color(0xFF4A4F57),
                      ),
                      side: BorderSide(
                          width: 1,
                          color: selected
                              ? blue600
                              : const Color.fromARGB(255, 255, 255, 255),
                        ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(50),

                      ),
                    );
                  }).toList(),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Future<void> _submitPost() async {
    final userProvider = context.read<UserProvider>();
    final currentUser = userProvider.currentUser;

    if (currentUser == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('로그인이 필요합니다.')),
      );
      return;
    }

    final provider = context.read<CommunityProvider>();
    final success = await provider.addPost(
      _titleController.text.trim(),
      _contentController.text.trim(),
      _selectedBoardTopic!, // _canComplete 검사를 통과했으므로 null이 아님 보장
      authorId: currentUser.id,
      authorNickname: currentUser.displayName ?? '알 수 없음',
      tags: _tags,
    );
    if (success && mounted) {
      Navigator.maybePop(context);
    } else if (mounted && provider.errorMessage != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(provider.errorMessage!)),
      );
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _contentController.dispose();
    _tagController.dispose();
    _tagFocusNode.dispose();
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
                    onPressed: _canComplete ? _submitPost : null,
                    child: context.watch<CommunityProvider>().isLoading
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : Text(
                            '완료',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w700,
                              color: _canComplete
                                  ? const Color(0xFF2F67BF)
                                  : const Color(0xFFD3D6DB),
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
                      onTap: _showBoardTopicSheet,
                      child: Padding(
                        padding: EdgeInsets.fromLTRB(16, 16, 16, 16),
                        child: Row(
                          children: [
                            Text(
                              _selectedBoardTopic ?? '주제를 선택해주세요.',
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
                        onChanged: (_) => setState(() {}),
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
                              text:
                                  '저작권을 침해하거나 학습 커뮤니티 성격에 맞지 않는 글은 제한될 수 있어요.',
                            ),
                          ],
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ),
            // 등록된 태그 칩들을 보여주는 횡스크롤 영역
            if (_tags.isNotEmpty)
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: _tags.map((tag) => Padding(
                      padding: const EdgeInsets.only(right: 8),
                      child: InputChip(
                        label: Text('#$tag'),
                        onDeleted: () {
                          setState(() {
                            _tags.remove(tag);
                          });
                        },
                        backgroundColor: const Color(0xFFEAF2FF),
                        deleteIconColor: const Color(0xFF2F67BF),
                        labelStyle: const TextStyle(
                          color: Color(0xFF2F67BF),
                          fontWeight: FontWeight.w600,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(6),
                          side: const BorderSide(color: Colors.transparent),
                        ),
                      ),
                    )).toList(),
                  ),
                ),
              ),
              
            // 태그 입력창 (활성화 시에만 보임)
            if (_isTagInputActive)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                decoration: const BoxDecoration(
                  color: Color(0xFFF9F9F9),
                  border: Border(top: BorderSide(color: lineColor)),
                ),
                child: TextField(
                  controller: _tagController,
                  focusNode: _tagFocusNode,
                  decoration: InputDecoration(
                    hintText: '태그를 입력하고 엔터를 누르세요',
                    hintStyle: const TextStyle(color: Color(0xFF9EA4AF), fontSize: 15),
                    border: InputBorder.none,
                    isDense: true,
                    suffixText: '${_tags.length}/20',
                    suffixStyle: const TextStyle(color: Color(0xFF9EA4AF), fontSize: 13, fontWeight: FontWeight.w600),
                  ),
                  textInputAction: TextInputAction.done,
                  onSubmitted: (val) {
                    final text = val.trim();
                    if (text.isNotEmpty && !_tags.contains(text)) {
                      if (text.length > 10) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('태그는 10글자 이하로 입력해주세요.')),
                        );
                        return;
                      }
                      if (_tags.length >= 20) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('태그는 최대 20개까지만 등록할 수 있습니다.')),
                        );
                        return;
                      }
                      
                      setState(() {
                        _tags.add(text);
                      });
                      _tagController.clear();
                      _tagFocusNode.requestFocus(); // 계속 입력할 수 있도록 포커스 유지
                    }
                  },
                ),
              ),
              
            Container(
              decoration: const BoxDecoration(
                border: Border(top: BorderSide(color: lineColor)),
              ),
              padding: const EdgeInsets.fromLTRB(28, 16, 28, 18),
              child: Row(
                children: [
                  const _BottomTool(icon: Icons.image_outlined, label: '사진'),
                  const SizedBox(width: 28),
                  GestureDetector(
                    onTap: () {
                      setState(() {
                        _isTagInputActive = !_isTagInputActive;
                        if (_isTagInputActive) {
                          _tagFocusNode.requestFocus();
                        }
                      });
                    },
                    child: _BottomTool(
                      icon: Icons.tag_rounded,
                      label: '태그',
                      isActive: _isTagInputActive,
                    ),
                  ),
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
  final bool isActive;

  const _BottomTool({
    required this.icon,
    required this.label,
    this.isActive = false,
  });

  @override
  Widget build(BuildContext context) {
    final color = isActive ? const Color(0xFF2F67BF) : const Color(0xFF9EA4AF);
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 28, color: color),
        const SizedBox(width: 8),
        Text(
          label,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: color,
          ),
        ),
      ],
    );
  }
}
