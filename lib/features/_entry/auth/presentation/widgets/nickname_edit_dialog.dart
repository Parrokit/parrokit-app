// ============================================================================
// lib/features/_entry/auth/presentation/widgets/nickname_edit_dialog.dart
// ============================================================================
//
// [역할]
// 닉네임 변경 다이얼로그.
//
// [레이어]
// Presentation Layer > Widgets
// ============================================================================

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:parrokit/core/provider/user_provider.dart';

/// 닉네임 변경 다이얼로그를 표시합니다.
Future<void> showNicknameEditDialog(
    BuildContext context, String? currentName) async {
  return showDialog(
    context: context,
    builder: (context) => _NicknameEditDialog(initialName: currentName),
  );
}

class _NicknameEditDialog extends StatefulWidget {
  final String? initialName;

  const _NicknameEditDialog({required this.initialName});

  @override
  State<_NicknameEditDialog> createState() => _NicknameEditDialogState();
}

class _NicknameEditDialogState extends State<_NicknameEditDialog> {
  late final TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.initialName);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('닉네임 변경'),
      content: TextField(
        controller: _controller,
        decoration: const InputDecoration(
          hintText: '닉네임을 입력하세요',
          filled: true,
        ),
        autofocus: true,
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('취소'),
        ),
        TextButton(
          onPressed: () {
            final newName = _controller.text.trim();
            if (newName.isNotEmpty) {
              context.read<UserProvider>().updateDisplayName(newName);
            } else if (widget.initialName != null) {
              // 이름 삭제 (null)
              context.read<UserProvider>().updateDisplayName(null);
            }
            Navigator.pop(context);
          },
          child: const Text('저장'),
        ),
      ],
    );
  }
}
