// ============================================================================
// lib/features/community/presentation/qeustion_wirte_screen.dart
// ============================================================================
//
// [역할]
// 테두리가 없는(borderless) 깔끔하고 심플한 피드/트위터 스타일의 질문 작성 화면.
// 카테고리와 프로필 아바타를 제거하고 제목과 내용만을 직관적으로 작성할 수 있도록 간소화.
//
// [레이어]
// Presentation Layer > Screens
// ============================================================================

import 'package:flutter/material.dart';

class QuestionWriteScreen extends StatefulWidget {
  const QuestionWriteScreen({super.key});

  @override
  State<QuestionWriteScreen> createState() => _QuestionWriteScreenState();
}

class _QuestionWriteScreenState extends State<QuestionWriteScreen> {
  // ─────────────────────────────────────────────────────────────────
  // 상태 & 컨트롤러
  // ─────────────────────────────────────────────────────────────────
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _contentController = TextEditingController();

  bool get _isValid =>
      _titleController.text.trim().isNotEmpty &&
      _contentController.text.trim().isNotEmpty;

  @override
  void initState() {
    super.initState();
    _titleController.addListener(_updateState);
    _contentController.addListener(_updateState);
  }

  void _updateState() {
    setState(() {});
  }

  void _submitQuestion() {
    if (!_isValid) return;
    // 작성 완료 후 화면 닫기
    Navigator.pop(context);
  }

  @override
  void dispose() {
    _titleController.removeListener(_updateState);
    _contentController.removeListener(_updateState);
    _titleController.dispose();
    _contentController.dispose();
    super.dispose();
  }

  // ─────────────────────────────────────────────────────────────────
  // Build
  // ─────────────────────────────────────────────────────────────────
  @override
  Widget build(BuildContext context) {
    final orange600 = Colors.orange[600]!;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        scrolledUnderElevation: 0,
        leading: IconButton(
          onPressed: () => Navigator.maybePop(context),
          icon: const Icon(Icons.close_rounded, size: 28, color: Colors.black),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16.0, top: 10.0, bottom: 10.0),
            child: ElevatedButton(
              onPressed: _isValid ? _submitQuestion : null,
              style: ElevatedButton.styleFrom(
                backgroundColor: orange600,
                disabledBackgroundColor: orange600.withValues(alpha: 0.4),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                elevation: 0,
                padding: const EdgeInsets.symmetric(horizontal: 20),
              ),
              child: const Text(
                '질문하기',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                ),
              ),
            ),
          )
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            // Thin top divider
            Container(color: const Color(0xFFF1F3F5), height: 1),

            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(20.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Title Input Field (Borderless)
                    TextField(
                      controller: _titleController,
                      decoration: const InputDecoration(
                        hintText: '제목을 입력하세요.',
                        hintStyle: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFFADB5BD),
                        ),
                        border: InputBorder.none,
                        enabledBorder: InputBorder.none,
                        focusedBorder: InputBorder.none,
                        contentPadding: EdgeInsets.zero,
                      ),
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF212529),
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Content Input Field (Borderless)
                    TextField(
                      controller: _contentController,
                      maxLines: null,
                      keyboardType: TextInputType.multiline,
                      decoration: const InputDecoration(
                        hintText: '무엇이 궁금하신가요? 단어 번역, 문맥 상 의미, 억양 차이 등 자유롭게 질문해보세요.',
                        hintStyle: TextStyle(
                          fontSize: 16,
                          color: Color(0xFFADB5BD),
                          height: 1.5,
                        ),
                        border: InputBorder.none,
                        enabledBorder: InputBorder.none,
                        focusedBorder: InputBorder.none,
                        contentPadding: EdgeInsets.zero,
                      ),
                      style: const TextStyle(
                        fontSize: 16,
                        color: Color(0xFF495057),
                        height: 1.5,
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // Bottom Attachment Toolbar
            Container(
              decoration: const BoxDecoration(
                border: Border(top: BorderSide(color: Color(0xFFF1F3F5))),
                color: Colors.white,
              ),
              padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
              child: Row(
                children: [
                  IconButton(
                    icon: Icon(Icons.image_outlined, color: orange600),
                    onPressed: () {},
                  ),
                  IconButton(
                    icon: Icon(Icons.mic_none_rounded, color: orange600),
                    onPressed: () {},
                  ),
                  IconButton(
                    icon: Icon(Icons.link_rounded, color: orange600),
                    onPressed: () {},
                  ),
                  IconButton(
                    icon: Icon(Icons.tag_rounded, color: orange600),
                    onPressed: () {},
                  ),
                  const Spacer(),
                  // Character Counter Text
                  if (_contentController.text.isNotEmpty)
                    Text(
                      '${_contentController.text.length}자',
                      style: TextStyle(
                        fontSize: 13,
                        color: Colors.grey[500],
                        fontWeight: FontWeight.w500,
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
