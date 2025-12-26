// ============================================================================
// lib/features/_content/shorts/presentation/widgets/video_layer_placeholder.dart
// ============================================================================
//
// [역할]
// 비디오 로딩 중이거나 에러 발생 시 표시되는 플레이스홀더 위젯.
//
// [기능]
// - 검은 배경에 로딩 인디케이터 중앙 배치
//
// [레이어]
// Presentation Layer > Widgets
//
// ============================================================================

import 'package:flutter/material.dart';

/// [역할]
/// 비디오가 준비되기 전 보여주는 로딩 화면 위젯.
class VideoLayerPlaceholder extends StatelessWidget {
  const VideoLayerPlaceholder({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.black,
      alignment: Alignment.center,
      child: const SizedBox(
        width: 48,
        height: 48,
        child: CircularProgressIndicator(
          strokeWidth: 3,
          valueColor: AlwaysStoppedAnimation<Color>(Colors.grey),
        ),
      ),
    );
  }
}
