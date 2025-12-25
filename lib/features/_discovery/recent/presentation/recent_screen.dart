// ============================================================================
// lib/features/recent/presentation/recent_screen.dart
// ============================================================================
//
// [역할]
// 최근 본 클립 목록 화면.
// 사용자가 최근 시청한 클립들을 리스트로 표시.
//
// [레이어]
// Presentation Layer - View
//
// [구성 요소]
// - RecentClipCard: 클립 카드 위젯
// - RecentListSkeleton: 로딩 스켈레톤
// - EmptyRecentView: 빈 상태 표시
// ============================================================================

import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:parrokit/core/provider/clip_activity_provider.dart';
import 'package:parrokit/features/_content/player/presentation/clip_player_screen.dart';

import 'widgets/recent_clip_card.dart';
import 'widgets/recent_list_skeleton.dart';
import 'widgets/empty_recent_view.dart';

/// 최근 본 클립 목록 화면.
class RecentScreen extends StatefulWidget {
  const RecentScreen({super.key});

  @override
  State<RecentScreen> createState() => _RecentScreenState();
}

class _RecentScreenState extends State<RecentScreen> {
  // ─────────────────────────────────────────────────────────────────
  // State
  // ─────────────────────────────────────────────────────────────────

  late Future<List<(int, Uint8List?, String?, String?)>> _future;

  // ─────────────────────────────────────────────────────────────────
  // Lifecycle
  // ─────────────────────────────────────────────────────────────────

  @override
  void initState() {
    super.initState();
    _future = _load();
  }

  // ─────────────────────────────────────────────────────────────────
  // Data Loading
  // ─────────────────────────────────────────────────────────────────

  Future<List<(int, Uint8List?, String?, String?)>> _load({
    bool refreshThumb = false,
  }) {
    final provider = context.read<ClipActivityProvider>();
    return provider.fetchRecentClips(limit: 100, refreshThumb: refreshThumb);
  }

  Future<void> _onRefresh() async {
    final future = _load();
    setState(() => _future = future);
    await future;
  }

  // ─────────────────────────────────────────────────────────────────
  // Actions
  // ─────────────────────────────────────────────────────────────────

  void _openPlayer(int clipId) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => ClipPlayerScreen(
          clipId: clipId,
          initialIndex: 0,
        ),
      ),
    );
  }

  // ─────────────────────────────────────────────────────────────────
  // Build
  // ─────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text('최근 본 클립'),
      ),
      body: RefreshIndicator(
        onRefresh: _onRefresh,
        child: FutureBuilder<List<(int, Uint8List?, String?, String?)>>(
          future: _future,
          builder: (context, snap) {
            // 로딩 중
            if (snap.connectionState == ConnectionState.waiting) {
              return const RecentListSkeleton();
            }

            // 에러
            if (snap.hasError) {
              return Center(
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: Text(
                    '최근 목록을 불러오는 중 오류가 발생했어요.\n${snap.error}',
                    textAlign: TextAlign.center,
                  ),
                ),
              );
            }

            // 빈 상태
            final items = snap.data ?? const [];
            if (items.isEmpty) {
              return const EmptyRecentView();
            }

            // 리스트
            return ListView.separated(
              padding: const EdgeInsets.fromLTRB(12, 8, 12, 16),
              itemCount: items.length,
              separatorBuilder: (_, __) => Divider(
                height: 8,
                thickness: 0.5,
                color: cs.outlineVariant.withOpacity(.6),
              ),
              itemBuilder: (context, index) {
                final (clipId, thumb, clipTitle, titleName) = items[index];
                return RecentClipCard(
                  clipId: clipId,
                  thumb: thumb,
                  clipTitle: clipTitle ?? '제목 없음',
                  titleName: titleName,
                  onTap: () => _openPlayer(clipId),
                );
              },
            );
          },
        ),
      ),
    );
  }
}
