import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart';
import 'package:video_player/video_player.dart';

import 'audio_waveform_bar.dart';
import 'video_controls_bar.dart';
import '../../../../../core/shared/utils/show_toast.dart';

class PickedState extends StatefulWidget {
  const PickedState({
    super.key,
    required this.picked,
    required this.onReplace,
    required this.onPickFromPhotos,
    required this.onRemove,
    this.thumb,
    required this.isPlayingInline,
    required this.playerController,
    required this.onPlayInline,
    required this.onToggleInline,
    required this.onStopInline,
    this.waveformData,
    this.waveformLoading = false,
  });

  final PlatformFile picked;
  final VoidCallback onReplace;
  final VoidCallback onPickFromPhotos;
  final VoidCallback onRemove;
  // 확장자·크기 정보: UI 미표시이나 필드는 유지
  final Uint8List? thumb;
  final bool isPlayingInline;
  final VideoPlayerController? playerController;
  final VoidCallback onPlayInline;
  final VoidCallback onToggleInline;
  final VoidCallback onStopInline;

  /// 실제 오디오 파형 데이터 (null이면 로딩 or 미추출)
  final List<double>? waveformData;
  final bool waveformLoading;

  @override
  State<PickedState> createState() => _PickedStateState();
}

class _PickedStateState extends State<PickedState> {
  // 줌 배율: 1.0(기본, 전체 표시) -> 배율이 커질수록 줌 인.
  double _zoomFactor = 1.0;

  void _zoomIn() {
    final c = widget.playerController;
    if (c == null || !c.value.isInitialized) return;

    final durMs = c.value.duration.inMilliseconds.toDouble();
    if (durMs <= 3000.0) {
      showToast('이 영상은 3초 미만이라 더 이상 확대할 수 없어요.');
      return;
    }

    final maxZoom = durMs / 3000.0;
    if (_zoomFactor >= maxZoom) {
      showToast('더 이상 확대할 수 없어요.');
      return;
    }

    setState(() {
      _zoomFactor = (_zoomFactor * 1.25).clamp(1.0, maxZoom);
    });
  }

  void _zoomOut() {
    if (_zoomFactor <= 1.0) {
      showToast('더 이상 축소할 수 없어요.');
      return;
    }
    setState(() {
      _zoomFactor = (_zoomFactor / 1.25).clamp(1.0, double.infinity);
    });
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;

    // ignore: unused_local_variable
    final ext = (widget.picked.extension ?? 'file').toLowerCase();
    // ignore: unused_local_variable
    final sizeMB = (widget.picked.size / (1024 * 1024));

    final bool showPlayer = widget.isPlayingInline &&
        widget.playerController != null &&
        widget.playerController!.value.isInitialized;
    final double aspect =
        showPlayer ? widget.playerController!.value.aspectRatio : 16 / 9;

    return Column(
      children: [
        // ── 1. 비디오 플레이어 ──────────────────────────────────────────────
        AspectRatio(
          aspectRatio: aspect,
          child: Stack(
            children: [
              Positioned.fill(
                child: ClipRRect(
                  borderRadius: BorderRadius.zero,
                  child: showPlayer
                      ? VideoPlayer(widget.playerController!)
                      : GestureDetector(
                          onTap: widget.onPlayInline,
                          behavior: HitTestBehavior.opaque,
                          child: widget.thumb == null
                              ? Container(
                                  color: cs.onSurface.withValues(alpha: 0.05),
                                  child: Center(
                                    child: Icon(
                                      Icons.video_file_rounded,
                                      size: 56,
                                      color:
                                          cs.onSurface.withValues(alpha: 0.35),
                                    ),
                                  ),
                                )
                              : Image.memory(widget.thumb!, fit: BoxFit.cover),
                        ),
                ),
              ),
            ],
          ),
        ),

        // ── 2. 음성 파형 그래프 ────────────────────────────────────────────
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
          child: AudioWaveformBar(
            videoController: widget.playerController,
            waveformData: widget.waveformData,
            isLoading: widget.waveformLoading,
            zoomFactor: _zoomFactor,
            height: 44,
          ),
        ),

        // ── 3. 컨트롤러 ───────────────────────────────────────────────────
        const SizedBox(height: 4),
        VideoControlsBar(
          controller: widget.playerController,
          onPlayInline: widget.onPlayInline,
          onToggleInline: widget.onToggleInline,
          onStopInline: widget.onStopInline,
          onZoomIn: _zoomIn,
          onZoomOut: _zoomOut,
        ),

        // ── 4. 파일 이름 + 다시 선택 / 지우기 ─────────────────────────────
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Column(
            children: [
              const SizedBox(height: 12),
              Row(
                children: [
                  Icon(Icons.check_circle_rounded,
                      color: cs.primary, size: 18),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      widget.picked.name,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style:
                          tt.bodyLarge?.copyWith(fontWeight: FontWeight.w800),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Expanded(
                    child: PopupMenuButton<String>(
                      onSelected: (v) {
                        if (v == 'file') widget.onReplace();
                        if (v == 'photos') widget.onPickFromPhotos();
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
                        child: TextButton.icon(
                          icon: Icon(Icons.swap_horiz_rounded,
                              size: 18, color: cs.onSurfaceVariant),
                          label: Text(
                            '다시 선택',
                            style: tt.bodyMedium?.copyWith(
                              fontWeight: FontWeight.w800,
                              color: cs.onSurfaceVariant,
                            ),
                          ),
                          onPressed: null,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: TextButton.icon(
                      icon: const Icon(Icons.delete_outline_rounded, size: 18),
                      label: Text(
                        '지우기',
                        style: tt.bodyMedium?.copyWith(
                          fontWeight: FontWeight.w800,
                          color: cs.primary,
                        ),
                      ),
                      onPressed: widget.onRemove,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }
}
