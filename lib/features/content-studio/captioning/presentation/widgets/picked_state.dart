import 'package:flutter/cupertino.dart';
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
    this.segmentsWidget,
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
  final Widget? segmentsWidget;

  @override
  State<PickedState> createState() => _PickedStateState();
}

class _PickedStateState extends State<PickedState> {
  // 줌 배율: 1.0(기본, 전체 표시) -> 배율이 커질수록 줌 인.
  double _zoomFactor = 1.0;
  bool _isSettingsExpanded = false;
  double _skipSeconds = 3.0;

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
          isSettingsExpanded: _isSettingsExpanded,
          skipSeconds: _skipSeconds,
          onToggleSettings: () {
            setState(() {
              _isSettingsExpanded = !_isSettingsExpanded;
            });
          },
        ),

        AnimatedSize(
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOutCubic,
          child: _isSettingsExpanded
              ? _VideoSettingsBar(
                  controller: widget.playerController,
                  picked: widget.picked,
                  onReplace: widget.onReplace,
                  onPickFromPhotos: widget.onPickFromPhotos,
                  onRemove: widget.onRemove,
                  segmentsWidget: widget.segmentsWidget,
                  skipSeconds: _skipSeconds,
                  onSkipSecondsChanged: (val) {
                    setState(() {
                      _skipSeconds = val;
                    });
                  },
                )
              : const SizedBox.shrink(),
        ),
      ],
    );
  }
}

class _VideoSettingsBar extends StatefulWidget {
  const _VideoSettingsBar({
    required this.controller,
    required this.picked,
    required this.onReplace,
    required this.onPickFromPhotos,
    required this.onRemove,
    this.segmentsWidget,
    required this.skipSeconds,
    this.onSkipSecondsChanged,
  });

  final VideoPlayerController? controller;
  final PlatformFile picked;
  final VoidCallback onReplace;
  final VoidCallback onPickFromPhotos;
  final VoidCallback onRemove;
  final Widget? segmentsWidget;
  final double skipSeconds;
  final ValueChanged<double>? onSkipSecondsChanged;

  @override
  State<_VideoSettingsBar> createState() => _VideoSettingsBarState();
}

class _VideoSettingsBarState extends State<_VideoSettingsBar> {
  final List<bool> _isExpanded = [false, false, false];

  @override
  void initState() {
    super.initState();
    widget.controller?.addListener(_onUpdate);
  }

  @override
  void didUpdateWidget(_VideoSettingsBar oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.controller != widget.controller) {
      oldWidget.controller?.removeListener(_onUpdate);
      widget.controller?.addListener(_onUpdate);
    }
  }

  @override
  void dispose() {
    widget.controller?.removeListener(_onUpdate);
    super.dispose();
  }

  void _onUpdate() {
    if (mounted) setState(() {});
  }

  void _showSkipPickerBottomSheet(BuildContext context) {
    // 0.5부터 10.0까지 0.5단위 (20개)
    final skips = List.generate(20, (index) => 0.5 + (index * 0.5));
    final currentSkip = widget.skipSeconds;

    int initialIndex = skips.indexWhere((s) => (s - currentSkip).abs() < 0.005);
    if (initialIndex == -1) initialIndex = 5; // 3.0s

    final scrollController =
        FixedExtentScrollController(initialItem: initialIndex);

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) {
        final cs = Theme.of(context).colorScheme;
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const SizedBox(height: 24),
              Text(
                '스킵 간격 (초)',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: cs.onSurface,
                ),
              ),
              const SizedBox(height: 16),
              SizedBox(
                height: 200,
                child: CupertinoPicker(
                  scrollController: scrollController,
                  itemExtent: 32.0,
                  magnification: 1.2,
                  squeeze: 1.1,
                  useMagnifier: true,
                  onSelectedItemChanged: (index) {
                    if (widget.onSkipSecondsChanged != null) {
                      widget.onSkipSecondsChanged!(skips[index]);
                    }
                  },
                  children: skips.map((skip) {
                    return Center(
                      child: Text(
                        '${skip.toStringAsFixed(skip == skip.truncateToDouble() ? 0 : 1)}초',
                        style: TextStyle(
                          fontSize: 18,
                          color: cs.onSurface,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    );
                  }).toList(),
                ),
              ),
              const SizedBox(height: 16),
            ],
          ),
        );
      },
    );
  }

  void _showSpeedPickerBottomSheet(BuildContext context) {
    final speeds = List.generate(171, (index) => 0.30 + (index * 0.01));
    final currentSpeed = widget.controller?.value.playbackSpeed ?? 1.0;

    int initialIndex =
        speeds.indexWhere((s) => (s - currentSpeed).abs() < 0.005);
    if (initialIndex == -1) initialIndex = 70; // 1.00

    final scrollController =
        FixedExtentScrollController(initialItem: initialIndex);

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) {
        final cs = Theme.of(context).colorScheme;
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const SizedBox(height: 24),
              Text(
                '재생 속도',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: cs.onSurface,
                ),
              ),
              const SizedBox(height: 16),
              SizedBox(
                height: 200,
                child: CupertinoPicker(
                  scrollController: scrollController,
                  itemExtent: 32.0,
                  magnification: 1.2,
                  squeeze: 1.1,
                  useMagnifier: true,
                  onSelectedItemChanged: (index) {
                    final speed = speeds[index];
                    widget.controller?.setPlaybackSpeed(speed);
                  },
                  children: speeds.map((speed) {
                    return Center(
                      child: Text(
                        '${speed.toStringAsFixed(2)}x',
                        style: TextStyle(
                          fontSize: 18,
                          color: cs.onSurface,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    );
                  }).toList(),
                ),
              ),
              const SizedBox(height: 16),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bgColor = isDark ? cs.surfaceContainerHigh : cs.surfaceContainerLow;

    final currentSpeed = widget.controller?.value.playbackSpeed ?? 1.0;
    final ext = (widget.picked.extension ?? 'file').toUpperCase();

    return Container(
      decoration: BoxDecoration(
        color: bgColor,
        border: Border(
          top: BorderSide(
            color: cs.outlineVariant.withValues(alpha: 0.3),
            width: 1,
          ),
        ),
      ),
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // 탭 버튼 영역
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _TabButton(
                icon: Icons.info_outline_rounded,
                label: '메타데이터',
                isActive: _isExpanded[0],
                onTap: () => setState(() => _isExpanded[0] = !_isExpanded[0]),
              ),
              const SizedBox(width: 8),
              _TabButton(
                icon: Icons.auto_awesome_rounded,
                label: '자동자막 & A-B',
                isActive: _isExpanded[1],
                onTap: () => setState(() => _isExpanded[1] = !_isExpanded[1]),
              ),
              const SizedBox(width: 8),
              _TabButton(
                icon: Icons.settings_rounded,
                label: '동영상 설정',
                isActive: _isExpanded[2],
                onTap: () => setState(() => _isExpanded[2] = !_isExpanded[2]),
              ),
            ],
          ),

          // 콘텐츠 영역 (열려있는 탭 내용 표시)
          AnimatedSize(
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeOutCubic,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                if (_isExpanded.any((e) => e)) ...[
                  const SizedBox(height: 8),
                  Divider(
                      height: 1, color: cs.onSurface.withValues(alpha: 0.1)),
                  const SizedBox(height: 16),
                ],
                if (_isExpanded[0]) ...[
                  // 1. 메타 데이터
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 8.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Row(
                          children: [
                            SizedBox(
                              width: 70,
                              child: Text('파일이름',
                                  style: TextStyle(
                                      fontSize: 12,
                                      fontWeight: FontWeight.w600,
                                      color: cs.onSurfaceVariant)),
                            ),
                            Expanded(
                              child: Text(
                                widget.picked.name,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w700,
                                    color: cs.onSurface),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            SizedBox(
                              width: 70,
                              child: Text('확장자',
                                  style: TextStyle(
                                      fontSize: 12,
                                      fontWeight: FontWeight.w600,
                                      color: cs.onSurfaceVariant)),
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 6, vertical: 2),
                              decoration: BoxDecoration(
                                color: cs.surfaceContainerHighest,
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: Text(
                                ext,
                                style: TextStyle(
                                  fontSize: 10,
                                  fontWeight: FontWeight.w800,
                                  color: cs.onSurfaceVariant,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                ],
                if (_isExpanded[1]) ...[
                  // 2. 자동자막 서비스 & A-B 리스트
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        '자동자막 서비스',
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w800,
                          color: cs.onSurfaceVariant,
                        ),
                      ),
                      FilledButton.tonalIcon(
                        onPressed: () {
                          // 기능 추가 예정
                        },
                        icon: const Icon(Icons.auto_awesome_rounded, size: 16),
                        label: const Text('자막 자동 생성'),
                        style: FilledButton.styleFrom(
                          minimumSize: const Size(0, 36),
                          padding: const EdgeInsets.symmetric(horizontal: 12),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  if (widget.segmentsWidget != null) ...[
                    widget.segmentsWidget!,
                    const SizedBox(height: 16),
                  ],
                ],
                if (_isExpanded[2]) ...[
                  // 3. 동영상 설정
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 8.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        InkWell(
                          onTap: () => _showSpeedPickerBottomSheet(context),
                          borderRadius: BorderRadius.circular(4),
                          child: Padding(
                            padding: const EdgeInsets.symmetric(vertical: 4),
                            child: Row(
                              children: [
                                SizedBox(
                                  width: 70,
                                  child: Text('배속',
                                      style: TextStyle(
                                          fontSize: 12,
                                          fontWeight: FontWeight.w600,
                                          color: cs.onSurfaceVariant)),
                                ),
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 6, vertical: 2),
                                  decoration: BoxDecoration(
                                    color: cs.surfaceContainerHighest,
                                    borderRadius: BorderRadius.circular(4),
                                  ),
                                  child: Text(
                                    '${currentSpeed.toStringAsFixed(2)}x',
                                    style: TextStyle(
                                        fontSize: 10,
                                        fontWeight: FontWeight.w800,
                                        color: cs.primary),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(height: 8),
                        InkWell(
                          onTap: () => _showSkipPickerBottomSheet(context),
                          borderRadius: BorderRadius.circular(4),
                          child: Padding(
                            padding: const EdgeInsets.symmetric(vertical: 4),
                            child: Row(
                              children: [
                                SizedBox(
                                  width: 70,
                                  child: Text('스킵 간격',
                                      style: TextStyle(
                                          fontSize: 12,
                                          fontWeight: FontWeight.w600,
                                          color: cs.onSurfaceVariant)),
                                ),
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 6, vertical: 2),
                                  decoration: BoxDecoration(
                                    color: cs.surfaceContainerHighest,
                                    borderRadius: BorderRadius.circular(4),
                                  ),
                                  child: Text(
                                    '${widget.skipSeconds.toStringAsFixed(widget.skipSeconds == widget.skipSeconds.truncateToDouble() ? 0 : 1)}초',
                                    style: TextStyle(
                                        fontSize: 10,
                                        fontWeight: FontWeight.w800,
                                        color: cs.primary),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(height: 16),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            PopupMenuButton<String>(
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
                              child: const _SettingAction(
                                icon: Icons.swap_horiz_rounded,
                                label: '다시 선택',
                              ),
                            ),
                            const SizedBox(width: 8),
                            _SettingAction(
                              icon: Icons.delete_outline_rounded,
                              label: '지우기',
                              onTap: widget.onRemove,
                              isDestructive: true,
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _TabButton extends StatelessWidget {
  const _TabButton({
    required this.icon,
    required this.label,
    required this.isActive,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final bool isActive;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final color = isActive ? cs.primary : cs.onSurfaceVariant;
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
        child: Column(
          children: [
            AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              curve: Curves.easeOutCubic,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
              decoration: BoxDecoration(
                color: isActive ? cs.primaryContainer : Colors.transparent,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Icon(icon, size: 24, color: isActive ? cs.onPrimaryContainer : cs.onSurfaceVariant),
            ),
            const SizedBox(height: 6),
            Text(
              label,
              style: TextStyle(
                fontSize: 11,
                fontWeight: isActive ? FontWeight.w800 : FontWeight.w600,
                color: color,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SettingAction extends StatelessWidget {
  const _SettingAction({
    required this.icon,
    required this.label,
    this.onTap,
    this.isDestructive = false,
  });

  final IconData icon;
  final String label;
  final VoidCallback? onTap;
  final bool isDestructive;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final color = isDestructive ? cs.error : cs.onSurfaceVariant;
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(10),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        decoration: BoxDecoration(
          color: isDestructive
              ? cs.errorContainer.withValues(alpha: 0.3)
              : cs.surfaceContainerHighest.withValues(alpha: 0.5),
          borderRadius: BorderRadius.circular(10),
          border: isDestructive ? Border.all(color: cs.error.withValues(alpha: 0.2)) : null,
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 16, color: color),
            const SizedBox(width: 6),
            Text(
              label,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w700,
                color: color,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
