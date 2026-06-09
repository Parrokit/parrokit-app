import 'package:flutter/material.dart';
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
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      backgroundColor: colorScheme.surface,
      appBar: AppBar(
        title: const Text(
          '콜렉션',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        centerTitle: false,
        actions: [
          IconButton(
            icon: const Icon(Icons.search_rounded),
            onPressed: () {},
          ),
          IconButton(
            icon: const Icon(Icons.menu_rounded),
            onPressed: () {},
          ),
        ],
        bottom: TabBar(
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
