// ============================================================================
// lib/features/content-studio/captioning/presentation/sections/file_section.dart
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
import 'dart:typed_data';

import 'package:file_picker/file_picker.dart';
import 'package:ffmpeg_kit_flutter_new/ffmpeg_kit.dart';
import 'package:ffmpeg_kit_flutter_new/return_code.dart';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:video_player/video_player.dart';

import 'package:parrokit/core/shared/utils/app_logger.dart';
import 'package:parrokit/core/shared/utils/show_toast.dart';

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

  /// 마지막으로 파형을 추출한 파일 경로 (중복 추출 방지)
  String? _lastExtractedPath;

  /// 임시 PCM 파일 경로
  String? _tempPcmPath;

  @override
  void initState() {
    super.initState();
    widget.vm.addListener(_onVmChanged);
    // 이미 파일이 선택돼 있을 경우 즉시 추출
    final path = widget.vm.picked?.path;
    if (path != null) {
      WidgetsBinding.instance
          .addPostFrameCallback((_) => _extractWaveform(path));
    }
  }

  @override
  void didUpdateWidget(FileSection oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.vm != widget.vm) {
      oldWidget.vm.removeListener(_onVmChanged);
      widget.vm.addListener(_onVmChanged);
    }
  }

  @override
  void dispose() {
    widget.vm.removeListener(_onVmChanged);
    _vp?.dispose();
    _cleanupTempPcm();
    super.dispose();
  }

  void _onVmChanged() {
    final path = widget.vm.picked?.path;
    if (path == null) {
      if (_lastExtractedPath != null) {
        setState(() => _resetWaveform());
      }
      return;
    }
    if (path != _lastExtractedPath) {
      _extractWaveform(path);
    }
  }

  void _resetWaveform() {
    _waveformData = null;
    _waveformLoading = false;
    _lastExtractedPath = null;
  }

  Future<void> _cleanupTempPcm() async {
    final path = _tempPcmPath;
    if (path == null) return;
    try {
      final f = File(path);
      if (await f.exists()) await f.delete();
    } catch (e) {
      AppLogger.w('[Captioning][Waveform] 임시 PCM 파일 삭제 실패', error: e);
    }
    _tempPcmPath = null;
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
            setState(() => _resetWaveform());
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
    AppLogger.d('[Captioning][Player] 인라인 재생 시작 path=$path');
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
      AppLogger.i('[Captioning][Player] 인라인 재생 성공');
    } catch (e) {
      AppLogger.e('[Captioning][Player] 재생 초기화 실패', error: e);
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

  // ── 오디오 파형 추출 ──────────────────────────────────────────────────────

  /// 비디오 파일에서 오디오를 raw PCM으로 추출하고
  /// Dart에서 직접 파형 데이터를 계산한다.
  ///
  /// audio_waveforms 플랫폼 채널 없이 순수 Dart 연산으로 처리해
  /// iOS 시뮬레이터를 포함한 모든 환경에서 동작한다.
  Future<void> _extractWaveform(String videoPath) async {
    if (_lastExtractedPath == videoPath) return;
    if (!mounted) return;

    _lastExtractedPath = videoPath;
    setState(() {
      _waveformLoading = true;
      _waveformData = null;
    });

    AppLogger.i('[Captioning][Waveform] 파형 추출 시작 path=$videoPath');

    try {
      final tmpDir = await getTemporaryDirectory();
      final pcmOut = '${tmpDir.path}/aw_tmp_audio.pcm';

      await _cleanupTempPcm();
      _tempPcmPath = pcmOut;

      final outFile = File(pcmOut);
      if (await outFile.exists()) await outFile.delete();

      // ffmpeg: 비디오 → 원시 PCM (mono, 8 kHz, s16le)
      // 8 kHz × 2 bytes × 60 s ≈ 960 KB — 파형 계산에 충분한 해상도
      final session = await FFmpegKit.executeWithArguments([
        '-y',
        '-i', videoPath,
        '-vn',
        '-ac', '1',       // mono
        '-ar', '8000',    // 8 kHz
        '-f', 's16le',    // signed 16-bit little-endian
        '-t', '180',      // 최대 3분
        pcmOut,
      ]);
      final rc = await session.getReturnCode();

      if (!mounted) return;

      if (!ReturnCode.isSuccess(rc) || !await outFile.exists()) {
        final logs = await session.getAllLogsAsString();
        AppLogger.w(
          '[Captioning][Waveform] ffmpeg PCM 추출 실패 — 파형 미표시 logs=$logs',
        );
        if (mounted) setState(() => _waveformLoading = false);
        return;
      }

      AppLogger.d('[Captioning][Waveform] PCM 추출 성공 out=$pcmOut');

      // Dart에서 PCM 바이트 → 파형 계산
      final bytes = await outFile.readAsBytes();
      final data = _computeWaveformFromPcm(bytes, barCount: 200);

      AppLogger.i(
        '[Captioning][Waveform] 파형 계산 완료 samples=${data.length}',
      );

      if (mounted) {
        setState(() {
          _waveformData = data;
          _waveformLoading = false;
        });
      }
    } catch (e) {
      AppLogger.e('[Captioning][Waveform] 파형 추출 예외', error: e);
      if (mounted) setState(() => _waveformLoading = false);
    }
  }

  /// s16le PCM 바이트 배열에서 [barCount]개의 정규화 파형 값을 계산한다.
  ///
  /// 각 구간의 RMS(Root Mean Square)를 구해 0.0 ~ 1.0으로 정규화한다.
  static List<double> _computeWaveformFromPcm(
    Uint8List bytes, {
    int barCount = 200,
  }) {
    // s16le: 2바이트 = 1 샘플
    final sampleCount = bytes.length ~/ 2;
    if (sampleCount == 0) return [];

    final byteData = ByteData.sublistView(bytes);
    final segmentSize = (sampleCount / barCount).ceil();
    final result = <double>[];

    for (int i = 0; i < barCount; i++) {
      final start = i * segmentSize;
      if (start >= sampleCount) break;
      final end = (start + segmentSize).clamp(0, sampleCount);

      double sumSq = 0;
      for (int j = start; j < end; j++) {
        final sample = byteData.getInt16(j * 2, Endian.little).toDouble();
        sumSq += sample * sample;
      }
      final rms = (end > start) ? (sumSq / (end - start)) : 0.0;
      result.add(rms);
    }

    if (result.isEmpty) return [];

    // 0~1 정규화
    final maxVal = result.reduce((a, b) => a > b ? a : b);
    if (maxVal <= 0) return result.map((_) => 0.0).toList();
    return result.map((v) => (v / maxVal).clamp(0.0, 1.0)).toList();
  }
}
