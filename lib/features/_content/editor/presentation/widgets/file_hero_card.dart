import 'package:flutter/material.dart';
import 'empty_state.dart';
import 'picked_state.dart';
import 'card_container.dart';
import 'dart:typed_data';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:video_player/video_player.dart';


class FileHeroCard extends StatelessWidget {
  const FileHeroCard({
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

  @override
  Widget build(BuildContext context) {
    final isEmpty = picked == null;

    return CardContainer(
      child: AnimatedSwitcher(
        duration: const Duration(milliseconds: 220),
        transitionBuilder: (child, anim) =>
            FadeTransition(opacity: anim, child: child),
        child: isEmpty
            ? EmptyState(
          key: const ValueKey('empty'),
          onPick: onPick,
          onAddToSandbox: onAddToSandbox,
          onPickFromPhotos: onPickFromPhotos,
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
        ),
      ),
    );
  }
}
