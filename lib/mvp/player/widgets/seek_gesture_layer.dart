import 'package:flutter/material.dart';

class SeekGestureLayer extends StatelessWidget {
  const SeekGestureLayer({required this.onSeek});
  final void Function(double dx, double width) onSeek;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (_, c) => GestureDetector(
        behavior: HitTestBehavior.translucent,
        onHorizontalDragUpdate: (d) =>
            onSeek(d.localPosition.dx.clamp(0.0, c.maxWidth), c.maxWidth),
        onTapDown: (d) =>
            onSeek(d.localPosition.dx.clamp(0.0, c.maxWidth), c.maxWidth),
      ),
    );
  }
}
