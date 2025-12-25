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
import 'package:parrokit/core/provider/media_provider.dart';
import 'package:parrokit/features/_content/library/presentation/providers/tag_filter_provider.dart';
import 'package:parrokit/data/local/app_database.dart'; // Tag definition

import '../domain/library_mode.dart';
import 'sections/library_folder_section.dart';
import 'sections/library_tag_section.dart';
import 'widgets/bookmark_tabs.dart';

/// Toss-ish Library Screen
/// - 상단 "책갈피" 탭: [유형별 보기] | [태그로 보기]
/// - 유형별: BreadCrumb + 폴더/클립 리스트
/// - 태그로 보기: 카테고리 칩 + 결과 리스트
class LibraryScreen extends StatefulWidget {
  const LibraryScreen({
    super.key,
    this.initialTitleId,
    this.initialReleaseId,
    this.initialEpisodeId,
    this.initialTab,
  });

  final int? initialTitleId;
  final int? initialReleaseId;
  final int? initialEpisodeId;
  final int? initialTab;

  @override
  State<LibraryScreen> createState() => _LibraryScreenState();
}

class _LibraryScreenState extends State<LibraryScreen>
    with SingleTickerProviderStateMixin {
  LibraryTab tab = LibraryTab.folder;

  // Tag Tab State
  final Set<String> _selectedTags = {};

  @override
  void initState() {
    super.initState();
    tab = widget.initialTab == 1 ? LibraryTab.tag : LibraryTab.folder;

    WidgetsBinding.instance.addPostFrameCallback((_) async {
      final media = context.read<MediaProvider>();
      final tagProv = context.read<TagFilterProvider>();

      await tagProv.startWatching();
      await media.loadTitles();
      media.startWatchingDistinctTags();

      if (widget.initialTitleId != null) {
        await media.selectTitle(widget.initialTitleId!);
      }
      if (widget.initialReleaseId != null) {
        await media.selectRelease(widget.initialReleaseId!);
      }
      if (widget.initialEpisodeId != null) {
        await media.selectEpisode(widget.initialEpisodeId!);
      }
    });
  }

  // --- Tag Logic ---

  void _onTagSelected(Tag t) {
    setState(() {
      _selectedTags.add(t.name);
    });
    _applyTagFilter();
  }

  void _onTagDeleted(String name) {
    setState(() {
      _selectedTags.remove(name);
    });
    _applyTagFilter();
  }

  void _onClearAllTags() {
    final media = context.read<MediaProvider>();
    if (media.distinctTags.isEmpty) return;

    setState(() {
      _selectedTags
        ..clear()
        ..addAll(media.distinctTags.map((t) => t.name));
    });
    _applyTagFilter();
  }

  void _onClearResult() {
    setState(() => _selectedTags.clear());
    context.read<TagFilterProvider>().scheduleApply(() {
      context.read<TagFilterProvider>().applyOrByTagNames(const []);
    });
  }

  void _applyTagFilter() {
    context.read<TagFilterProvider>().scheduleApply(() {
      context
          .read<TagFilterProvider>()
          .applyOrByTagNames(_selectedTags.toList());
    });
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final media = context.watch<MediaProvider>();

    return Scaffold(
      backgroundColor: cs.surface,
      body: SafeArea(
        child: Column(
          children: [
            const SizedBox(height: 8),
            BookmarkTabs(
              value: tab,
              onChanged: (v) => setState(() => tab = v),
            ),
            const SizedBox(height: 10),
            Expanded(
              child: tab == LibraryTab.folder
                  ? const LibraryFolderSection()
                  : LibraryTagSection(
                      allTags: media.distinctTags,
                      selectedTags: _selectedTags,
                      onTagSelected: _onTagSelected,
                      onTagDeleted: _onTagDeleted,
                      onClearAll: _onClearAllTags,
                      onClearResult: _onClearResult,
                    ),
            ),
          ],
        ),
      ),
    );
  }
}
