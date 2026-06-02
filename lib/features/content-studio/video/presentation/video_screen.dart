import 'package:flutter/material.dart';

class VideoScreen extends StatelessWidget {
  const VideoScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.movie_creation_rounded, size: 48),
            SizedBox(height: 16),
            Text('Video 생성', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
            SizedBox(height: 8),
            Text('프롬프트 기반 영상 생성 기능을 준비하는 화면입니다.'),
          ],
        ),
      ),
    );
  }
}
