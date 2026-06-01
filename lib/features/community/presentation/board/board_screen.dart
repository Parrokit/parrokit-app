import 'package:flutter/material.dart';
import 'package:parrokit/features/community/presentation/widgets/community_board_post_tile.dart';
import 'package:provider/provider.dart';
import 'package:parrokit/features/community/providers/community_provider.dart';

class BoardScreen extends StatefulWidget {
  final String selectedFilter;

  const BoardScreen({super.key, required this.selectedFilter});

  @override
  State<BoardScreen> createState() => _BoardScreenState();
}

class _BoardScreenState extends State<BoardScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<CommunityProvider>().fetchPosts(postType: 'board', refresh: true);
    });
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<CommunityProvider>();
    final colorScheme = Theme.of(context).colorScheme;

    if (provider.isLoading && provider.posts.isEmpty) {
      return const Center(child: CircularProgressIndicator());
    }

    final filteredPosts = provider.getBoardPostsByFilter(widget.selectedFilter);

    if (filteredPosts.isEmpty) {
      return Center(
        child: Text(
          '등록된 게시글이 없습니다.',
          style: Theme.of(context).textTheme.bodyLarge?.copyWith(
            color: colorScheme.onSurfaceVariant,
          ),
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: () =>
          context.read<CommunityProvider>().fetchPosts(postType: 'board', refresh: true),
      child: ListView.separated(
        padding: const EdgeInsets.only(bottom: 80),
        itemCount: filteredPosts.length,
        separatorBuilder: (context, index) =>
            Divider(color: colorScheme.outlineVariant, height: 1),
        itemBuilder: (context, index) {
          return CommunityBoardPostTile(post: filteredPosts[index]);
        },
      ),
    );
  }
}
