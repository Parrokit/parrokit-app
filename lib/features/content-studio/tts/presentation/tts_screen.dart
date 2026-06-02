import 'package:flutter/material.dart';
import 'package:parrokit/features/content-studio/hub/presentation/content_studio_placeholder_screen.dart';

class TtsScreen extends StatelessWidget {
  const TtsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const ContentStudioPlaceholderScreen(
      title: 'TTS 생성',
      subtitle: '텍스트를 입력해 학습용 음성을 생성하는 화면입니다.',
      icon: Icons.graphic_eq_rounded,
    );
  }
}
