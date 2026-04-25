// ============================================================================
// lib/features/_settings/more/presentation/sections/cache_section.dart
// ============================================================================
//
// [역할]
// 캐시(임시 파일) 삭제 및 용량 확인 섹션.
//
// [레이어]
// Presentation Layer > Sections
// ============================================================================

import 'package:flutter/material.dart';
import 'package:parrokit/core/services/cache_service.dart';
import '../widgets/card_container.dart';
import '../widgets/nav_tile.dart';
import '../widgets/section_title.dart';

class CacheSection extends StatefulWidget {
  const CacheSection({super.key});

  @override
  State<CacheSection> createState() => _CacheSectionState();
}

class _CacheSectionState extends State<CacheSection> {
  String _cacheSize = '';
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _refreshCache();
  }

  Future<void> _refreshCache() async {
    final size = await CacheService.instance.getCacheSize();
    if (mounted) {
      setState(() {
        _cacheSize = CacheService.instance.formatSize(size);
      });
    }
  }

  Future<void> _clearCache() async {
    final theme = Theme.of(context);
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(
          '임시 파일 청소',
          style: theme.textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        content: Text(
          '개발자가 미처 지우지 못한 임시 파일들을 말끔히 정리해 드릴게요.\n\n💡 캐시는 시스템에 의해 자동으로 생성되므로, 지운 후에도 새로운 파일들이 계속 추가될 수 있어요.\n\n정리 대상 용량: $_cacheSize',
          style: theme.textTheme.bodyMedium?.copyWith(
            height: 1.5,
            color: theme.colorScheme.onSurfaceVariant,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('취소'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('삭제'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      if (!mounted) return;
      setState(() => _isLoading = true);

      // UX: 너무 빨리 끝나면 어색하므로 최소 지연
      await Future.delayed(const Duration(milliseconds: 500));
      await CacheService.instance.clearCache();
      await _refreshCache();

      if (mounted) {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('임시 파일이 삭제되었습니다.')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SectionTitle('캐시 삭제'),
        const SizedBox(height: 10),
        CardContainer(
          child: NavTile(
            icon: Icons.cleaning_services_outlined,
            title: '임시 보관함 정리', // 사용자가 "임시 보관함" 용어를 사용함
            // 로딩 중이면 인디케이터, 아니면 텍스트 표시
            trailing: _isLoading
                ? const SizedBox(
                    width: 16,
                    height: 16,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : Text(
                    _cacheSize,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: Theme.of(context).colorScheme.primary,
                          fontWeight: FontWeight.bold,
                        ),
                  ),
            onTap: _isLoading ? null : _clearCache,
          ),
        ),
      ],
    );
  }
}
