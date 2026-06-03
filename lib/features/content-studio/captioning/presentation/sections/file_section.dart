// ============================================================================
// lib/features/_content/editor/presentation/sections/file_section.dart
// ============================================================================
//
// [역할]
// 파일 선택 섹션 위젯.
// 영상 파일 선택, 제거, 인라인 재생, 오디오 파형 추출 UI.
//
// [레이어]
// Presentation Layer > Sections
// ============================================================================

import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:ffmpeg_kit_flutter_new/ffmpeg_kit.dart';
import 'package:ffmpeg_kit_flutter_new/return_code.dart';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:video_player/video_player.dart';

import 'package:parrokit/core/shared/utils/show_toast.dart';

import '../widgets/audio_waveform_bar.dart';
import '../widgets/file_hero_card.dart';
import '../captioning_view_model.dart';

/// 파일 선택 섹션.
class FileSection extends StatefulWidget {
  const FileSection({super.key, required this.vm});

  final CaptioningViewModel vm;

  @override
  State<FileSection> createState() => _FileSectionState();
}

class _FileSectionState extends State<FileSection> {
  VideoPlayerController? _vp;
  bool _vpReady = false;

  /// 오디오 파형 상태
  List<double>? _waveformData;
  bool _waveformLoading = false;

  @override
  void dispose() {
    _vp?.dispose();
    _cleanupTempAudio();
    super.dispose();
  }

  // ── 임시 오디오 파일 경로 ──────────────────────────────────────────────────
  String? _tempAudioPath;

  Future<void> _cleanupTempAudio() async {
    final path = _tempAudioPath;
    if (path != null) {
      try {
        final f = File(path);
        if (await f.exists()) await f.delete();
      } catch (_) {}
      _tempAudioPath = null;
    }
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
          waveformData: _waveformData,
          waveformLoading: _waveformLoading,
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

    // 파형 추출 (비디오가 처음 재생될 때 한 번만)
    if (_waveformData == null) {
      _extractWaveform(widget.vm.picked!.path!);
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

  // ── 오디오 파형 추출 ──────────────────────────────────────────────────────

  /// 비디오 파일에서 오디오를 추출한 뒤 파형 데이터를 로드한다.
  Future<void> _extractWaveform(String videoPath) async {
    if (!mounted) return;
    setState(() {
      _waveformLoading = true;
      _waveformData = null;
    });

    try {
      final tmpDir = await getTemporaryDirectory();
      final audioOut = '${tmpDir.path}/aw_tmp_audio.m4a';

      // 기존 임시 파일 제거
      await _cleanupTempAudio();
      _tempAudioPath = audioOut;
      final outFile = File(audioOut);
      if (await outFile.exists()) await outFile.delete();

      // ffmpeg: 비디오 → m4a (오디오만, 최대 3분)
      final session = await FFmpegKit.execute(
        '-y -i "$videoPath" -vn -acodec aac -b:a 64k -t 180 "$audioOut"',
      );
      final rc = await session.getReturnCode();

      if (!mounted) return;

      if (ReturnCode.isSuccess(rc) && await outFile.exists()) {
        final data = await extractWaveformData(audioOut, sampleCount: 200);
        if (mounted) {
          setState(() {
            _waveformData = data;
            _waveformLoading = false;
          });
        }
      } else {
        // ffmpeg 실패 → 더미 파형으로 폴백
        if (mounted) {
          setState(() {
            _waveformData = [];
            _waveformLoading = false;
          });
        }
      }
    } catch (_) {
      if (mounted) {
        setState(() {
          _waveformData = [];
          _waveformLoading = false;
        });
      }
    }
  }
}
