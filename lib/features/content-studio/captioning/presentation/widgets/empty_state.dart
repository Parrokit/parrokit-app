import 'package:flutter/material.dart';
import 'video_picker_sheet.dart';

class EmptyState extends StatelessWidget {
  const EmptyState({
    super.key,
    required this.onPick,
    required this.onPickFromPhotos,
  });

  final VoidCallback onPick;
  final VoidCallback onPickFromPhotos;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return AspectRatio(
      aspectRatio: 16 / 9,
      child: GestureDetector(
        onTap: () {
          showVideoPickerSheet(
            context: context,
            title: '영상 추가',
            onPickFile: onPick,
            onPickPhotos: onPickFromPhotos,
          );
        },
        behavior: HitTestBehavior.opaque,
        child: Container(
          color: cs.surfaceContainerHigh,
          child: Center(
            child: Icon(
              Icons.add_circle_outline_rounded,
              size: 48,
              color: cs.onSurfaceVariant.withValues(alpha: 0.6),
            ),
          ),
        ),
      ),
    );
  }
}
