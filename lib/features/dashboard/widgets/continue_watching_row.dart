import 'dart:typed_data';
import 'package:flutter/material.dart';

class ContinueWatchingRow extends StatelessWidget {
  const ContinueWatchingRow({
    super.key,
    required this.items,           // (clipId, thumbnail, clipTitle, titleName)
    required this.cardBg,
    required this.subtle,
    required this.textPrimary,
    required this.textSecondary,
    required this.onTapItem,       // (clipId) => ...
    required this.onTapMore,       // () => ...
  });

  final List<(int, Uint8List?, String?, String?)> items;
  final Color cardBg;
  final Color subtle;
  final Color textPrimary;
  final Color textSecondary;
  final void Function(int clipId) onTapItem;
  final VoidCallback onTapMore;

  @override
  Widget build(BuildContext context) {
    final showGuide = items.isEmpty || items.length < 6;
    final itemCount = items.isEmpty ? 1 : items.length + (showGuide ? 1 : 0);

    return SizedBox(
      height: 164,
      child: ListView.separated(
        padding: const EdgeInsets.fromLTRB(20, 12, 20, 0),
        scrollDirection: Axis.horizontal,
        itemCount: itemCount,
        separatorBuilder: (_, __) => const SizedBox(width: 12),
        itemBuilder: (context, i) {
          // 1) 안내 카드 (없거나 6개 미만일 때 끝에 1장 추가)
          if (items.isEmpty || (i == items.length && showGuide)) {
            return _MoreCard(
              subtle: subtle,
              textSecondary: textSecondary,
              onTap: onTapMore,
              isEmpty: items.isEmpty,
            );
          }

          // 2) 일반 카드
          final (clipId, imageBytes, clipTitle, titleName) = items[i];
          return _ItemCard(
            clipId: clipId,
            imageBytes: imageBytes,
            clipTitle: clipTitle ?? '무제',
            titleName: titleName,
            cardBg: cardBg,
            subtle: subtle,
            onTap: () => onTapItem(clipId),
          );
        },
      ),
    );
  }
}

class _ItemCard extends StatelessWidget {
  const _ItemCard({
    required this.clipId,
    required this.imageBytes,
    required this.clipTitle,
    required this.titleName,
    required this.cardBg,
    required this.subtle,
    required this.onTap,
  });

  final int clipId;
  final Uint8List? imageBytes;
  final String clipTitle;
  final String? titleName;
  final Color cardBg;
  final Color subtle;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 220,
        decoration: BoxDecoration(
          color: cardBg,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: subtle),
        ),
        clipBehavior: Clip.antiAlias,
        child: Stack(
          children: [
            // 썸네일
            Positioned.fill(
              child: imageBytes != null
                  ? Image.memory(imageBytes!, fit: BoxFit.cover)
                  : _thumbPlaceholder(),
            ),
            // 상단 라벨(작품명)
            if (titleName != null && titleName!.isNotEmpty)
              Positioned(
                left: 10, top: 10,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.black.withOpacity(0.45),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    titleName!,
                    maxLines: 1, overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: Colors.white, fontSize: 12, fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ),
            // 재생 버튼 느낌
            Positioned.fill(
              child: IgnorePointer(
                child: Center(
                  child: Container(
                    width: 44, height: 44,
                    decoration: BoxDecoration(
                      color: Colors.black.withOpacity(0.30),
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.white.withOpacity(0.7), width: 1),
                    ),
                    child: const Icon(Icons.play_arrow_rounded, color: Colors.white, size: 30),
                  ),
                ),
              ),
            ),
            // 하단 그라데이션 + 텍스트 + 진행바
            Positioned(
              left: 0, right: 0, bottom: 0,
              child: Container(
                padding: const EdgeInsets.fromLTRB(12, 16, 12, 12),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter, end: Alignment.bottomCenter,
                    colors: [Colors.transparent, Colors.black.withOpacity(0.75)],
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      clipTitle,
                      maxLines: 1, overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: Colors.white, fontWeight: FontWeight.w800, fontSize: 14,
                      ),
                    ),

                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _thumbPlaceholder() {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0xFF0f172a), Color(0xFF1f2937)],
          begin: Alignment.topLeft, end: Alignment.bottomRight,
        ),
      ),
      child: const Center(
        child: Icon(Icons.movie, color: Colors.white70, size: 28),
      ),
    );
  }
}

class _MoreCard extends StatelessWidget {
  const _MoreCard({
    super.key,
    required this.subtle,
    required this.textSecondary,
    required this.onTap,
    required this.isEmpty,
  });

  final Color subtle;
  final Color textSecondary;
  final VoidCallback onTap;
  final bool isEmpty;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final cardBg = isDark ? const Color(0xFF15181C) : Colors.white;

    if (isEmpty) {
      // 👉 비었을 때: 단순 Empty 카드
      return Container(
        width: 220,
        decoration: BoxDecoration(
          color: cardBg,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: subtle),
        ),
        child: Center(
          child: Text(
            "아직 등록된 클립이 없어요",
            style: TextStyle(
              color: textSecondary,
              fontSize: 14,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      );
    }

    // 👉 비어있지 않을 때: 원래 “더 보러가기” 카드
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 220,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: subtle),
          color: cardBg,
        ),
        child: Stack(
          children: [
            // 약한 패턴 배경
            Positioned.fill(
              child: Opacity(
                opacity: .05,
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      stops: const [0.0, .5, 1.0],
                      colors: [Colors.white, Colors.transparent, Colors.white],
                    ),
                  ),
                ),
              ),
            ),
            // 가운데 내용
            Positioned.fill(
              child: Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 52,
                      height: 52,
                      decoration: BoxDecoration(
                        color: Colors.black.withOpacity(0.06),
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(color: subtle),
                      ),
                      child: Icon(
                        Icons.grid_view_rounded,
                        size: 28,
                        color: textSecondary,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      '더 보러가기',
                      style: TextStyle(
                        color: textSecondary,
                        fontSize: 15,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      '라이브러리에서 전체 보기',
                      textAlign: TextAlign.center,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: textSecondary.withOpacity(.8),
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}