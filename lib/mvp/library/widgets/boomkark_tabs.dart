import 'package:flutter/material.dart';
import 'bookmark_tab.dart';
import '../../../data/constants/library_tab.dart';

class BookmarkTabs extends StatelessWidget {
  const BookmarkTabs({required this.value, required this.onChanged});

  final LibraryTab value;
  final ValueChanged<LibraryTab> onChanged;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final isFolder = value == LibraryTab.folder;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      child: Container(
        decoration: BoxDecoration(
          color: cs.surface,
          borderRadius: BorderRadius.circular(14),
          boxShadow: [
            BoxShadow(
                color: Colors.black.withOpacity(0.03),
                blurRadius: 8,
                offset: const Offset(0, 2)),
          ],
          border: Border.all(color: cs.outlineVariant, width: 0.8),
        ),
        padding: const EdgeInsets.all(8),
        child: Stack(
          children: [
            AnimatedAlign(
              alignment:
              isFolder ? Alignment.centerLeft : Alignment.centerRight,
              duration: const Duration(milliseconds: 220),
              curve: Curves.easeOut,
              child: Container(
                width: (MediaQuery.of(context).size.width - 12 * 2 - 8 * 2) / 2,
                height: 42,
                decoration: BoxDecoration(
                  color: cs.primary.withOpacity(0.12),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                      color: cs.primary.withOpacity(0.5), width: 0.8),
                ),
              ),
            ),
            Row(children: [
              Expanded(
                child: BookmarkTab(
                  icon: Icons.folder_open_rounded,
                  label: '유형별 보기',
                  active: isFolder,
                  onTap: () => onChanged(LibraryTab.folder),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: BookmarkTab(
                  icon: Icons.sell_outlined,
                  label: '태그로 보기',
                  active: !isFolder,
                  onTap: () => onChanged(LibraryTab.tag),
                ),
              ),
            ]),
          ],
        ),
      ),
    );
  }
}
