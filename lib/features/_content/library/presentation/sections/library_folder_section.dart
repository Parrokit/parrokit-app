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
import '../widgets/folder_grid.dart';
import '../widgets/clip_list_view.dart';

/// [역할]
/// 라이브러리의 '폴더' 탭 UI 섹션.
///
/// [계층 구조]
/// 1. Collections (컬렉션)
/// 2. Clips (클립)
class LibraryFolderSection extends StatelessWidget {
  const LibraryFolderSection({super.key});

  Future<void> _showCreateCollectionDialog(BuildContext context) async {
    final ctl = TextEditingController();
    final media = context.read<MediaProvider>();
    await showDialog<void>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('컬렉션 추가'),
        content: TextField(
          controller: ctl,
          autofocus: true,
          decoration: const InputDecoration(hintText: '컬렉션 이름'),
          onSubmitted: (_) async {
            final name = ctl.text.trim();
            if (name.isNotEmpty) await media.createCollection(name);
            if (ctx.mounted) Navigator.pop(ctx);
          },
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('취소')),
          TextButton(
            onPressed: () async {
              final name = ctl.text.trim();
              if (name.isNotEmpty) await media.createCollection(name);
              if (ctx.mounted) Navigator.pop(ctx);
            },
            child: const Text('추가'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final media = context.watch<MediaProvider>();

    // Breadcrumbs 생성
    final crumbs = <String>['라이브러리'];
    String? selectedCollectionName;

    if (media.selectedCollectionId != null) {
      final col = media.collections.cast<dynamic>().firstWhere(
            (c) => (c.id as int) == media.selectedCollectionId,
            orElse: () => null,
          );
      if (col != null) {
        selectedCollectionName = col.name as String;
        crumbs.add(selectedCollectionName);
      } else {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (context.mounted) {
            context.read<MediaProvider>().backToCollections();
          }
        });
      }
    }

    final isInsideCollection = media.selectedCollectionId != null;

    return Stack(
      children: [
        Column(
          children: [
            BreadcrumbBar(
              path: crumbs,
              onTapCrumb: (i) {
                if (i == 0) media.backToCollections();
              },
            ),
            const SizedBox(height: 10),
            Expanded(
              child: Builder(
                builder: (_) {
                  // 1) Collections
                  if (!isInsideCollection) {
                    return FolderGrid(
                      sectionTitle: '컬렉션',
                      items: media.collections
                          .map((c) => (c as dynamic).name as String)
                          .toList(),
                      onTap: (idx) =>
                          media.selectCollection(media.collections[idx].id),
                    );
                  }

                  // 2) Clips
                  return ClipListView(
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
        ),

        // FAB
        Positioned(
          right: 16,
          bottom: 16,
          child: FloatingActionButton(
            heroTag: 'library_fab',
            onPressed: isInsideCollection
                ? () {
                    final colName = Uri.encodeComponent(selectedCollectionName ?? '');
                    context.push(
                      '${AppRoutes.clipsPath}/${AppRoutes.clipsCreatePath}?collectionName=$colName',
                    );
                  }
                : () => _showCreateCollectionDialog(context),
            child: const Icon(Icons.add),
          ),
        ),
      ],
    );
  }
}
