import 'package:flutter/material.dart';
import 'empty_state.dart';
import 'audio_waveform_bar.dart';
import 'picked_state.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart';
import 'package:video_player/video_player.dart';

import '../../domain/editor_state.dart';

class FileHeroCard extends StatelessWidget {
  const FileHeroCard({
    super.key,
    required this.picked,
    required this.onPick,
    required this.onRemove,
    required this.onAddToSandbox,
    required this.onPickFromPhotos,
    this.thumb,
    required this.isPlayingInline,
    required this.playerController,
    required this.onPlayInline,
    required this.onToggleInline,
    required this.onStopInline,
    required this.onReopenLast,
    required this.onReopenFile,
    required this.onReopenPhotos,
    required this.lastSourceLabel,
    this.waveformData,
    this.waveformLoading = false,
    this.isVideoLoading = false,
    this.segmentsWidget,
    this.segmentForms = const [],
    this.onOverlayRangeChanged,
    this.onOverlayStartAdjusted,
    this.onOverlayEndAdjusted,
  });

  final PlatformFile? picked;
  final VoidCallback onPick;
  final VoidCallback onRemove;
  final VoidCallback onAddToSandbox;
  final VoidCallback onPickFromPhotos;
  final bool isPlayingInline;
  final VideoPlayerController? playerController;
  final VoidCallback onPlayInline;
  final VoidCallback onToggleInline;
  final VoidCallback onStopInline;
  final Uint8List? thumb;

  final VoidCallback onReopenLast;
  final VoidCallback onReopenFile;
  final VoidCallback onReopenPhotos;
  final String lastSourceLabel;

  final List<double>? waveformData;
  final bool waveformLoading;
  final bool isVideoLoading;
  final Widget? segmentsWidget;
  final List<SegmentFormData> segmentForms;
  final ValueChanged<WaveformOverlayRange>? onOverlayRangeChanged;
  final void Function(int index, int deltaMs)? onOverlayStartAdjusted;
  final void Function(int index, int deltaMs)? onOverlayEndAdjusted;

  @override
  Widget build(BuildContext context) {
    final bool showLoading = isVideoLoading || waveformLoading;
    final bool showEmpty = picked == null || showLoading;

    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 220),
      transitionBuilder: (child, anim) =>
          FadeTransition(opacity: anim, child: child),
      child: showEmpty
          ? EmptyState(
              key: const ValueKey('empty'),
              onPick: onPick,
              onPickFromPhotos: onPickFromPhotos,
              isLoading: showLoading,
            )
          : PickedState(
              key: const ValueKey('picked'),
              picked: picked!,
              onReplace: onPick,
              onPickFromPhotos: onPickFromPhotos,
              onRemove: onRemove,
              thumb: thumb,
              isPlayingInline: isPlayingInline,
              playerController: playerController,
              onPlayInline: onPlayInline,
              onToggleInline: onToggleInline,
              onStopInline: onStopInline,
              waveformData: waveformData,
              waveformLoading: waveformLoading,
              segmentsWidget: segmentsWidget,
              segmentForms: segmentForms,
              onOverlayRangeChanged: onOverlayRangeChanged,
              onOverlayStartAdjusted: onOverlayStartAdjusted,
              onOverlayEndAdjusted: onOverlayEndAdjusted,
            ),
    );
  }
}
