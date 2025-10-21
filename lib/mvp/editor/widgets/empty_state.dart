import 'package:flutter/material.dart';

class EmptyState extends StatelessWidget {
  const EmptyState({
    super.key,
    required this.onPick,
    required this.onAddToSandbox,
    required this.onPickFromPhotos,
  });

  final VoidCallback onPick;
  final VoidCallback onAddToSandbox;
  final VoidCallback onPickFromPhotos;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;
    final subtle = cs.onSurface.withOpacity(0.6);
    final borderColor = cs.outlineVariant;

    return Column(
      children: [
        AspectRatio(
          aspectRatio: 16 / 9,
          child: Container(
            decoration: BoxDecoration(
              color: cs.onSurface.withOpacity(0.03),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: borderColor, width: 0.8),
            ),
            child: Center(
              child: Icon(Icons.video_file_rounded,
                  size: 56, color: cs.onSurface.withOpacity(0.35)),
            ),
          ),
        ),
        const SizedBox(height: 12),
        Text('영상 파일을 선택해 주세요',
            style: tt.bodyLarge?.copyWith(fontWeight: FontWeight.w800)),
        const SizedBox(height: 6),
        Text('파일을 선택한 후, 미리보기와 관련 정보를 이어서 입력해 주세요.',
            style: tt.bodySmall?.copyWith(color: subtle)),
        const SizedBox(height: 14),
        Row(
          children: [
            Expanded(
              child: OutlinedButton.icon(
                icon: const Icon(Icons.file_open_rounded, size: 18),
                label:  Text('파일 선택',style: tt.bodyMedium?.copyWith(fontWeight: FontWeight.w800)),
                onPressed: onPick,
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: OutlinedButton.icon(

                icon: const Icon(Icons.photo_library_rounded, size: 18),
                label:  Text('사진에서 선택', style: tt.bodyMedium?.copyWith(fontWeight: FontWeight.w800)),
                onPressed: onPickFromPhotos,
              ),
            ),
          ],
        ),
      ],
    );
  }
}
