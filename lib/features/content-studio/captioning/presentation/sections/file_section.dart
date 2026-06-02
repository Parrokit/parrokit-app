// ============================================================================
// lib/features/_content/editor/presentation/sections/file_section.dart
// ============================================================================
//
// [역할]
// 파일 선택 섹션 위젯.
// 영상 파일 선택, 제거, 인라인 재생 UI.
//
// [레이어]
// Presentation Layer > Sections
// ============================================================================

import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';

import 'package:parrokit/core/shared/utils/show_toast.dart';

import '../widgets/file_hero_card.dart';
import '../clip_editor_view_model.dart';

/// 파일 선택 섹션.
class FileSection extends StatefulWidget {
  const FileSection({super.key, required this.vm});

  final ClipEditorViewModel vm;

  @override
  State<FileSection> createState() => _FileSectionState();
}

class _FileSectionState extends State<FileSection> {
  VideoPlayerController? _vp;
  bool _vpReady = false;

  @override
  void dispose() {
    _vp?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final vm = widget.vm;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        FileHeroCard(
          picked: vm.picked,
          onPick: vm.pickFromSandbox,
          onRemove: () {
            _stopInline();
            vm.removePicked();
          },
          onAddToSandbox: () async {
            final result = await FilePicker.platform.pickFiles(
              type: FileType.video,
              allowMultiple: false,
            );
            if (result != null && result.files.isNotEmpty) {
              vm.pickFromSandbox();
            }
          },
          onPickFromPhotos: vm.pickFromPhotos,
          thumb: vm.thumb,
          isPlayingInline: _vpReady,
          playerController: _vp,
          onPlayInline: _playInline,
          onToggleInline: _toggleInline,
          onStopInline: _stopInline,
          onReopenLast: () {},
          onReopenFile: vm.pickFromSandbox,
          onReopenPhotos: vm.pickFromPhotos,
          lastSourceLabel: '파일',
        ),
      ],
    );
  }

  Future<void> _playInline() async {
    final path = widget.vm.picked?.path;
    if (path == null) {
      showToast('재생할 파일 경로가 없습니다.');
      return;
    }
    try {
      await _vp?.dispose();
      final c = VideoPlayerController.file(File(path));
      await c.initialize();
      widget.vm.durationCtl.text = c.value.duration.inMilliseconds.toString();

      c.addListener(() {
        if (!mounted) return;
        final v = c.value;
        final done =
            v.isInitialized && !v.isPlaying && v.position >= v.duration;
        if (done) setState(() {});
      });

      setState(() {
        _vp = c;
        _vpReady = true;
      });
      await _vp!.play();
    } catch (e) {
      if (mounted) showToast('재생 초기화 실패: $e');
    }
  }

  void _toggleInline() {
    if (!_vpReady || _vp == null) return;
    setState(() {
      _vp!.value.isPlaying ? _vp!.pause() : _vp!.play();
    });
  }

  Future<void> _stopInline() async {
    await _vp?.dispose();
    setState(() {
      _vp = null;
      _vpReady = false;
    });
  }
}
