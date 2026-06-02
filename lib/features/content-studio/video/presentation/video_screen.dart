import 'package:flutter/material.dart';
import 'package:parrokit/features/content-studio/hub/presentation/content_studio_placeholder_screen.dart';

class VideoScreen extends StatelessWidget {
  const VideoScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const ContentStudioPlaceholderScreen(
      title: 'Video 생성',
      subtitle: '프롬프트 기반 영상 생성 기능을 준비하는 화면입니다.',
      icon: Icons.movie_creation_rounded,
    );
  }
}
