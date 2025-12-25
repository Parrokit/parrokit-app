import 'package:flutter/material.dart';
import 'dart:typed_data';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:video_player/video_player.dart';

class PickedState extends StatelessWidget {
  const PickedState({
    super.key,
    required this.picked,
    required this.onReplace, // 파일에서 다시 선택
    required this.onPickFromPhotos, // ✅ 사진에서 다시 선택
    required this.onRemove,
    this.thumb,
    required this.isPlayingInline,
    required this.playerController,
    required this.onPlayInline,
    required this.onToggleInline,
    required this.onStopInline,
  });

  final PlatformFile picked;
  final VoidCallback onReplace;
  final VoidCallback onPickFromPhotos; // ✅ 추가
  final VoidCallback onRemove;
  final Uint8List? thumb;
  final bool isPlayingInline;
  final VideoPlayerController? playerController;
  final VoidCallback onPlayInline;
  final VoidCallback onToggleInline;
  final VoidCallback onStopInline;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;
    final borderColor = cs.outlineVariant;
    final subtle = cs.onSurface.withOpacity(0.6);

    final name = picked.name;
    final ext = (picked.extension ?? 'file').toLowerCase();
    final sizeKB = (picked.size / 1024).ceil();

    final bool showPlayer = isPlayingInline &&
        playerController != null &&
        playerController!.value.isInitialized;
    final double aspect =
        showPlayer ? playerController!.value.aspectRatio : 16 / 9;

    return Column(
      children: [
        AspectRatio(
          aspectRatio: aspect,
          child: Stack(
            children: [
              // 플레이어 or 썸네일
              Positioned.fill(
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(14),
                  child: showPlayer
                      ? VideoPlayer(playerController!)
                      : GestureDetector(
                          onTap: onPlayInline,
                          behavior: HitTestBehavior.opaque,
                          child: thumb == null
                              ? Container(
                                  decoration: BoxDecoration(
                                    color: cs.onSurface.withOpacity(0.03),
                                    border: Border.all(
                                        color: borderColor, width: 0.8),
                                  ),
                                  child: Center(
                                    child: Icon(Icons.video_file_rounded,
                                        size: 56,
                                        color: cs.onSurface.withOpacity(0.35)),
                                  ),
                                )
                              : Image.memory(thumb!, fit: BoxFit.cover),
                        ),
                ),
              ),

              // 하단 컨트롤 바 (항상 보이게)
              Positioned(
                left: 0,
                right: 0,
                bottom: 0,
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  decoration: BoxDecoration(
                    color: Colors.black.withOpacity(0.35),
                    borderRadius: const BorderRadius.vertical(
                        bottom: Radius.circular(14)),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      // ▶ / ||
                      IconButton(
                        iconSize: 28,
                        onPressed: () {
                          final pc = playerController;
                          if (pc == null || !pc.value.isInitialized) {
                            onPlayInline(); // 초기
                          } else {
                            onToggleInline(); // 토글
                          }
                        },
                        icon: Icon(() {
                          final pc = playerController;
                          if (pc == null || !(pc.value.isInitialized))
                            return Icons.play_arrow; // 초기
                          if (pc.value.isPlaying) return Icons.pause; // 재생중
                          if (pc.value.position >= pc.value.duration)
                            return Icons.play_arrow; // 끝남
                          return Icons.play_arrow; // 일시정지
                        }(), color: Colors.white),
                      ),
                      const SizedBox(width: 12),
                      // 되돌아가기(썸네일)
                      IconButton(
                        iconSize: 24,
                        onPressed: onStopInline,
                        icon: const Icon(Icons.replay, color: Colors.white),
                      ),
                    ],
                  ),
                ),
              ),

              // 확장자 배지
              Positioned(
                left: 10,
                bottom: 10,
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  decoration: BoxDecoration(
                    color: cs.surface,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: borderColor, width: 0.8),
                  ),
                  child: Text(ext,
                      style:
                          tt.bodySmall?.copyWith(fontWeight: FontWeight.w700)),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Icon(Icons.check_circle_rounded, color: cs.primary, size: 18),
            const SizedBox(width: 8),
            Expanded(
              child: Text(name,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: tt.bodyLarge?.copyWith(fontWeight: FontWeight.w800)),
            ),
            const SizedBox(width: 8),
            Text('$sizeKB KB', style: tt.bodySmall?.copyWith(color: subtle)),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            // ▼ 드롭다운 트리거를 OutlinedButton처럼 보이게
            Expanded(
              child: PopupMenuButton<String>(
                onSelected: (v) {
                  if (v == 'file') onReplace(); // 파일에서 다시 선택
                  if (v == 'photos') onPickFromPhotos(); // 사진에서 다시 선택
                },
                itemBuilder: (context) => const [
                  PopupMenuItem(
                    value: 'file',
                    child: ListTile(
                      leading: Icon(Icons.file_open_rounded),
                      title: Text('파일에서 선택'),
                    ),
                  ),
                  PopupMenuItem(
                    value: 'photos',
                    child: ListTile(
                      leading: Icon(Icons.photo_library_rounded),
                      title: Text('사진에서 선택'),
                    ),
                  ),
                ],
                child: SizedBox(
                  width: double.infinity,
                  child: OutlinedButton.icon(
                    icon: const Icon(Icons.swap_horiz_rounded, size: 18),
                    label: Text(
                      '다시 선택',
                      style:
                          tt.bodyMedium?.copyWith(fontWeight: FontWeight.w800),
                    ),
                    onPressed: null, // 클릭 이벤트는 PopupMenuButton이 처리
                  ),
                ),
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: TextButton.icon(
                icon: const Icon(Icons.delete_outline_rounded, size: 18),
                label:  Text(
                  '지우기',
                  style: tt.bodyMedium?.copyWith(fontWeight: FontWeight.w800,color: cs.primary),
                ),
                onPressed: onRemove,
              ),
            ),
          ],
        ),
      ],
    );
  }
}
