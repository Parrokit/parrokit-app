import 'package:flutter/material.dart';

/// [역할]
/// 라이브러리 폴더 뷰의 폴더 카드 아이템.
///
/// 계층 구조 탐색 시 폴더(Title, Season 등) 하나를 표시합니다.
class FolderCard extends StatelessWidget {
  const FolderCard({super.key, required this.name, required this.onTap});

  final String name;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return InkWell(
      borderRadius: BorderRadius.circular(14),
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: cs.surface,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: cs.outlineVariant, width: 0.8),
        ),
        padding: const EdgeInsets.all(10),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.folder_rounded,
                size: 28, color: cs.onSurface.withValues(alpha: 0.7)),
            const SizedBox(height: 8),
            Text(name,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(fontWeight: FontWeight.w700)),
          ],
        ),
      ),
    );
  }
}
