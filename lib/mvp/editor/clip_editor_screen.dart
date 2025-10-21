// lib/mvp/editor/clip_editor_screen.dart
import 'dart:io';
import 'dart:typed_data';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import 'package:parrokit/data/models/clip_view.dart';
import 'package:parrokit/utils/pa_logger.dart';
import 'package:parrokit/utils/show_toast.dart';
import 'package:path_provider/path_provider.dart';
import 'package:provider/provider.dart';
import 'package:video_player/video_player.dart';
import 'package:video_thumbnail/video_thumbnail.dart';
import '../../provider/media_provider.dart';
import 'widgets/file_hero_card.dart';
import 'widgets/hairline_divider.dart';
import 'widgets/input_card.dart';
import 'widgets/labeled_text_field.dart';
import 'widgets/section_title.dart';
import 'widgets/segment_card.dart';
import 'package:uuid/uuid.dart';
import 'package:parrokit/data/local/pa_database.dart' as db;

enum _PickSource { file, photos }

final _uuid = const Uuid();

class _SegmentForm {
  final TextEditingController startCtl = TextEditingController();
  final TextEditingController endCtl = TextEditingController();
  final TextEditingController originalCtl = TextEditingController();
  final TextEditingController pronCtl = TextEditingController();
  final TextEditingController koCtl = TextEditingController();

  void dispose() {
    startCtl.dispose();
    endCtl.dispose();
    originalCtl.dispose();
    pronCtl.dispose();
    koCtl.dispose();
  }
}

class ClipEditorScreen extends StatefulWidget {
  const ClipEditorScreen({super.key, this.clipId});

  final int? clipId;

  @override
  State<ClipEditorScreen> createState() => _ClipEditorScreenState();
}

class _ClipEditorScreenState extends State<ClipEditorScreen> {
  PlatformFile? _picked; // 선택된 비디오 파일(경로)
  _PickSource _lastPickSource = _PickSource.file;
  final _picker = ImagePicker();
  Uint8List? _thumb; // 썸네일
  VideoPlayerController? _vp;
  bool _vpReady = false;
  bool _saving = false;
  bool _isEdit = false;
  bool _fileChanged = false;
  String? _existingRelPath;
  int? _existingDurationMS;
  final RegExp _mmssmmm = RegExp(r'^\d{2}:\d{2}\.\d{3}$');

  // --- 메타/폼 컨트롤러 ---
  final _titleCtl = TextEditingController(); // 클립 제목
  final _nameCtl = TextEditingController(); // 작품명
  final _nameNativeCtl = TextEditingController(); // 작품명
  final _episodeCtl = TextEditingController(); // 몇화(시즌일 때)
  final _durationCtl = TextEditingController(); // 수동 길이 입력(옵션)

  // 타입/시즌/연도/에피소드 제목/태그
  String _type = 'season'; // 'season' | 'movie'
  final _seasonCtl = TextEditingController();
  final _epiTitleCtl = TextEditingController(); // ✅ 필수
  final _tagsCtl = TextEditingController();
  final List<String> _tags = [];

  final List<_SegmentForm> _segForms = [_SegmentForm()];

  late final String _stagingDirName = 'video_staging';

  @override
  void initState() {
    super.initState();
    if (widget.clipId != null) {
      _isEdit = true;
      _loadForEdit(widget.clipId!);
    }
  }

  @override
  void dispose() {
    _titleCtl.dispose();
    _nameCtl.dispose();
    _nameNativeCtl.dispose();
    _episodeCtl.dispose();
    _durationCtl.dispose();

    _seasonCtl.dispose();
    _epiTitleCtl.dispose();
    _tagsCtl.dispose();

    for (final f in _segForms) {
      f.dispose();
    }
    _vp?.dispose();
    if (_picked?.path != null && _isInStaging(_picked!.path!)) {
      discardStaged(_picked!.path!);
    }
    super.dispose();
  }

  Future<void> _loadForEdit(int clipId) async {
    final mp = context.read<MediaProvider>();

    // 1) clip 찾기
    db.Clip? clip;
    try {
      clip = mp.clips.firstWhere((c) => c.id == clipId);
    } catch (_) {
      showToast(context, '편집할 클립을 찾을 수 없습니다.');
      if (mounted) Navigator.of(context).maybePop();
      return;
    }

    // 2) 상위 엔티티 추적
    db.Episode? ep;
    if (clip.episodeId != null) {
      try {
        ep = mp.episodes.firstWhere((e) => e.id == clip!.episodeId);
      } catch (_) {}
    }

    db.Release? rel;
    if (ep?.releaseId != null) {
      try {
        rel = mp.releases.firstWhere((r) => r.id == ep!.releaseId);
      } catch (_) {}
    }

    db.Title? title;
    if (rel?.titleId != null) {
      try {
        title = mp.titles.firstWhere((t) => t.id == rel!.titleId);
      } catch (_) {}
    }

    // 3) 메타/태그 프리필 (동기 setState)
    setState(() {
      _nameCtl.text = title?.name ?? '';
      _nameNativeCtl.text = title?.nameNative ?? '';
      _type = rel?.type ?? 'season';
      _seasonCtl.text = rel?.number?.toString() ?? '';
      _episodeCtl.text = ep?.number?.toString() ?? '';
      _epiTitleCtl.text = ep?.title ?? '';
      _titleCtl.text = clip?.title ?? '';
      _existingRelPath = clip?.filePath;
      _existingDurationMS = clip?.durationMs;

      _tags
        ..clear()
        ..addAll(
            (mp.tagsByClip[clipId] ?? const <db.Tag>[]).map((t) => t.name));
    });

    // 4) 세그먼트 로드 (await는 setState 밖)
    final cv = await mp.fetchClipById(clipId);
    if (cv == null) {
      showToast(context, '편집할 클립을 찾을 수 없습니다.');
      if (mounted) Navigator.of(context).maybePop();
      return;
    }

    _segForms.clear();
    for (final s in cv.segments) {
      final f = _SegmentForm();
      f.startCtl.text = _msToMMSSmmm(s.startMs);
      f.endCtl.text = _msToMMSSmmm(s.endMs);
      f.originalCtl.text = s.original;
      f.pronCtl.text = s.pron;
      f.koCtl.text = s.trans;
      _segForms.add(f);
    }
    if (_segForms.isEmpty) {
      _segForms.add(_SegmentForm());
    }
    if (mounted) setState(() {}); // 세그먼트 UI 갱신

    // 5) 파일 경로 → 절대경로 변환 + 썸네일/길이
    if (_existingRelPath != null && _existingRelPath!.isNotEmpty) {
      final abs = await _absoluteFromRelative(_existingRelPath!);
      final file = File(abs);
      final size = await file.exists() ? await file.length() : 0;

      if (mounted) {
        setState(() {
          _picked =
              PlatformFile(name: abs.split('/').last, size: size, path: abs);
          _lastPickSource = _PickSource.file;
          _isEdit = true;
          _fileChanged = false;
        });
      }

      try {
        final bytes = await VideoThumbnail.thumbnailData(
          video: abs,
          imageFormat: ImageFormat.PNG,
          maxWidth: 256,
          quality: 75,
          timeMs: 0,
        );
        if (mounted) setState(() => _thumb = bytes);

        if (_existingDurationMS == null || _existingDurationMS == 0) {
          final temp = VideoPlayerController.file(file);
          await temp.initialize();
          _existingDurationMS = temp.value.duration.inMilliseconds;
          if (mounted)
            setState(() {
              _durationCtl.text = _existingDurationMS!.toString();
            });
          await temp.dispose();
        } else {
          if (mounted)
            setState(() {
              _durationCtl.text = _existingDurationMS!.toString();
            });
        }
      } catch (_) {
        // 썸네일/길이 실패는 무시 가능
      }
    } else {
      if (mounted) {
        setState(() {
          _isEdit = true;
          _fileChanged = false;
        });
      }
    }
  }

  String _msToMMSSmmm(int ms) {
    final m = ms ~/ 60000;
    final s = (ms % 60000) ~/ 1000;
    final u = ms % 1000;
    return '${m.toString().padLeft(2, '0')}:${s.toString().padLeft(2, '0')}.${u.toString().padLeft(3, '0')}';
  }

  Future<String> _absoluteFromRelative(String rel) async {
    final base = await getApplicationDocumentsDirectory();
    return '${base.path}/$rel';
  }

  Future<Directory> _ensureStagingDir() async {
    final base = await getTemporaryDirectory(); // 앱 캐시 영역
    final dir = Directory('${base.path}/video_staging');
    if (!await dir.exists()) await dir.create(recursive: true);
    return dir;
  }

  Future<Directory> _ensureFinalDir() async {
    final base = await getApplicationDocumentsDirectory(); // 영구 보관
    final dir = Directory('${base.path}/videos');
    if (!await dir.exists()) await dir.create(recursive: true);
    return dir;
  }

  Future<String> stageVideoFromPath(String srcPath,
      {String? suggestedName}) async {
    final dir = await _ensureStagingDir();
    final ext = _guessExt(srcPath, suggestedName);
    final name = '${DateTime.now().millisecondsSinceEpoch}_${_uuid.v4()}$ext';
    final dest = File('${dir.path}/$name');
    await _copyByStream(File(srcPath).openRead(), dest);
    return dest.path; // ← 스테이징 경로 반환
  }

  Future<void> discardStaged(String stagedPath) async {
    try {
      await File(stagedPath).delete();
    } catch (_) {}
  }

  Future<String> finalizeStaged(String stagedPath) async {
    final finalDir = await _ensureFinalDir();
    final ext = _extensionOf(stagedPath);
    final name = '${DateTime.now().millisecondsSinceEpoch}_${_uuid.v4()}$ext';
    final dest = File('${finalDir.path}/$name');

    // 1) copy 먼저
    await _copyByStream(File(stagedPath).openRead(), dest);

    // 2) 성공했으면 staging 삭제(스테이징 안일 때만)
    if (await dest.exists() && (await dest.length()) > 0) {
      try {
        await File(stagedPath).delete();
      } catch (_) {}
      // ✅ DB에는 상대경로만 반환
      return 'videos/$name';
    } else {
      throw Exception('Final copy failed');
    }
  }

  String _guessExt(String path, String? suggested) {
    String pick(String s) =>
        s.contains('.') ? s.substring(s.lastIndexOf('.')) : '';
    final fromSug = suggested != null ? pick(suggested) : '';
    final fromPath = pick(path);
    return (fromSug.isNotEmpty
        ? fromSug
        : fromPath.isNotEmpty
            ? fromPath
            : '.mp4');
  }

  String _extensionOf(String path) =>
      path.contains('.') ? path.substring(path.lastIndexOf('.')) : '.mp4';

  Future<void> _copyByStream(Stream<List<int>> input, File dest) async {
    final sink = dest.openWrite();
    try {
      await input.pipe(sink);
    } finally {
      await sink.close();
    }
  }

  Future<void> sweepOldStaging(
      {Duration ttl = const Duration(hours: 48)}) async {
    final dir = await _ensureStagingDir();
    if (!await dir.exists()) return;
    final now = DateTime.now();
    await for (final e in dir.list()) {
      if (e is File) {
        final stat = await e.stat();
        if (now.difference(stat.modified) > ttl) {
          try {
            await e.delete();
          } catch (_) {}
        }
      }
    }
  }

  Future<void> _playInline() async {
    final path = _picked?.path;
    if (path == null) {
      showToast(context, '재생할 파일 경로가 없습니다.');
      return;
    }
    try {
      await _vp?.dispose();
      final c = VideoPlayerController.file(File(path));
      await c.initialize();

      // ✅ duration 자동 입력
      final dur = c.value.duration.inMilliseconds;
      _durationCtl.text = dur.toString();

      // 끝까지 재생했는지 감지 → 아이콘 갱신
      c.addListener(() {
        if (!mounted) return;
        final v = c.value;
        final done =
            v.isInitialized && !v.isPlaying && v.position >= v.duration;
        if (done) setState(() {}); // 버튼 아이콘이 ▶로 돌아오게 리빌드
      });

      setState(() {
        _vp = c;
        _vpReady = true;
      });
      await _vp!.play();
    } catch (e) {
      showToast(context, '재생 초기화 실패: $e');
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

  Future<void> _pickFromSandbox() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['mp4', 'mov', 'mkv'],
      allowMultiple: false,
    );
    if (result == null || result.files.isEmpty) return;

    final f = result.files.first;
    final saved =
        await stageVideoFromPath(f.path!, suggestedName: f.name); // ★ 스테이징
    final size = await File(saved).length();

    await _setPickedFromPath(path: saved, name: f.name, size: size);
    setState(() {
      _lastPickSource = _PickSource.file;
      _fileChanged = true; // ★
    });
  }

  Future<void> _pickFromPhotos() async {
    final x = await _picker.pickVideo(source: ImageSource.gallery);
    if (x == null) return;
    final staged = await stageVideoFromPath(x.path, suggestedName: x.name); // ★
    final size = await File(staged).length();

    await _setPickedFromPath(path: staged, name: x.name, size: size);
    setState(() {
      _lastPickSource = _PickSource.photos;
      _fileChanged = true;
    });
  }

  Future<void> _reopenLastPicker() async {
    if (_lastPickSource == _PickSource.file) {
      await _pickFromSandbox();
    } else {
      await _pickFromPhotos();
    }
  }

  Future<void> _setPickedFromPath({
    required String path,
    required String name,
    required int size,
  }) async {
    try {
      setState(() {
        _picked = PlatformFile(name: name, size: size, path: path);
        _thumb = null;
      });

      // ✅ 썸네일
      final bytes = await VideoThumbnail.thumbnailData(
        video: path,
        imageFormat: ImageFormat.PNG,
        maxWidth: 256,
        quality: 75,
        timeMs: 0,
      );
      if (!mounted) return;
      setState(() => _thumb = bytes);

      // ✅ duration 자동 입력
      final temp = VideoPlayerController.file(File(path));
      await temp.initialize();
      _durationCtl.text = temp.value.duration.inMilliseconds.toString();
      await temp.dispose();
    } catch (e) {
      showToast(context, '썸네일/길이 추출 실패: $e');
    }
  }

  Future<void> _addToSandbox() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.video,
      allowMultiple: false,
    );
    if (result != null && result.files.isNotEmpty) {
      final f = result.files.first;
      if (f.path == null) return showToast(context, '경로를 찾을 수 없습니다.');
      await _setPickedFromPath(path: f.path!, name: f.name, size: f.size);
      showToast(context, '샌드박스에 추가했다고 가정 (데모)');
    }
  }

  void _removePicked() async {
    final p = _picked?.path;
    setState(() {
      _picked = null;
      _thumb = null;
      _vp?.dispose();
      _vp = null;
      _vpReady = false;
    });
    if (p != null && _isInStaging(p)) {
      await discardStaged(p);
    }
  }

  bool _isInStaging(String path) => path.contains('/$_stagingDirName/');

  void _onAddSeg() {
    setState(() {
      final nf = _SegmentForm();
      // UX: 직전 세그 끝을 새 세그 시작으로 미리 채움
      if (_segForms.isNotEmpty) {
        final last = _segForms.last;
        nf.startCtl.text = last.endCtl.text;
      }
      _segForms.add(nf);
    });
  }

  void _onRemoveSeg(int idx) {
    if (_segForms.length == 1) {
      showToast(context, '세그먼트는 최소 1개 이상 필요합니다.');
      return;
    }
    setState(() {
      final f = _segForms.removeAt(idx);
      f.dispose();
    });
  }

  int _parseNormalizedToMs(String normalized) {
    final m = RegExp(r'^(\d{2}):(\d{2})\.(\d{3})$').firstMatch(normalized)!;
    final mm = int.parse(m.group(1)!);
    final ss = int.parse(m.group(2)!);
    final ms = int.parse(m.group(3)!);
    return mm * 60000 + ss * 1000 + ms;
  }

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context);
    final tt = t.textTheme;
    final cs = t.colorScheme;

    return Scaffold(
      backgroundColor: t.colorScheme.surface,
      appBar: AppBar(
        title: const Text('편집'),
        centerTitle: true,
        elevation: 0,
      ),
      body: SafeArea(
        child: Stack(
          children: [
            ListView(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 28),
              children: [
                // --- 1) 파일 섹션 ---
                const SectionTitle('영상 파일'),
                const SizedBox(height: 10),
                FileHeroCard(
                  picked: _picked,
                  onPick: _pickFromSandbox,
                  onRemove: _removePicked,
                  onAddToSandbox: _addToSandbox,
                  onPickFromPhotos: _pickFromPhotos,
                  thumb: _thumb,
                  isPlayingInline: _vpReady,
                  playerController: _vp,
                  onPlayInline: _playInline,
                  onToggleInline: _toggleInline,
                  onStopInline: _stopInline,
                  onReopenLast: _reopenLastPicker,
                  onReopenFile: _pickFromSandbox,
                  onReopenPhotos: _pickFromPhotos,
                  lastSourceLabel:
                      _lastPickSource == _PickSource.file ? '파일' : '사진',
                ),

                const SizedBox(height: 24),
                const HairlineDivider(),
                const SizedBox(height: 16),

                // --- 2) 메타 섹션 ---
                const SectionTitle('영상 정보'),
                const SizedBox(height: 10),
                InputCard(children: [
                  LabeledTextField(
                    label: '클립 제목',
                    hint: '클립 제목을 입력하세요.',
                    controller: _titleCtl,
                    helper: '어떤 장면인지 바로 알아볼 수 있게 간결하게 적어주세요.',
                    prefixIcon: Icons.title,
                    clearable: true,
                  ),
                  const SizedBox(height: 10),
                  LabeledTextField(
                    label: '작품명',
                    hint: '작품의 이름을 입력하세요.',
                    controller: _nameCtl,
                    prefixIcon: Icons.movie_outlined,
                    clearable: true,
                  ),
                  LabeledTextField(
                    label: '원어 작품명',
                    hint: '작품의 본토 이름을 입력하세요.',
                    controller: _nameNativeCtl,
                    prefixIcon: Icons.movie_outlined,
                    clearable: true,
                  ),
                  const SizedBox(height: 10),

                  // 타입 선택
                  Row(
                    children: [
                      Expanded(
                        child: SegmentedButton<String>(
                          segments: [
                            ButtonSegment(
                              value: 'season',
                              label: Text(
                                '시즌',
                                style: tt.bodyMedium?.copyWith(
                                  fontWeight: FontWeight.w800,
                                ),
                              ),
                            ),
                            ButtonSegment(
                              value: 'movie',
                              label: Text(
                                '영화',
                                style: tt.bodyMedium?.copyWith(
                                  fontWeight: FontWeight.w800,
                                ),
                              ),
                            ),
                          ],
                          selected: {_type},
                          onSelectionChanged: (s) {
                            setState(() {
                              _type = s.first;
                            });
                          },
                          showSelectedIcon: false,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),

                  // 시즌 번호(선택)
                  if (_type == 'season')
                    LabeledTextField(
                      label: '시즌',
                      hint: '몇 번째 시즌인지 숫자로 입력하세요.',
                      controller: _seasonCtl,
                      keyboardType: TextInputType.number,
                      prefixIcon: Icons.layers_outlined,
                      clearable: true,
                      inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                    ),
                  const SizedBox(height: 10),
                  // 에피소드 번호(선택, 시즌일 때만)
                  if (_type == 'season')
                    LabeledTextField(
                      label: '화',
                      hint: '몇 번째 회차인지 숫자로 입력하세요.',
                      controller: _episodeCtl,
                      keyboardType: TextInputType.number,
                      prefixIcon: Icons.confirmation_number_outlined,
                      clearable: true,
                    ),
                  const SizedBox(height: 10),
                  // 에피소드/부제 제목(필수)
                  LabeledTextField(
                    label: _type == 'movie' ? '영화 제목' : '회차 제목',
                    hint:
                        _type == 'movie' ? '회차의 제목을 입력하세요.' : '영화의 제목을 입력하세요.',
                    helper: _type == 'movie'
                        ? '시리즈가 없는 단독 영화의 경우,\n작품명과 동일하거나 편한대로 작성해주세요.'
                        : '수정한 경우, 기존 값은 새 내용으로 갱신됩니다.',
                    controller: _epiTitleCtl,
                    prefixIcon: Icons.title_outlined,
                    clearable: true,
                  ),
                  const SizedBox(height: 10),

                  // 태그
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      LabeledTextField(
                        label: '태그(선택)',
                        hint: '기억하기 쉽고 다시 찾기 편한 태그를 입력하세요.',
                        controller: _tagsCtl,
                        helper: '“태그 추가” 버튼을 누르면 태그가 생성됩니다.',
                        prefixIcon: Icons.tag_outlined,
                        clearable: true,
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          FilledButton.icon(
                            icon: const Icon(Icons.add_rounded, size: 18),
                            label: const Text('태그 추가'),
                            onPressed: () {
                              final t = _tagsCtl.text.trim();
                              if (t.isEmpty) return;
                              setState(() {
                                if (!_tags.contains(t)) _tags.add(t);
                                _tagsCtl.clear();
                              });
                            },
                          ),
                          const SizedBox(width: 8),
                          FilledButton(
                            style: FilledButton.styleFrom(
                              backgroundColor: t.colorScheme.onPrimary,
                              foregroundColor: t.colorScheme.primary,
                            ),
                            child: const Text('모두 지우기'),
                            onPressed: () => setState(_tags.clear),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Wrap(
                        spacing: 6,
                        runSpacing: -8,
                        children: _tags
                            .map((t) => Chip(
                                  label: Text(t,
                                      style: tt.bodyMedium
                                          ?.copyWith(color: cs.onPrimary)),
                                  backgroundColor: cs.primary,
                                  deleteIcon: const Icon(Icons.close_rounded,
                                      size: 18, color: Colors.white70),
                                  shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(20)),
                                  onDeleted: () =>
                                      setState(() => _tags.remove(t)),
                                ))
                            .toList(),
                      ),
                    ],
                  ),
                ]),

                const SizedBox(height: 20),
                const HairlineDivider(),
                const SizedBox(height: 12),

                // --- 3) 세그먼트 섹션 ---
                Row(
                  children: [
                    const SectionTitle('구간 정보'),
                    const Spacer(),
                    OutlinedButton.icon(
                      icon: const Icon(Icons.add_rounded, size: 18),
                      label: const Text('구간 추가'),
                      onPressed: _onAddSeg, // ✅ 아래 함수
                    ),
                  ],
                ),
                const SizedBox(height: 8),

                // ✅ 동적 리스트
                for (int i = 0; i < _segForms.length; i++) ...[
                  SegmentCard(
                    index: i + 1,
                    startCtl: _segForms[i].startCtl,
                    endCtl: _segForms[i].endCtl,
                    originalCtl: _segForms[i].originalCtl,
                    pronCtl: _segForms[i].pronCtl,
                    koCtl: _segForms[i].koCtl,
                  ),
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      const SizedBox(width: 8),
                      OutlinedButton.icon(
                        icon: const Icon(Icons.delete_outline, size: 18),
                        label: const Text('구간 삭제'),
                        onPressed: () => _onRemoveSeg(i), // ✅ 아래 함수
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                ],

                // --- 하단 액션 ---
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        child: const Text('취소'),
                        onPressed: () => Navigator.of(context).maybePop(),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: ElevatedButton(
                        child: const Text('저장'),
                        onPressed: _onSavePressed,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 200),
              ],
            ),
            if (_saving)
              Positioned.fill(
                child: Container(
                  color: Colors.black.withOpacity(0.25),
                  child: const Center(
                    child: CircularProgressIndicator(),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Future<void> _onSavePressed() async {
    // ----- 0) 파일 필수 -----
    final stagedPath = _picked?.path;
    if (stagedPath == null || stagedPath.isEmpty) {
      return showToast(context, '영상 파일을 먼저 선택해 주세요.');
    }

    // ----- 1) 메타 필수: 제목/작품명/유형/연도/회차제목 -----
    final name = _nameCtl.text.trim();
    final nameNative = _nameNativeCtl.text.trim();
    final clipTitle = _titleCtl.text.trim();
    final epiTitle = _epiTitleCtl.text.trim();
    if (clipTitle.isEmpty) return showToast(context, '클립 제목은 필수입니다.');
    if (name.isEmpty) return showToast(context, '작품명은 필수입니다.');
    if (nameNative.isEmpty) return showToast(context, '원어 작품명은 필수입니다.');
    if (epiTitle.isEmpty) {
      return showToast(
          context, _type == 'movie' ? '영화 제목은 필수입니다.' : '회차 제목은 필수입니다.');
    }

    // 시즌 타입일 경우: 시즌/화 숫자 필수
    int? seasonNum, epiNumber;
    if (_type == 'season') {
      final sText = _seasonCtl.text.trim();
      final eText = _episodeCtl.text.trim();
      seasonNum = int.tryParse(sText);
      epiNumber = int.tryParse(eText);
      if (seasonNum == null) return showToast(context, '시즌 번호는 숫자로 필수입니다.');
      if (epiNumber == null) return showToast(context, '화 번호는 숫자로 필수입니다.');
      if (seasonNum <= 0) return showToast(context, '시즌 번호는 1 이상이어야 합니다.');
      if (epiNumber <= 0) return showToast(context, '화 번호는 1 이상이어야 합니다.');
    } else {
      seasonNum = null;
      epiNumber = null;
    }

    // ----- 2) duration 필수: 플레이어값 → 입력값 -----
    int? durationMs;
    if (_vpReady && _vp != null) {
      durationMs = _vp!.value.duration.inMilliseconds;
    } else {
      durationMs = int.tryParse(_durationCtl.text.trim());
    }
    if (durationMs == null || durationMs <= 0) {
      return showToast(
          context, '영상 길이(duration)는 필수입니다. 재생 후 자동입력 또는 수동 입력하세요.');
    }

    // ----- 3) 세그먼트 필수 + 모든 필드 필수 + 형식/범위/겹침 검증 -----
    final seg = <db.Segment>[];
    for (int i = 0; i < _segForms.length; i++) {
      final f = _segForms[i];
      final sText = f.startCtl.text.trim();
      final eText = f.endCtl.text.trim();
      final ja = f.originalCtl.text.trim();
      final pr = f.pronCtl.text.trim();
      final ko = f.koCtl.text.trim();

      // 완전 빈 행 허용 안 함(전부 필수이므로)
      if (sText.isEmpty ||
          eText.isEmpty ||
          ja.isEmpty ||
          pr.isEmpty ||
          ko.isEmpty) {
        return showToast(context, '세그먼트 ${i + 1}: 시작/끝/원문/발음/번역은 모두 필수입니다.');
      }

      if (!_mmssmmm.hasMatch(sText)) {
        return showToast(
            context, '세그먼트 ${i + 1}: 시작 시각 형식이 올바르지 않습니다. 예) 00:04.230');
      }
      if (!_mmssmmm.hasMatch(eText)) {
        return showToast(
            context, '세그먼트 ${i + 1}: 종료 시각 형식이 올바르지 않습니다. 예) 00:05.000');
      }

      final start = _parseNormalizedToMs(sText);
      final end = _parseNormalizedToMs(eText);
      if (end <= start) {
        return showToast(context, '세그먼트 ${i + 1}: 종료 시각이 시작보다 커야 합니다.');
      }

      // 세그 범위가 영상 길이를 넘지 않도록
      if (start < 0 || end > durationMs) {
        return showToast(context, '세그먼트 ${i + 1}: 구간이 영상 길이를 벗어납니다.');
      }

      seg.add(db.Segment(
        id: 0,
        clipId: 0,
        startMs: start,
        endMs: end,
        original: ja,
        pron: pr,
        trans: ko,
      ));
    }
    if (seg.isEmpty) return showToast(context, '세그먼트는 최소 1개 이상 필요합니다.');

    // 정렬 + 겹침 금지
    seg.sort((a, b) => a.startMs.compareTo(b.startMs));
    for (int i = 1; i < seg.length; i++) {
      final prev = seg[i - 1];
      final cur = seg[i];
      if (cur.startMs < prev.endMs) {
        return showToast(context, '세그먼트 ${i}와 ${i + 1}이 겹칩니다. 시간을 조정하세요.');
      }
    }

    // ----- 4) 여기서부터는 기존 저장 로직 그대로 (relPath 결정, add/update 등) -----
    setState(() => _saving = true);
    try {
      final mp = context.read<MediaProvider>();

      // (a) 상대경로 결정
      String relPath;
      if (_isEdit && !_fileChanged && (_existingRelPath?.isNotEmpty ?? false)) {
        relPath = _existingRelPath!;
      } else {
        relPath = await finalizeStaged(stagedPath);
      }

      // (b) 저장/업데이트
      if (_isEdit && widget.clipId != null) {
        String? oldAbs;
        if (_fileChanged && (_existingRelPath?.isNotEmpty ?? false)) {
          oldAbs = await _absoluteFromRelative(_existingRelPath!);
        }

        await mp.updateMedia(
          clipId: widget.clipId!,
          titleName: name,
          titleNameNative: nameNative,
          type: _type,
          seasonNumber: _type == 'season' ? seasonNum : null,
          episodeNumber: _type == 'season' ? epiNumber : null,
          episodeTitle: epiTitle,
          clipTitle: clipTitle,
          filePath: relPath,
          durationMs: durationMs,
          segments: seg,
          tags: _tags,
        );

        if (oldAbs != null) {
          try {
            final f = File(oldAbs);
            if (await f.exists()) await f.delete();
          } catch (_) {}
        }
        if (!mounted) return;
        showToast(context, '업데이트 완료!');
      } else {
        await mp.addMedia(
          titleName: name,
          titleNameNative: nameNative,
          type: _type,
          seasonNumber: _type == 'season' ? seasonNum : null,
          episodeNumber: _type == 'season' ? epiNumber : null,
          episodeTitle: epiTitle,
          clipTitle: clipTitle,
          filePath: relPath,
          durationMs: durationMs,
          segments: seg,
          tags: _tags,
        );
        if (!mounted) return;
        showToast(context, '저장 완료!');
      }

      if (!mounted) return;
      Navigator.of(context).pop(true);
    } catch (e) {
      showToast(context, '저장 실패: $e');
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }
}
