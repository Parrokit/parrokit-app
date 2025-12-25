// ============================================================================
// lib/features/_content/library/presentation/sections/library_folder_section.dart
// ============================================================================
//
// [역할]
// 라이브러리 화면의 "폴더" 탭 섹션 (Breadcrumb + Grid/List)
//
// [레이어]
// Presentation Layer > Sections
//
// ============================================================================

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:parrokit/core/router/app_router.dart';
import 'package:parrokit/core/provider/media_provider.dart';
import '../widgets/breadcrumb_bar.dart';
import '../widgets/grid_section.dart';
import '../widgets/episode_list_sample.dart';
import '../widgets/clip_list_from_provider.dart';

class LibraryFolderSection extends StatelessWidget {
  const LibraryFolderSection({super.key});

  @override
  Widget build(BuildContext context) {
    final media = context.watch<MediaProvider>();

    // Breadcrumbs 생성
    final crumbs = <String>['라이브러리'];

    // selectedTitleId 처리
    if (media.selectedTitleId != null) {
      final title =
          media.titles.where((x) => x.id == media.selectedTitleId).toList();
      if (title.isNotEmpty) {
        crumbs.add(title.first.name);
      } else {
        // 데이터 불일치 시 복구
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (context.mounted) context.read<MediaProvider>().backToTitles();
        });
      }
    }

    // selectedReleaseId 처리
    if (media.selectedReleaseId != null) {
      final rel =
          media.releases.where((x) => x.id == media.selectedReleaseId).toList();
      if (rel.isNotEmpty) {
        final r = rel.first;
        final label = r.type == 'season' ? 'S${r.number}' : '영화';
        crumbs.add(label);
      } else {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (context.mounted) context.read<MediaProvider>().backToReleases();
        });
      }
    }

    // selectedEpisodeId 처리
    if (media.selectedEpisodeId != null) {
      final ep =
          media.episodes.where((x) => x.id == media.selectedEpisodeId).toList();
      if (ep.isNotEmpty) {
        final e = ep.first;
        final epLabel = (e.number != null)
            ? 'E${e.number!.toString().padLeft(2, '0')}'
            : (e.title ?? 'Episode');
        crumbs.add(epLabel);
      } else {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (context.mounted) context.read<MediaProvider>().backToEpisodes();
        });
      }
    }

    return Column(
      children: [
        BreadcrumbBar(
          path: crumbs,
          onTapCrumb: (i) {
            // 0: 루트, 1: 타이틀, 2: 릴리스
            if (i == 0) {
              media.backToTitles();
            } else if (i == 1) {
              media.backToReleases();
            } else if (i == 2) {
              media.backToEpisodes();
            }
          },
        ),
        const SizedBox(height: 10),
        Expanded(
          child: Builder(
            builder: (_) {
              // 1) Titles
              if (media.selectedTitleId == null) {
                return GridSection(
                  sectionTitle: '작품',
                  items: media.titles.map((e) => e.name).toList(),
                  onTap: (idx) => media.selectTitle(media.titles[idx].id),
                );
              }

              // 2) Releases
              if (media.selectedReleaseId == null) {
                final labels = media.releases.map((r) {
                  if (r.type == 'season') return 'S${r.number}';
                  return '영화';
                }).toList();
                return GridSection(
                  sectionTitle: '릴리스',
                  items: labels,
                  onTap: (idx) => media.selectRelease(media.releases[idx].id),
                );
              }

              // 3) Episodes
              if (media.selectedEpisodeId == null) {
                return EpisodeListSimple(
                  episodes: media.episodes,
                  onOpen: (ep) => media.selectEpisode(ep.id),
                );
              }

              // 4) Clips
              return ClipListFromProvider(
                items: media.clipItems,
                onOpen: (ci) {
                  context.push(
                    '${AppRoutes.clipsPath}/${AppRoutes.clipsPlayPath}?clipId=${ci.clip.id}',
                  );
                },
              );
            },
          ),
        ),
      ],
    );
  }
}
