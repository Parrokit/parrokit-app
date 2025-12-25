// lib/mvp/library/library_screen.dart
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:parrokit/data/local/app_database.dart';
import 'package:parrokit/data/models/clip_item.dart';
import 'package:parrokit/core/router/app_router.dart';
import 'package:parrokit/core/provider/tag_filter_provider.dart';
import 'package:provider/provider.dart';
import 'package:parrokit/core/provider/media_provider.dart';
import '../../../data/constants/library_tab.dart';
import 'index.dart' as LibraryWidgets;

/// Toss-ish Library Screen
/// - 상단 "책갈피" 탭: [유형별 보기] | [태그로 보기]
/// - 유형별: BreadCrumb + 폴더/클립 리스트(데모)
/// - 태그로 보기: 카테고리 칩 + 결과 리스트(데모)
/// 외부 패키지 없이 머티리얼만 사용.

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
  final TextEditingController _tagSearchCtrl = TextEditingController();
  final Set<String> _selectedTags = {};
  late final TagFilterProvider _tagProv;

  @override
  void initState() {
    super.initState();
    tab = widget.initialTab == 1 ? LibraryTab.tag : LibraryTab.folder;

    WidgetsBinding.instance.addPostFrameCallback((_) async {
      final media = context.read<MediaProvider>();
      _tagProv = context.read<TagFilterProvider>();
      await _tagProv.startWatching();

      // loadTitles가 Future를 반환하도록 해두면 가장 깔끔
      await media.loadTitles();
      media.startWatchingDistinctTags();

      // 순서: Title → Release → Episode (있는 것만 적용)
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

  void _postFrame(VoidCallback fn) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      fn();
    });
  }

  @override
  void dispose() {
    _tagSearchCtrl.dispose(); // ✅ 메모리 누수 방지
    _tagProv.clearOnDispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context);
    final cs = t.colorScheme;
    final media = context.watch<MediaProvider>();

    final crumbs = <String>['라이브러리'];
    final names = _selectedTags.toList().reversed.toList(); //  역순으로 렌더
    final allTags = media.distinctTags;
// selectedTitleId 처리
    if (media.selectedTitleId != null) {
      final title =
          media.titles.where((x) => x.id == media.selectedTitleId).toList();
      if (title.isNotEmpty) {
        crumbs.add(title.first.name);
      } else {
        _postFrame(() => context.read<MediaProvider>().backToTitles()); // ✅
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
        _postFrame(() => context.read<MediaProvider>().backToReleases()); // ✅
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
        _postFrame(() => context.read<MediaProvider>().backToEpisodes()); // ✅
      }
    }

    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            const SizedBox(height: 8),
            LibraryWidgets.BookmarkTabs(
              value: tab,
              onChanged: (v) => setState(() => tab = v),
            ),
            const SizedBox(height: 10),
            if (tab == LibraryTab.folder) ...[
              LibraryWidgets.BreadcrumbBar(
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

              // 단계별 화면
              Expanded(
                child: Builder(
                  builder: (_) {
                    // 1) Titles
                    if (media.selectedTitleId == null) {
                      return LibraryWidgets.GridSection(
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
                      return LibraryWidgets.GridSection(
                        sectionTitle: '릴리스',
                        items: labels,
                        onTap: (idx) =>
                            media.selectRelease(media.releases[idx].id),
                      );
                    }

                    // 3) Episodes (새로 추가된 단계)
                    if (media.selectedEpisodeId == null) {
                      return LibraryWidgets.EpisodeListSimple(
                        episodes: media.episodes,
                        onOpen: (ep) => media.selectEpisode(ep.id),
                      );
                    }

                    // 4) Clips (해당 에피소드의 클립들)
                    return LibraryWidgets.ClipListFromProvider(
                        items: media.clipItems,
                        onOpen: (ci) {
                          context.push(
                            '${AppRoutes.clipsPath}/${AppRoutes.clipsPlayPath}?clipId=${ci.clip.id}',
                          );
                        });
                  },
                ),
              ),
            ] else ...[
              Expanded(
                child: Builder(
                  builder: (_) {
                    final allTags = media.distinctTags;
                    if (allTags.isEmpty) {
                      return const Center(child: Text('등록된 태그가 없습니다'));
                    }

                    // 자동완성 옵션 생성기 (이미 선택된 태그는 제외)
                    Iterable<Tag> _optionsFor(String query) {
                      final q = query.trim().toLowerCase();
                      final base = q.isEmpty
                          ? allTags
                          : allTags
                              .where((t) => t.name.toLowerCase().contains(q));
                      return base
                          .where((t) => !_selectedTags.contains(t.name))
                          .take(30);
                    }

                    // 드롭다운에서 컨트롤러/포커스 지우려고 참조 잡아둠
                    TextEditingController? _acCtrl;
                    FocusNode? _acFocus;

                    return Column(
                      children: [
                        // 🔎 자동완성 검색 + 전체해제 버튼
                        Padding(
                          padding: const EdgeInsets.fromLTRB(12, 4, 12, 8),
                          child: Row(
                            children: [
                              Expanded(
                                child: Autocomplete<Tag>(
                                  displayStringForOption: (t) => t.name,
                                  optionsBuilder: (text) =>
                                      _optionsFor(text.text),
                                  fieldViewBuilder: (context,
                                      textEditingController,
                                      focusNode,
                                      onFieldSubmitted) {
                                    _acCtrl = textEditingController;
                                    _acFocus = focusNode;
                                    return TextField(
                                      controller: textEditingController,
                                      focusNode: focusNode,
                                      textInputAction: TextInputAction.search,
                                      decoration: InputDecoration(
                                        hintText: '태그 검색',
                                        prefixIcon: const Icon(Icons.search),
                                        suffixIcon: (textEditingController
                                                .text.isEmpty)
                                            ? null
                                            : IconButton(
                                                icon: const Icon(Icons.clear),
                                                tooltip: '검색어 지우기',
                                                onPressed: () {
                                                  textEditingController.clear();
                                                  // rebuild 없이도 Autocomplete가 옵션을 갱신함
                                                  focusNode.requestFocus();
                                                },
                                              ),
                                        filled: true,
                                        isDense: true,
                                        border: OutlineInputBorder(
                                          borderRadius:
                                              BorderRadius.circular(12),
                                        ),
                                        contentPadding:
                                            const EdgeInsets.symmetric(
                                                horizontal: 12, vertical: 10),
                                      ),
                                      onChanged: (_) {
                                        // suffixIcon 갱신용
                                        // setState 없이도 Autocomplete가 옵션 드롭다운은 갱신하지만,
                                        // suffixIcon은 이 위젯 트리에서만 재빌드되므로 아래처럼 포커스 유지하며 강제 리빌드할 수도 있음.
                                        // setState(() {});
                                      },
                                    );
                                  },
                                  optionsViewBuilder:
                                      (context, onSelected, options) {
                                    return Align(
                                      alignment: Alignment.topLeft,
                                      child: Material(
                                        elevation: 4,
                                        borderRadius: BorderRadius.circular(10),
                                        child: SizedBox(
                                          width: 410,
                                          child: ConstrainedBox(
                                            constraints: const BoxConstraints(
                                                maxHeight: 280, minWidth: 240),
                                            child: ListView.separated(
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                      vertical: 6),
                                              shrinkWrap: true,
                                              itemCount: options.length,
                                              separatorBuilder: (_, __) =>
                                                  const Divider(
                                                      height: 1,
                                                      thickness: 0.5),
                                              itemBuilder: (context, index) {
                                                final t =
                                                    options.elementAt(index);
                                                return InkWell(
                                                  onTap: () => onSelected(t),
                                                  child: Padding(
                                                    padding: const EdgeInsets
                                                        .symmetric(
                                                        horizontal: 12,
                                                        vertical: 10),
                                                    child: Row(
                                                      children: [
                                                        const Icon(
                                                            Icons.auto_awesome,
                                                            size: 18),
                                                        const SizedBox(
                                                            width: 10),
                                                        Expanded(
                                                          child: Text(
                                                            t.name,
                                                            maxLines: 1,
                                                            overflow:
                                                                TextOverflow
                                                                    .ellipsis,
                                                            style: TextStyle(
                                                              fontSize: 14,
                                                              fontWeight:
                                                                  FontWeight
                                                                      .w600,
                                                              fontFamily: Theme
                                                                      .of(context)
                                                                  .textTheme
                                                                  .bodyMedium
                                                                  ?.fontFamily,
                                                            ),
                                                          ),
                                                        ),
                                                      ],
                                                    ),
                                                  ),
                                                );
                                              },
                                            ),
                                          ),
                                        ),
                                      ),
                                    );
                                  },
                                  onSelected: (t) {
                                    setState(() {
                                      _selectedTags.add(t.name);
                                    });
                                    // ✅ 디바운스 적용 OR 필터 반영
                                    context
                                        .read<TagFilterProvider>()
                                        .scheduleApply(() {
                                      context
                                          .read<TagFilterProvider>()
                                          .applyOrByTagNames(
                                              _selectedTags.toList());
                                    });

                                    _acCtrl?.clear();
                                    _acFocus?.unfocus();
                                  },
                                ),
                              ),
                              const SizedBox(width: 8),
                              // 전체 해제
                              SizedBox(
                                height: 48,
                                width: 48,
                                child: OutlinedButton(
                                  onPressed: allTags.isEmpty
                                      ? null
                                      : () {
                                          // 1) 모든 태그 선택
                                          setState(() {
                                            _selectedTags
                                              ..clear()
                                              ..addAll(
                                                  allTags.map((t) => t.name));
                                          });

                                          // 2) 디바운스로 OR 필터 적용
                                          context
                                              .read<TagFilterProvider>()
                                              .scheduleApply(() {
                                            context
                                                .read<TagFilterProvider>()
                                                .applyOrByTagNames(
                                                    _selectedTags.toList());
                                          });
                                        },
                                  style: OutlinedButton.styleFrom(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 12),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                  ),
                                  child: Text(
                                    'All',
                                    style: TextStyle(
                                      fontSize: 13,
                                      fontWeight: FontWeight.w600,
                                      color:
                                          Theme.of(context).colorScheme.primary,
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 8),

                              // 기존 전체 해제 버튼 (오른쪽)
                              SizedBox(
                                height: 48,
                                width: 48,
                                child: OutlinedButton(
                                  onPressed: _selectedTags.isEmpty
                                      ? null
                                      : () {
                                          setState(() => _selectedTags.clear());
                                          context
                                              .read<TagFilterProvider>()
                                              .scheduleApply(() {
                                            context
                                                .read<TagFilterProvider>()
                                                .applyOrByTagNames(const []);
                                          });
                                        },
                                  style: OutlinedButton.styleFrom(
                                    padding: EdgeInsets.zero,
                                    shape: RoundedRectangleBorder(
                                        borderRadius:
                                            BorderRadius.circular(12)),
                                  ),
                                  child: const Icon(Icons.cleaning_services,
                                      size: 20),
                                ),
                              ),
                            ],
                          ),
                        ),

                        // ⬇️ 선택된 태그들: 횡스크롤 한 줄
                        Padding(
                          padding: const EdgeInsets.fromLTRB(12, 0, 12, 8),
                          child: SizedBox(
                            height: 40, // 칩 높이에 맞춰 적당히
                            width: double.infinity,
                            child: _selectedTags.isEmpty
                                ? Align(
                                    alignment: Alignment.centerLeft,
                                    child: Text(
                                      '',
                                      style: Theme.of(context)
                                          .textTheme
                                          .bodyMedium
                                          ?.copyWith(
                                            color: Theme.of(context)
                                                .colorScheme
                                                .onSurface
                                                .withOpacity(0.5),
                                          ),
                                    ),
                                  )
                                : SingleChildScrollView(
                                    scrollDirection: Axis.horizontal,
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.start,
                                      children: [
                                        for (final name in names) ...[
                                          FilterChip(
                                            label: Text(
                                              name,
                                              overflow: TextOverflow.ellipsis,
                                              style: TextStyle(
                                                fontSize: 14,
                                                fontFamily: Theme.of(context)
                                                    .textTheme
                                                    .bodyMedium
                                                    ?.fontFamily,
                                                fontWeight: FontWeight.w600,
                                                color: Colors.white,
                                              ),
                                            ),
                                            selected: true,
                                            onSelected: (_) {},
                                            backgroundColor: Theme.of(context)
                                                .colorScheme
                                                .surfaceVariant,
                                            selectedColor: Theme.of(context)
                                                .colorScheme
                                                .primary,
                                            checkmarkColor: Colors.white,
                                            showCheckmark: false,
                                            shape: RoundedRectangleBorder(
                                              borderRadius:
                                                  BorderRadius.circular(
                                                      20), // ← 라운드 낮춤
                                              side: const BorderSide(
                                                  color: Color(0xFF0066FF),
                                                  width: 1),
                                            ),
                                            materialTapTargetSize:
                                                MaterialTapTargetSize
                                                    .shrinkWrap,
                                            visualDensity: const VisualDensity(
                                                horizontal: -2, vertical: -2),
                                            padding: const EdgeInsets.symmetric(
                                                horizontal: 12, vertical: 6),
                                            deleteIcon: const Icon(Icons.close,
                                                size: 16, color: Colors.white),
                                            onDeleted: () {
                                              setState(() =>
                                                  _selectedTags.remove(name));
                                              context
                                                  .read<TagFilterProvider>()
                                                  .scheduleApply(() {
                                                context
                                                    .read<TagFilterProvider>()
                                                    .applyOrByTagNames(
                                                        _selectedTags.toList());
                                              });
                                            },
                                          ),
                                          const SizedBox(width: 8),
                                        ],
                                      ],
                                    ),
                                  ),
                          ),
                        ),

                        // ⬇️ 결과 리스트(플레이스홀더)
                        // ⬇️ 결과 리스트
                        // 라이브러리 화면 결과 리스트 영역
                        Expanded(
                          child: Selector<TagFilterProvider, List<ClipItem>>(
                            selector: (_, p) => p.items,
                            shouldRebuild: (prev, next) {
                              // Provider 쪽 로직과 같은 기준
                              if (prev.length != next.length) return true;
                              for (var i = 0; i < prev.length; i++) {
                                if (prev[i].clip.id != next[i].clip.id)
                                  return true;
                              }
                              return false; // ✅ 동일하면 rebuild 안 함
                            },
                            builder: (_, items, __) {
                              return LibraryWidgets.ClipListFromProvider(
                                key: const PageStorageKey('tag_results_list'),
                                // ✅ 스크롤 상태 유지
                                items: items,
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
                  },
                ),
              ),
            ],
          ],
        ),
      ),
      backgroundColor: cs.surface,
    );
  }
}
