import 'package:flutter/material.dart';
import 'package:parrokit/core/state/provider/clip_provider.dart';
import 'package:provider/provider.dart';
import 'package:parrokit/features/collection/library/presentation/library_screen.dart';

/// 콜렉션 메인 탭바 쉘 화면
class CollectionShellScreen extends StatefulWidget {
  const CollectionShellScreen({super.key});

  @override
  State<CollectionShellScreen> createState() => _CollectionShellScreenState();
}

class _CollectionShellScreenState extends State<CollectionShellScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _tabController.addListener(_handleTabChanged);
  }

  void _handleTabChanged() {
    if (!mounted) return;
    setState(() {});

    if (_tabController.index != 0) {
      context.read<ClipProvider>().closeCollectionMenu();
    }
  }

  @override
  void dispose() {
    _tabController.removeListener(_handleTabChanged);
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final clipProvider = context.watch<ClipProvider>();
    final isClipTab = _tabController.index == 0;
    final isSelectionMode = clipProvider.isCollectionMenuOpen && isClipTab;
    final visibleClipIds =
        clipProvider.clipItems.map((item) => item.clip.id).toSet();
    final selectedClipIds = clipProvider.selectedClipIds;
    final isAllSelected = visibleClipIds.isNotEmpty &&
        visibleClipIds.length == selectedClipIds.length;

    return Scaffold(
      backgroundColor: colorScheme.surface,
      appBar: AppBar(
        title: const Text(
          '콜렉션',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        centerTitle: false,
        actions: [
          if (isSelectionMode)
            Padding(
              padding: const EdgeInsets.only(right: 8),
              child: TextButton(
                onPressed: visibleClipIds.isEmpty
                    ? null
                    : () {
                        if (isAllSelected) {
                          clipProvider.clearClipSelection();
                        } else {
                          clipProvider.selectAllVisibleClips();
                        }
                      },
                child: Text(isAllSelected ? '전체 해제' : '전체 선택'),
              ),
            ),
        ],
        bottom: isSelectionMode
            ? null
            : TabBar(
                controller: _tabController,
                isScrollable: true,
                tabAlignment: TabAlignment.start,
                labelColor: colorScheme.onSurface,
                labelStyle:
                    const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                unselectedLabelColor: colorScheme.onSurfaceVariant,
                unselectedLabelStyle:
                    const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                indicatorColor: colorScheme.onSurface,
                indicatorSize: TabBarIndicatorSize.label,
                dividerColor: Colors.transparent,
                padding: EdgeInsets.zero,
                labelPadding: const EdgeInsets.symmetric(horizontal: 16.0),
                tabs: const [
                  Tab(text: '클립'),
                  Tab(text: '문장'),
                  Tab(text: '단어'),
                ],
              ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          // 1. 미디어 탭 (기존 라이브러리 스크린)
          const LibraryScreen(),

          // 2. 문장 탭 (임시)
          Center(
            child: Text(
              '문장 노트 준비 중',
              style: TextStyle(color: colorScheme.onSurfaceVariant),
            ),
          ),

          // 3. 단어 탭 (임시)
          Center(
            child: Text(
              '나만의 단어장 준비 중',
              style: TextStyle(color: colorScheme.onSurfaceVariant),
            ),
          ),
        ],
      ),
    );
  }
}
