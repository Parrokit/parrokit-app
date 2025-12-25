// ============================================================================
// lib/features/recom/presentation/widgets/anime_detail_dialog.dart
// ============================================================================
//
// [역할]
// 애니메이션 상세 정보 다이얼로그.
// 포스터, 제목, 평점, 장르, 시놉시스 표시.
//
// [레이어]
// Presentation Layer > Widgets
// ============================================================================

import 'package:flutter/material.dart';
import 'package:parrokit/features/recom/domain/anime_meta_data.dart';

/// 애니메이션 상세 다이얼로그 표시.
void showAnimeDetailDialog(BuildContext context, AnimeMetadata anime) {
  showDialog(
    context: context,
    builder: (ctx) => _AnimeDetailDialog(anime: anime),
  );
}

class _AnimeDetailDialog extends StatelessWidget {
  const _AnimeDetailDialog({required this.anime});

  final AnimeMetadata anime;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final size = MediaQuery.of(context).size;

    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      insetPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
      child: ConstrainedBox(
        constraints: BoxConstraints(
          maxWidth: 520,
          maxHeight: size.height * 0.70,
        ),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisSize: MainAxisSize.max,
            children: [
              // 닫기 버튼
              Align(
                alignment: Alignment.topRight,
                child: IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: () => Navigator.of(context).pop(),
                ),
              ),

              // 포스터 + 정보
              _buildHeader(theme),

              const SizedBox(height: 16),

              // 시놉시스
              _buildSynopsis(theme),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(ThemeData theme) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // 포스터
        Flexible(
          flex: 3,
          child: ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: AspectRatio(
              aspectRatio: 3 / 4,
              child: Image.network(
                anime.imageUrl,
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => Container(
                  color: theme.colorScheme.surfaceContainerHighest,
                  child: const Icon(Icons.image_not_supported),
                ),
              ),
            ),
          ),
        ),
        const SizedBox(width: 16),

        // 정보
        Expanded(
          flex: 5,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 제목
              Text(
                anime.nameKo,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),

              // 평점 + 타입
              Row(
                children: [
                  const Icon(Icons.star_rate_rounded, size: 18),
                  const SizedBox(width: 4),
                  Text(anime.score.toStringAsFixed(2)),
                  const SizedBox(width: 12),
                  Text(
                    anime.type,
                    style: theme.textTheme.bodySmall,
                  ),
                ],
              ),
              const SizedBox(height: 6),

              // 장르
              Text(
                anime.genres,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: theme.textTheme.bodySmall,
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildSynopsis(ThemeData theme) {
    return Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "개요",
            style: theme.textTheme.bodyLarge,
          ),
          const SizedBox(height: 8),
          Expanded(
            child: Scrollbar(
              thumbVisibility: true,
              child: SingleChildScrollView(
                child: Text(
                  anime.synopsisKo,
                  style: theme.textTheme.bodyMedium,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
