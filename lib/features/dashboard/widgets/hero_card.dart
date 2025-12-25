import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class HeroCard extends StatelessWidget {
  const HeroCard({
    super.key,
    required this.cardBg,
    required this.subtle,
    required this.textPrimary,
    required this.textSecondary,
    required this.accent,
    this.title,       // 작품명
    this.clipTitle,   // 클립 제목
    this.loading = false,
    this.onGo,
  });

  final Color cardBg;
  final Color subtle;
  final Color textPrimary;
  final Color textSecondary;
  final Color accent;

  final String? title;      // 작품명
  final String? clipTitle;  // 클립 제목

  final bool loading;
  final VoidCallback? onGo;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: cardBg,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: subtle),
      ),
      child: Row(
        children: [
          Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              color: accent.withOpacity(.12),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Icon(Icons.play_circle_fill_rounded, color: accent, size: 28),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 제목(작품명)
                Row(
                  children: [
                    Text(
                      title ?? '오늘의 학습',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                        color: textSecondary,
                      ),
                    ),
                    const SizedBox(width: 8),
                    if (loading)
                      SizedBox(
                        width: 12,
                        height: 12,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: cs.primary.withOpacity(.8),
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: 6),

                // 부제목(클립 제목)
                Text(
                  clipTitle ?? '영상을 시청해보세요',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w800,
                    color: textPrimary,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          IconButton(
            onPressed: onGo ?? () => context.go('/clips'),
            icon: const Icon(Icons.arrow_forward_rounded),
            splashRadius: 22,
          ),
        ],
      ),
    );
  }
}