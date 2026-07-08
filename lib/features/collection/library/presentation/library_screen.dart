// ============================================================================
// lib/features/_content/library/presentation/library_screen.dart
// ============================================================================
//
// [역할]
// 라이브러리 메인 화면 (폴더/태그 탭 전환)
//
// [레이어]
// Presentation Layer > Screen
//
// ============================================================================

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:parrokit/core/state/provider/clip_provider.dart';
import 'package:parrokit/features/collection/library/presentation/providers/tag_filter_provider.dart';
import 'package:parrokit/data/local/app_database.dart'; // Tag definition

import '../domain/library_mode.dart';
import 'sections/library_folder_section.dart';
import 'sections/library_tag_section.dart';
import 'widgets/bookmark_tabs.dart';

/// [역할]
/// 라이브러리 메인 화면.
///
/// '폴더(Collections)별 보기'와 '태그별 보기' 두 가지 모드를 제공합니다.
/// 상단 [BookmarkTabs]를 통해 모드를 전환할 수 있습니다.
///
/// [기능]
/// - [LibraryTab.folder]: [LibraryFolderSection] 표시 (컬렉션 → 클립)
/// - [LibraryTab.tag]: [LibraryTagSection] 표시 (태그 기반 필터링 및 검색)
/// - 초기 진입 시 특정 Collection으로 바로 이동 가능 ([initialCollectionId])
class LibraryScreen extends StatefulWidget {
  const LibraryScreen({
    super.key,
    this.initialCollectionId,
    this.initialTab,
  });

  /// 초기 선택할 Collection ID (옵션)
  final int? initialCollectionId;

  /// 초기 활성화할 탭 인덱스 (0: Folder, 1: Tag)
  final int? initialTab;

  @override
  State<LibraryScreen> createState() => _LibraryScreenState();
}

class _LibraryScreenState extends State<LibraryScreen> {
  LibraryTab tab = LibraryTab.folder;

  @override
  void initState() {
    super.initState();
    tab = widget.initialTab == 1 ? LibraryTab.tag : LibraryTab.folder;

    WidgetsBinding.instance.addPostFrameCallback((_) async {
      final clipProvider = context.read<ClipProvider>();
      final tagProv = context.read<TagFilterProvider>();

      await tagProv.startWatching();
      clipProvider.startWatchingDistinctTags();

      if (widget.initialCollectionId != null) {
        await clipProvider.loadCollections();
        await clipProvider.selectCollection(widget.initialCollectionId);
      } else {
        await clipProvider.loadGroups();
      }
    });
  }

  // --- Tag Logic (Provider 위임) ---

  void _onTagSelected(Tag t) {
    context.read<TagFilterProvider>().addTag(t.name);
  }

  void _onTagDeleted(String name) {
    context.read<TagFilterProvider>().removeTag(name);
  }

  void _onSelectAllTags() {
    final clipProvider = context.read<ClipProvider>();
    if (clipProvider.distinctTags.isEmpty) return;

    context.read<TagFilterProvider>().setTags(
          clipProvider.distinctTags.map((t) => t.name),
        );
  }

  void _onClearResult() {
    context.read<TagFilterProvider>().clearTags();
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final clipProvider = context.watch<ClipProvider>();
    final tagProv = context.watch<TagFilterProvider>();
    final isSelectionMode = clipProvider.isCollectionMenuOpen &&
        clipProvider.selectedCollectionId != null;

    return Scaffold(
      backgroundColor: cs.surface,
      body: SafeArea(
        child: Column(
          children: [
            if (!isSelectionMode) ...[
              const SizedBox(height: 8),
              BookmarkTabs(
                value: tab,
                onChanged: (v) => setState(() => tab = v),
              ),
              const SizedBox(height: 10),
            ],
            Expanded(
              child: tab == LibraryTab.folder
                  ? const LibraryFolderSection()
                  : LibraryTagSection(
                      allTags: clipProvider.distinctTags,
                      selectedTags: tagProv.activeTagNames.toSet(),
                      onTagSelected: _onTagSelected,
                      onTagDeleted: _onTagDeleted,
                      onSelectAll: _onSelectAllTags,
                      onClearResult: _onClearResult,
                    ),
            ),
          ],
        ),
      ),
    );
  }
}
