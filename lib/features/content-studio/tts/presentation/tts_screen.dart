import 'package:flutter/material.dart';

class TtsScreen extends StatelessWidget {
  const TtsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.graphic_eq_rounded, size: 48),
            SizedBox(height: 16),
            Text('TTS 생성', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
            SizedBox(height: 8),
            Text('텍스트를 입력해 학습용 음성을 생성하는 화면입니다.'),
          ],
        ),
      ),
    );
  }
}
