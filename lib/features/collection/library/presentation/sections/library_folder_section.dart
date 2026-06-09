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
import 'package:parrokit/core/app/router/app_router.dart';
import 'package:parrokit/core/state/provider/media_provider.dart';
import '../widgets/breadcrumb_bar.dart';
import '../widgets/folder_grid.dart';
import '../widgets/clip_list_view.dart';

/// [역할]
/// 라이브러리의 '폴더' 탭 UI 섹션.
///
/// [계층 구조]
/// 1. Collections (컬렉션)
/// 2. Clips (클립)
class LibraryFolderSection extends StatefulWidget {
  const LibraryFolderSection({super.key});

  @override
  State<LibraryFolderSection> createState() => _LibraryFolderSectionState();
}

class _LibraryFolderSectionState extends State<LibraryFolderSection> {
  bool _deleteMode = false;

  void _toggleDeleteMode() => setState(() => _deleteMode = !_deleteMode);

  void _showFabMenu(BuildContext fabCtx, bool isAtGroupRoot) {
    final renderBox = fabCtx.findRenderObject() as RenderBox;
    final overlay =
        Overlay.of(fabCtx).context.findRenderObject() as RenderBox;
    final offset = renderBox.localToGlobal(Offset.zero, ancestor: overlay);
    final size = renderBox.size;

    showMenu<String>(
      context: fabCtx,
      position: RelativeRect.fromLTRB(
        offset.dx,
        offset.dy - 110,
        overlay.size.width - offset.dx - size.width,
        overlay.size.height - offset.dy,
      ),
      items: [
        PopupMenuItem(value: 'add', child: Text(isAtGroupRoot ? '그룹 추가하기' : '콜렉션 추가하기')),
        const PopupMenuItem(value: 'delete', child: Text('삭제 모드')),
      ],
    ).then((value) {
      if (!mounted) return;
      if (value == 'add') {
        if (isAtGroupRoot) {
          _showCreateGroupDialog(context);
        } else {
          _showCreateCollectionDialog(context);
        }
      } else if (value == 'delete') {
        setState(() => _deleteMode = true);
      }
    });
  }

  Future<void> _showDeleteGroupDialog(
    BuildContext context,
    int groupId,
    String name,
  ) async {
    if (!context.mounted) return;
    final cs = Theme.of(context).colorScheme;
    
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('그룹 삭제'),
        content: Text("'$name' 그룹과 하위의 모든 콜렉션, 클립이 삭제됩니다.\n\n이 작업은 되돌릴 수 없습니다."),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('취소'),
          ),
          FilledButton(
            style: FilledButton.styleFrom(backgroundColor: cs.error),
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('삭제'),
          ),
        ],
      ),
    );

    if (ok == true && context.mounted) {
      await context.read<MediaProvider>().deleteGroupById(groupId);
    }
  }

  Future<void> _showCreateGroupDialog(BuildContext context) async {
    final ctl = TextEditingController();
    final media = context.read<MediaProvider>();
    await showDialog<void>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('그룹 추가'),
        content: TextField(
          controller: ctl,
          autofocus: true,
          decoration: const InputDecoration(hintText: '그룹 이름'),
          onSubmitted: (_) async {
            final name = ctl.text.trim();
            if (name.isNotEmpty) await media.createGroup(name);
            if (ctx.mounted) Navigator.pop(ctx);
          },
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('취소')),
          TextButton(
            onPressed: () async {
              final name = ctl.text.trim();
              if (name.isNotEmpty) await media.createGroup(name);
              if (ctx.mounted) Navigator.pop(ctx);
            },
            child: const Text('추가'),
          ),
        ],
      ),
    );
  }

  Future<void> _showDeleteCollectionDialog(
    BuildContext context,
    int collectionId,
    String name,
  ) async {
    final media = context.read<MediaProvider>();
    final clipCount = await media.countClipsInCollection(collectionId);
    if (!context.mounted) return;

    final cs = Theme.of(context).colorScheme;
    final content = clipCount > 0
        ? "'$name' 컬렉션과 포함된 클립 $clipCount개를 모두 삭제할까요?\n\n이 작업은 되돌릴 수 없습니다."
        : "'$name' 컬렉션을 삭제할까요?";

    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('컬렉션 삭제'),
        content: Text(content),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('취소'),
          ),
          FilledButton(
            style: FilledButton.styleFrom(backgroundColor: cs.error),
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('삭제'),
          ),
        ],
      ),
    );

    if (ok == true && context.mounted) {
      await context.read<MediaProvider>().deleteCollectionById(collectionId);
    }
  }

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
    final cs = Theme.of(context).colorScheme;

    // Breadcrumbs 생성
    final crumbs = <String>['미디어 보관함'];
    String? selectedGroupName;
    String? selectedCollectionName;

    if (media.selectedGroupId != null) {
      if (media.selectedGroupId == -1) {
        selectedGroupName = '모든 콜렉션';
        crumbs.add(selectedGroupName);
      } else {
        final grp = media.groups.cast<dynamic>().firstWhere(
              (g) => (g.id as int) == media.selectedGroupId,
              orElse: () => null,
            );
        if (grp != null) {
          selectedGroupName = grp.name as String;
          crumbs.add(selectedGroupName);
        } else {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (context.mounted) {
              context.read<MediaProvider>().backToGroups();
            }
          });
        }
      }
    }

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

    final isAtClipList = media.selectedCollectionId != null;
    final isAtCollectionList = media.selectedGroupId != null && media.selectedCollectionId == null;
    final isAtGroupRoot = media.selectedGroupId == null;

    // 클립 목록으로 들어오면 삭제 모드 자동 해제
    if (isAtClipList && _deleteMode) {
      WidgetsBinding.instance
          .addPostFrameCallback((_) => setState(() => _deleteMode = false));
    }

    return Stack(
      children: [
        Column(
          children: [
            BreadcrumbBar(
              path: crumbs,
              onTapCrumb: (i) {
                if (i == 0) {
                  setState(() => _deleteMode = false);
                  media.backToGroups();
                } else if (i == 1 && crumbs.length > 2) {
                  setState(() => _deleteMode = false);
                  media.backToCollections();
                }
              },
            ),

            // 삭제 모드 배너
            if (_deleteMode && !isAtClipList)
              Container(
                color: cs.errorContainer,
                width: double.infinity,
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: Row(
                  children: [
                    Icon(Icons.delete_outline_rounded,
                        size: 16, color: cs.onErrorContainer),
                    const SizedBox(width: 8),
                    Text('삭제 모드 — 컬렉션을 눌러 삭제',
                        style: TextStyle(
                            color: cs.onErrorContainer, fontSize: 13)),
                    const Spacer(),
                    TextButton(
                      onPressed: _toggleDeleteMode,
                      child: Text('완료',
                          style: TextStyle(color: cs.onErrorContainer)),
                    ),
                  ],
                ),
              ),

            const SizedBox(height: 10),

            Expanded(
              child: Builder(
                builder: (_) {
                  if (isAtGroupRoot) {
                    final gridItems = [
                      '모든 콜렉션',
                      ...media.groups.map((g) => (g as dynamic).name as String)
                    ];
                    return FolderGrid(
                      sectionTitle: '그룹',
                      items: gridItems,
                      deleteMode: _deleteMode,
                      onTap: (idx) {
                        if (idx == 0) {
                          if (!_deleteMode) {
                            media.selectGroup(-1);
                          }
                          return;
                        }
                        
                        final grp = media.groups[idx - 1];
                        if (_deleteMode) {
                          _showDeleteGroupDialog(context, grp.id, grp.name);
                        } else {
                          media.selectGroup(grp.id);
                        }
                      },
                    );
                  }

                  // 2) Collections
                  if (isAtCollectionList) {
                    return FolderGrid(
                      sectionTitle: '컬렉션',
                      items: media.collections
                          .map((c) => (c as dynamic).name as String)
                          .toList(),
                      deleteMode: _deleteMode,
                      onTap: (idx) {
                        final col = media.collections[idx];
                        if (_deleteMode) {
                          _showDeleteCollectionDialog(
                              context, col.id, col.name);
                        } else {
                          media.selectCollection(col.id);
                        }
                      },
                    );
                  }

                  // 3) Clips
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
          child: Builder(
            builder: (fabCtx) => FloatingActionButton(
              heroTag: 'library_fab',
              onPressed: isAtClipList
                  ? () {
                      final colName =
                          Uri.encodeComponent(selectedCollectionName ?? '');
                      context.push(
                        '${AppRoutes.clipsPath}/${AppRoutes.clipsCreatePath}?collectionName=$colName',
                      );
                    }
                  : () => _showFabMenu(fabCtx, isAtGroupRoot),
              child: Icon(isAtClipList
                  ? Icons.add
                  : Icons.more_horiz_rounded),
            ),
          ),
        ),
      ],
    );
  }
}
