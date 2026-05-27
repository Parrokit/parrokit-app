// ============================================================================
// lib/features/community/presentation/vote_write_screen.dart
// ============================================================================
//
// [역할]
// 테두리가 없는(borderless) 깔끔하고 심플한 피드/트위터 스타일의 투표 작성 화면.
// 제목, 설명, 그리고 추가/삭제 가능한 투표 대상 옵션 항목 입력창 제공.
// 커뮤니티 대표 색상인 Colors.blue[600]을 일관되게 활용하여 제작.
//
// [레이어]
// Presentation Layer > Screens
// ============================================================================

import 'package:flutter/material.dart';

class VoteWriteScreen extends StatefulWidget {
  const VoteWriteScreen({super.key});

  @override
  State<VoteWriteScreen> createState() => _VoteWriteScreenState();
}

class _VoteWriteScreenState extends State<VoteWriteScreen> {
  // ─────────────────────────────────────────────────────────────────
  // 상태 & 컨트롤러
  // ─────────────────────────────────────────────────────────────────
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _contentController = TextEditingController();

  // 투표 대상 옵션 필드 리스트 (기본 2개 생성)
  final List<TextEditingController> _optionControllers = [
    TextEditingController(),
    TextEditingController(),
  ];

  bool get _isValid {
    if (_titleController.text.trim().isEmpty) return false;
    if (_contentController.text.trim().isEmpty) return false;

    // 모든 옵션이 입력되었는지 검사 (최소 2개 이상)
    if (_optionControllers.length < 2) return false;
    for (final controller in _optionControllers) {
      if (controller.text.trim().isEmpty) return false;
    }
    return true;
  }

  @override
  void initState() {
    super.initState();
    _titleController.addListener(_updateState);
    _contentController.addListener(_updateState);
    for (final controller in _optionControllers) {
      controller.addListener(_updateState);
    }
  }

  void _updateState() {
    setState(() {});
  }

  void _addOption() {
    if (_optionControllers.length >= 5) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('투표 항목은 최대 5개까지만 추가할 수 있습니다.'),
          duration: Duration(seconds: 2),
        ),
      );
      return;
    }

    final newController = TextEditingController();
    newController.addListener(_updateState);
    setState(() {
      _optionControllers.add(newController);
    });
  }

  void _removeOption(int index) {
    if (_optionControllers.length <= 2) return;

    final controller = _optionControllers[index];
    controller.removeListener(_updateState);
    controller.dispose();
    setState(() {
      _optionControllers.removeAt(index);
    });
  }

  void _submitVote() {
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

    for (final controller in _optionControllers) {
      controller.removeListener(_updateState);
      controller.dispose();
    }
    super.dispose();
  }

  // ─────────────────────────────────────────────────────────────────
  // Build
  // ─────────────────────────────────────────────────────────────────
  @override
  Widget build(BuildContext context) {
    final blue600 = Colors.blue[600]!;

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
              onPressed: _isValid ? _submitVote : null,
              style: ElevatedButton.styleFrom(
                backgroundColor: blue600,
                disabledBackgroundColor: blue600.withValues(alpha: 0.4),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                elevation: 0,
                padding: const EdgeInsets.symmetric(horizontal: 20),
              ),
              child: const Text(
                '투표 올리기',
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
                        hintText: '투표 제목을 입력하세요.',
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
                        hintText: '투표에 대한 자세한 설명을 적어보세요.',
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
                    const SizedBox(height: 24),

                    const Divider(color: Color(0xFFF1F3F5), height: 1, thickness: 1),
                    const SizedBox(height: 24),

                    // Vote Options Section
                    Text(
                      '투표 대상 항목',
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                        color: Colors.grey[800],
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Dynamic Options Inputs
                    ...List.generate(_optionControllers.length, (index) {
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 12.0),
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                          decoration: BoxDecoration(
                            color: const Color(0xFFF8F9FA),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Row(
                            children: [
                              Text(
                                '${index + 1}',
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.bold,
                                  color: blue600,
                                ),
                              ),
                              const SizedBox(width: 14),
                              Expanded(
                                child: TextField(
                                  controller: _optionControllers[index],
                                  decoration: InputDecoration(
                                    hintText: '항목 ${index + 1} 입력',
                                    hintStyle: const TextStyle(color: Color(0xFFADB5BD), fontSize: 15),
                                    border: InputBorder.none,
                                    enabledBorder: InputBorder.none,
                                    focusedBorder: InputBorder.none,
                                    isDense: true,
                                  ),
                                  style: const TextStyle(fontSize: 15, color: Color(0xFF212529)),
                                ),
                              ),
                              if (_optionControllers.length > 2)
                                IconButton(
                                  icon: Icon(Icons.remove_circle_outline_rounded, color: Colors.red[400], size: 20),
                                  onPressed: () => _removeOption(index),
                                  padding: EdgeInsets.zero,
                                  constraints: const BoxConstraints(),
                                ),
                            ],
                          ),
                        ),
                      );
                    }),

                    // Add Option Button
                    if (_optionControllers.length < 5)
                      Padding(
                        padding: const EdgeInsets.only(top: 8.0),
                        child: InkWell(
                          onTap: _addOption,
                          borderRadius: BorderRadius.circular(12),
                          child: Container(
                            height: 48,
                            width: double.infinity,
                            alignment: Alignment.center,
                            decoration: BoxDecoration(
                              color: Colors.blue[50]!.withValues(alpha: 0.5),
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(color: Colors.blue[100]!),
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(Icons.add_circle_outline_rounded, size: 18, color: blue600),
                                const SizedBox(width: 8),
                                Text(
                                  '항목 추가하기',
                                  style: TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.bold,
                                    color: blue600,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
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
