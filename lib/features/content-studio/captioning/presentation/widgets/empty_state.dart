import 'package:flutter/material.dart';

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
        onTap: () => _showPickerBottomSheet(context),
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

  void _showPickerBottomSheet(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      barrierColor: Colors.black.withValues(alpha: 0.4),
      builder: (context) {
        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
          decoration: BoxDecoration(
            color: cs.surface,
            borderRadius: const BorderRadius.vertical(
              top: Radius.circular(24),
            ),
          ),
          child: SafeArea(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  '영상 추가',
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 16),
                ListTile(
                  leading: const Icon(Icons.file_open_rounded),
                  title: Text(
                    '파일에서 선택',
                    style: theme.textTheme.bodyLarge?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  onTap: () {
                    Navigator.pop(context);
                    onPick();
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.photo_library_rounded),
                  title: Text(
                    '사진에서 선택',
                    style: theme.textTheme.bodyLarge?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  onTap: () {
                    Navigator.pop(context);
                    onPickFromPhotos();
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
