// ============================================================================
// lib/features/settings/more/presentation/sections/storage_section.dart
// ============================================================================
//
// [역할]
// 기기 안에 남겨둘 저장 공간을 조절하는 섹션.
// ============================================================================

import 'package:flutter/material.dart';
import '../widgets/card_container.dart';
import '../widgets/section_title.dart';
import '../storage_cache_management_screen.dart';

class StorageSection extends StatefulWidget {
  const StorageSection({super.key});

  @override
  State<StorageSection> createState() => _StorageSectionState();
}

class _StorageSectionState extends State<StorageSection> {
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SectionTitle('저장 공간'),
        const SizedBox(height: 10),
        CardContainer(
          child: InkWell(
            borderRadius: BorderRadius.circular(18),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => const StorageCacheManagementScreen(),
                ),
              );
            },
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '기기 안에 남겨둘 공간',
                  style: theme.textTheme.bodyLarge?.copyWith(
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 4),
                const _BulletText(
                  text: '처음 본 원격 저장소의 동영상은 기기에 자동 보관되어 다음 재생이 더 빨라져요.',
                ),
                const SizedBox(height: 6),
                const _BulletText(
                  text: '매번 다시 받지 않도록 자주 쓰는 동영상은 기기에 남겨두는 게 좋아요.',
                ),
                const SizedBox(height: 6),
                const _BulletText(
                  text: '공간이 부족하면 오래 안 쓴 것부터 정리할 수 있도록 해놨어요.',
                ),
                const SizedBox(height: 10),
                Row(
                  children: [
                    Text(
                      '캐시 관리 열기',
                      style: theme.textTheme.labelLarge?.copyWith(
                        color: Theme.of(context).colorScheme.primary,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(width: 4),
                    Icon(
                      Icons.chevron_right_rounded,
                      size: 18,
                      color: Theme.of(context).colorScheme.primary,
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class _BulletText extends StatelessWidget {
  const _BulletText({required this.text});

  final String text;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '•',
          style: theme.textTheme.bodySmall?.copyWith(
            color: cs.onSurfaceVariant,
            height: 1.45,
          ),
        ),
        const SizedBox(width: 6),
        Expanded(
          child: Text(
            text,
            style: theme.textTheme.bodySmall?.copyWith(
              color: cs.onSurfaceVariant,
              height: 1.45,
            ),
          ),
        ),
      ],
    );
  }
}
