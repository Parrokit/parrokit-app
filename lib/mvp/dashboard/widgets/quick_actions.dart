import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:parrokit/pa_router.dart';
import 'qa_button.dart';

class QuickActions extends StatelessWidget {
  const QuickActions({
    required this.cardBg,
    required this.subtle,
    required this.textPrimary,
    required this.textSecondary,
    required this.onTapRecord,
    required this.onTapImport,
    required this.onTapLibrary,
  });

  final Color cardBg;
  final Color subtle;
  final Color textPrimary;
  final Color textSecondary;
  final VoidCallback onTapRecord;
  final VoidCallback onTapImport;
  final VoidCallback onTapLibrary;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 56, // 버튼 높이 + 패딩 고려(필요시 조절)
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        physics: const BouncingScrollPhysics(),
        child: Row(
          children: [
            const SizedBox(width: 4),
            QAButton(
              label: '추가',
              icon: Icons.file_download_rounded,
              cardBg: cardBg,
              subtle: subtle,
              textPrimary: textPrimary,
              textSecondary: textSecondary,
              onTap: onTapImport,
            ),
            const SizedBox(width: 12),
            QAButton(
              label: '라이브러리',
              icon: Icons.bookmarks_rounded,
              cardBg: cardBg,
              subtle: subtle,
              textPrimary: textPrimary,
              textSecondary: textSecondary,
              onTap: onTapLibrary,
            ),
            const SizedBox(width: 4),
            QAButton(
              label: '검색',
              icon: Icons.search_rounded,
              cardBg: cardBg,
              subtle: subtle,
              textPrimary: textPrimary,
              textSecondary: textSecondary,
              onTap: () => context.replaceNamed(
                PaRoutes.library,
                queryParameters: {'tab': 1.toString()},
              ),
            ),
            const SizedBox(width: 12),
            QAButton(
              label: '설정',
              icon: Icons.settings_rounded,
              cardBg: cardBg,
              subtle: subtle,
              textPrimary: textPrimary,
              textSecondary: textSecondary,
              onTap: () => context.replaceNamed(PaRoutes.more),
            ),
            const SizedBox(width: 4),
          ],
        ),
      ),
    );
  }
}
